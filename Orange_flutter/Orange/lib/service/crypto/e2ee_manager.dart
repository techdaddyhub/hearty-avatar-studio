import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:orange_ui/service/session_manager.dart';
import 'package:orange_ui/utils/const_res.dart';
import 'package:orange_ui/utils/urls.dart';
import 'package:uuid/uuid.dart';

import 'aes256.dart';
import 'double_ratchet.dart';
import 'hkdf.dart';
import 'x25519.dart';

/// WeChat-Standard Zero-Knowledge End-to-End Encryption Manager
class E2EEManager {
  static final E2EEManager instance = E2EEManager._();
  static E2EEManager get shared => instance;

  E2EEManager._();

  late GetStorage _vault;
  final Map<int, RatchetSession> _activeSessions = {};
  bool _isInitialized = false;

  Uint8List? _identityPrivKey;
  Uint8List? _identityPubKey;

  bool get isInitialized => _isInitialized;
  String get identityPublicKeyBase64 => _identityPubKey != null ? base64Encode(_identityPubKey!) : '';

  /// Initialize local crypto storage and synchronize X3DH pre-keys with server
  Future<void> initialize() async {
    if (_isInitialized) return;
    _vault = GetStorage('HeartyE2EEVault');

    final storedPriv = _vault.read<String>('identity_priv');
    final storedPub = _vault.read<String>('identity_pub');

    if (storedPriv != null && storedPub != null) {
      _identityPrivKey = base64Decode(storedPriv);
      _identityPubKey = base64Decode(storedPub);
    } else {
      // Generate new identity key pair
      _identityPrivKey = X25519.generatePrivateKey();
      _identityPubKey = X25519.scalarMultBase(_identityPrivKey!);
      _vault.write('identity_priv', base64Encode(_identityPrivKey!));
      _vault.write('identity_pub', base64Encode(_identityPubKey!));
    }

    // Load cached sessions
    final storedSessions = _vault.read<Map<String, dynamic>>('sessions') ?? {};
    storedSessions.forEach((key, value) {
      final userId = int.tryParse(key);
      if (userId != null && value is Map<String, dynamic>) {
        try {
          _activeSessions[userId] = RatchetSession.fromJson(value);
        } catch (e) {
          dev.log('[E2EE] Failed to parse session for $userId: $e');
        }
      }
    });

    _isInitialized = true;
    dev.log('[E2EE] Cryptographic layer initialized. Identity PubKey: $identityPublicKeyBase64');

    // Register or replenish pre-keys if user is logged in
    final myUserId = SessionManager.instance.getUserID();
    if (myUserId > 0) {
      publishPreKeyBundle();
    }
  }

  /// Generate and publish X3DH Pre-Key Bundle to the Blind Relay Backend
  Future<bool> publishPreKeyBundle() async {
    if (_identityPrivKey == null || _identityPubKey == null) return false;

    try {
      // 1. Generate Signed Pre-Key
      final signedPreKeyPriv = X25519.generatePrivateKey();
      final signedPreKeyPub = X25519.scalarMultBase(signedPreKeyPriv);

      // Sign SPK using identity key (HMAC signature for curve point authentication)
      final sigMac = Hmac(sha256, _identityPrivKey!).convert(signedPreKeyPub).bytes;

      // 2. Generate batch of 25 One-Time Pre-Keys (OPKs)
      final opkPublicList = <String>[];
      final opkPrivateMap = <String, String>{};

      for (int i = 0; i < 25; i++) {
        final opkPriv = X25519.generatePrivateKey();
        final opkPub = X25519.scalarMultBase(opkPriv);
        final pubB64 = base64Encode(opkPub);
        opkPublicList.add(pubB64);
        opkPrivateMap[pubB64] = base64Encode(opkPriv);
      }

      // Persist private keys locally in vault
      _vault.write('signed_prekey_priv', base64Encode(signedPreKeyPriv));
      _vault.write('signed_prekey_pub', base64Encode(signedPreKeyPub));
      final existingOpks = _vault.read<Map<String, dynamic>>('opk_private_map') ?? {};
      existingOpks.addAll(opkPrivateMap);
      _vault.write('opk_private_map', existingOpks);

      // 3. Publish to server
      final myUserId = SessionManager.instance.getUserID();
      final payload = {
        'user_id': myUserId.toString(),
        'identity_key': base64Encode(_identityPubKey!),
        'signed_prekey': base64Encode(signedPreKeyPub),
        'signed_prekey_signature': base64Encode(sigMac),
        'one_time_prekeys': jsonEncode(opkPublicList),
      };

      final response = await http.post(
        Uri.parse(Urls.e2eePrekeysPublish),
        headers: {
          Urls.apiKeyName: ConstRes.apiKey,
        },
        body: payload,
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        dev.log('[E2EE] Pre-key bundle published successfully');
        return true;
      } else {
        dev.log('[E2EE] Failed to publish pre-keys: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      dev.log('[E2EE] Error publishing pre-keys: $e');
      return false;
    }
  }

  /// Get or establish a Double Ratchet session with a contact
  Future<RatchetSession> getOrCreateSession(int peerUserId) async {
    if (_activeSessions.containsKey(peerUserId)) {
      return _activeSessions[peerUserId]!;
    }

    // Fetch peer's pre-key bundle from Laravel
    final response = await http.post(
      Uri.parse('${Urls.e2eePrekeysBundle}$peerUserId'),
      headers: {Urls.apiKeyName: ConstRes.apiKey},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch pre-key bundle for peer $peerUserId: ${response.body}');
    }

    final data = jsonDecode(response.body);
    if (data['status'] != true || data['data'] == null) {
      throw Exception('Peer $peerUserId has not registered cryptographic pre-keys yet.');
    }

    final bundle = data['data'] as Map<String, dynamic>;
    final peerIdentityPub = base64Decode(bundle['identity_key'] as String);
    final peerSignedPrekey = base64Decode(bundle['signed_prekey'] as String);
    final peerOneTimePub = bundle['one_time_prekey'] != null
        ? base64Decode(bundle['one_time_prekey'] as String)
        : null;

    // X3DH Key Agreement (Alice's side):
    // DH1 = X25519(IdentityPriv_A, SignedPrekey_B)
    final dh1 = X25519.scalarMult(_identityPrivKey!, peerSignedPrekey);

    // Generate ephemeral key pair EK_A
    final ekPriv = X25519.generatePrivateKey();
    final ekPub = X25519.scalarMultBase(ekPriv);

    // DH2 = X25519(EK_A, IdentityPub_B)
    final dh2 = X25519.scalarMult(ekPriv, peerIdentityPub);

    // DH3 = X25519(EK_A, SignedPrekey_B)
    final dh3 = X25519.scalarMult(ekPriv, peerSignedPrekey);

    // DH4 = X25519(EK_A, OneTimePrekey_B) (if available)
    Uint8List? dh4;
    if (peerOneTimePub != null) {
      dh4 = X25519.scalarMult(ekPriv, peerOneTimePub);
    }

    // Combine DH outputs into master secret using HKDF
    final dhMasterBytes = BytesBuilder();
    dhMasterBytes.add(dh1);
    dhMasterBytes.add(dh2);
    dhMasterBytes.add(dh3);
    if (dh4 != null) dhMasterBytes.add(dh4);

    final masterSecret = HKDF.deriveKey(
      salt: Uint8List(32),
      ikm: dhMasterBytes.toBytes(),
      info: utf8.encode('Hearty-X3DH-MasterSecret') as Uint8List,
      length: 32,
    );

    // Initialize Ratchet Session as Initiator
    final session = RatchetSession.initAsInitiator(
      peerUserId: peerUserId,
      sharedMasterSecret: masterSecret,
      bobRatchetPub: peerSignedPrekey,
    );

    _activeSessions[peerUserId] = session;
    _saveSession(peerUserId, session);
    return session;
  }

  /// Encrypt a message payload into a zero-knowledge blind relay envelope
  Future<Map<String, dynamic>> encryptMessage({
    required int peerUserId,
    required String plaintext,
    String messageType = 'text',
    String? mediaUrl,
  }) async {
    final session = await getOrCreateSession(peerUserId);
    final envelope = session.encrypt(plaintext, messageType: messageType);
    _saveSession(peerUserId, session);

    final messageUid = const Uuid().v4();
    final myUserId = SessionManager.instance.getUserID();

    return {
      'message_uid': messageUid,
      'sender_id': myUserId,
      'recipient_id': peerUserId,
      'message_type': messageType,
      'ciphertext_payload': envelope.ciphertext,
      'iv': envelope.iv,
      'mac': envelope.mac,
      'ephemeral_pubkey': envelope.ephemeralPub,
      'media_url': mediaUrl ?? '',
      'seq': envelope.seq,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Decrypt an incoming encrypted envelope from peer
  String decryptMessage({
    required int peerUserId,
    required Map<String, dynamic> envelopeData,
  }) {
    RatchetSession? session = _activeSessions[peerUserId];

    // If session doesn't exist, initialize as recipient
    if (session == null) {
      final signedPreKeyPrivStr = _vault.read<String>('signed_prekey_priv');
      final signedPreKeyPubStr = _vault.read<String>('signed_prekey_pub');
      final bobRatchetPriv = signedPreKeyPrivStr != null
          ? base64Decode(signedPreKeyPrivStr)
          : _identityPrivKey!;
      final bobRatchetPub = signedPreKeyPubStr != null
          ? base64Decode(signedPreKeyPubStr)
          : _identityPubKey!;

      session = RatchetSession.initAsRecipient(
        peerUserId: peerUserId,
        sharedMasterSecret: Uint8List(32),
        bobRatchetPriv: bobRatchetPriv,
        bobRatchetPub: bobRatchetPub,
      );
      _activeSessions[peerUserId] = session;
    }

    final envelope = EncryptedEnvelope.fromJson(envelopeData);
    final plaintext = session.decrypt(envelope);
    _saveSession(peerUserId, session);
    return plaintext;
  }

  /// WeChat Moments Client-Side Envelope Encryption
  /// Generates symmetric key K_moment, encrypts content & media, then distributes K_moment in envelopes to friends
  Future<Map<String, dynamic>> encryptMoment({
    required String textContent,
    required List<String> mediaUrls,
    required List<int> friendUserIds,
  }) async {
    // 1. Generate 32-byte ephemeral Moment Symmetric Key and 16-byte IV
    final rng = Random.secure();
    final momentKey = Uint8List(32);
    final iv = Uint8List(16);
    for (int i = 0; i < 32; i++) momentKey[i] = rng.nextInt(256);
    for (int i = 0; i < 16; i++) iv[i] = rng.nextInt(256);

    // 2. Encrypt moment metadata & payload
    final plainPayload = jsonEncode({
      'content': textContent,
      'media_urls': mediaUrls,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    final cipherBytes = AES256.processCtr(
      key: momentKey,
      iv: iv,
      data: Uint8List.fromList(utf8.encode(plainPayload)),
    );

    // Compute MAC over (iv + ciphertext)
    final macPayload = BytesBuilder();
    macPayload.add(iv);
    macPayload.add(cipherBytes);
    final mac = Uint8List.fromList(Hmac(sha256, momentKey).convert(macPayload.toBytes()).bytes);

    // 3. Encrypt momentKey for each friend (Key Envelopes)
    final keyEnvelopes = <Map<String, dynamic>>[];
    for (final friendId in friendUserIds) {
      try {
        final session = await getOrCreateSession(friendId);
        final keyEnv = session.encrypt(base64Encode(momentKey), messageType: 'moment_key');
        _saveSession(friendId, session);

        keyEnvelopes.add({
          'recipient_id': friendId,
          'encrypted_key': keyEnv.ciphertext,
          'iv': keyEnv.iv,
          'mac': keyEnv.mac,
          'ephemeral_pubkey': keyEnv.ephemeralPub,
        });
      } catch (e) {
        dev.log('[E2EE] Could not create moment key envelope for friend $friendId: $e');
      }
    }

    return {
      'ciphertext': base64Encode(cipherBytes),
      'iv': base64Encode(iv),
      'mac': base64Encode(mac),
      'key_envelopes': keyEnvelopes,
    };
  }

  /// Decrypt a WeChat Moment received from a mutual friend
  String? decryptMoment({
    required int authorId,
    required String ciphertextB64,
    required String ivB64,
    required String macB64,
    required Map<String, dynamic> myKeyEnvelope,
  }) {
    try {
      // 1. Decrypt momentKey from envelope
      final momentKeyB64 = decryptMessage(
        peerUserId: authorId,
        envelopeData: myKeyEnvelope,
      );
      final momentKey = base64Decode(momentKeyB64);
      final iv = base64Decode(ivB64);
      final cipherBytes = base64Decode(ciphertextB64);
      final expectedMac = base64Decode(macB64);

      // 2. Verify MAC
      final macPayload = BytesBuilder();
      macPayload.add(iv);
      macPayload.add(cipherBytes);
      final computedMac = Uint8List.fromList(Hmac(sha256, momentKey).convert(macPayload.toBytes()).bytes);

      if (!_constantTimeEquals(computedMac, expectedMac)) {
        dev.log('[E2EE] Moment MAC verification failed');
        return null;
      }

      // 3. Decrypt payload
      final plainBytes = AES256.processCtr(key: momentKey, iv: iv, data: cipherBytes);
      return utf8.decode(plainBytes);
    } catch (e) {
      dev.log('[E2EE] Error decrypting moment from author $authorId: $e');
      return null;
    }
  }

  void _saveSession(int peerUserId, RatchetSession session) {
    final sessions = _vault.read<Map<String, dynamic>>('sessions') ?? {};
    sessions[peerUserId.toString()] = session.toJson();
    _vault.write('sessions', sessions);
  }

  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    int diff = 0;
    for (int i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}

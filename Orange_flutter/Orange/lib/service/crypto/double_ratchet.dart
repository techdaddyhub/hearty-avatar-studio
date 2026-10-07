import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'aes256.dart';
import 'hkdf.dart';
import 'x25519.dart';

/// Double Ratchet Session State & Cryptographic Engine
/// Conforms to Signal Protocol / Double Ratchet Specification
class RatchetSession {
  final int peerUserId;
  Uint8List rootKey;
  Uint8List sendChainKey;
  Uint8List recvChainKey;
  Uint8List ourRatchetPriv;
  Uint8List ourRatchetPub;
  Uint8List recvRatchetPub;
  int sendSeq;
  int recvSeq;

  RatchetSession({
    required this.peerUserId,
    required this.rootKey,
    required this.sendChainKey,
    required this.recvChainKey,
    required this.ourRatchetPriv,
    required this.ourRatchetPub,
    required this.recvRatchetPub,
    this.sendSeq = 0,
    this.recvSeq = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'peerUserId': peerUserId,
      'rootKey': base64Encode(rootKey),
      'sendChainKey': base64Encode(sendChainKey),
      'recvChainKey': base64Encode(recvChainKey),
      'ourRatchetPriv': base64Encode(ourRatchetPriv),
      'ourRatchetPub': base64Encode(ourRatchetPub),
      'recvRatchetPub': base64Encode(recvRatchetPub),
      'sendSeq': sendSeq,
      'recvSeq': recvSeq,
    };
  }

  factory RatchetSession.fromJson(Map<String, dynamic> json) {
    return RatchetSession(
      peerUserId: json['peerUserId'] as int,
      rootKey: base64Decode(json['rootKey'] as String),
      sendChainKey: base64Decode(json['sendChainKey'] as String),
      recvChainKey: base64Decode(json['recvChainKey'] as String),
      ourRatchetPriv: base64Decode(json['ourRatchetPriv'] as String),
      ourRatchetPub: base64Decode(json['ourRatchetPub'] as String),
      recvRatchetPub: base64Decode(json['recvRatchetPub'] as String),
      sendSeq: json['sendSeq'] as int? ?? 0,
      recvSeq: json['recvSeq'] as int? ?? 0,
    );
  }

  /// Initialize a new session as Alice (Initiator) using Bob's prekey bundle
  static RatchetSession initAsInitiator({
    required int peerUserId,
    required Uint8List sharedMasterSecret,
    required Uint8List bobRatchetPub,
  }) {
    // Generate Alice's initial DH ratchet key pair
    final alicePriv = X25519.generatePrivateKey();
    final alicePub = X25519.scalarMultBase(alicePriv);

    // Initial DH key agreement with Bob's ratchet pubkey
    final dhShared = X25519.scalarMult(alicePriv, bobRatchetPub);

    // Derive Root Key and Send Chain Key
    final derived = HKDF.deriveKey(
      salt: sharedMasterSecret,
      ikm: dhShared,
      info: utf8.encode('DoubleRatchet-Root-Initiator') as Uint8List,
      length: 64,
    );

    final rootKey = derived.sublist(0, 32);
    final sendChainKey = derived.sublist(32, 64);
    final recvChainKey = Uint8List(32); // initialized on first receive

    return RatchetSession(
      peerUserId: peerUserId,
      rootKey: rootKey,
      sendChainKey: sendChainKey,
      recvChainKey: recvChainKey,
      ourRatchetPriv: alicePriv,
      ourRatchetPub: alicePub,
      recvRatchetPub: bobRatchetPub,
      sendSeq: 0,
      recvSeq: 0,
    );
  }

  /// Initialize a new session as Bob (Recipient)
  static RatchetSession initAsRecipient({
    required int peerUserId,
    required Uint8List sharedMasterSecret,
    required Uint8List bobRatchetPriv,
    required Uint8List bobRatchetPub,
  }) {
    return RatchetSession(
      peerUserId: peerUserId,
      rootKey: sharedMasterSecret,
      sendChainKey: Uint8List(32),
      recvChainKey: Uint8List(32),
      ourRatchetPriv: bobRatchetPriv,
      ourRatchetPub: bobRatchetPub,
      recvRatchetPub: Uint8List(32), // received from Alice in 1st message
      sendSeq: 0,
      recvSeq: 0,
    );
  }

  /// Encrypt a message payload and ratchet forward
  EncryptedEnvelope encrypt(String plaintext, {String? messageType}) {
    // 1. Ratchet send chain key forward: MK = HMAC(CKs, 0x01), CKs_next = HMAC(CKs, 0x02)
    final hmac1 = Hmac(sha256, sendChainKey);
    final messageKey = Uint8List.fromList(hmac1.convert([0x01]).bytes);
    sendChainKey = Uint8List.fromList(hmac1.convert([0x02]).bytes);

    // 2. Derive AES key (32 bytes) and HMAC key (32 bytes) from messageKey
    final derived = HKDF.deriveKey(
      salt: Uint8List(32),
      ikm: messageKey,
      info: utf8.encode('DoubleRatchet-MsgKeys') as Uint8List,
      length: 64,
    );
    final aesKey = derived.sublist(0, 32);
    final macKey = derived.sublist(32, 64);

    // 3. Generate random 16-byte IV
    final rng = Random.secure();
    final iv = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      iv[i] = rng.nextInt(256);
    }

    // 4. Encrypt with AES-256-CTR
    final plainBytes = Uint8List.fromList(utf8.encode(plaintext));
    final cipherBytes = AES256.processCtr(key: aesKey, iv: iv, data: plainBytes);

    // 5. Compute HMAC-SHA256 over (IV + Ciphertext + sequence)
    final macPayload = BytesBuilder();
    macPayload.add(iv);
    macPayload.add(cipherBytes);
    macPayload.add(ourRatchetPub);
    macPayload.add([sendSeq & 0xff, (sendSeq >> 8) & 0xff]);

    final mac = Uint8List.fromList(Hmac(sha256, macKey).convert(macPayload.toBytes()).bytes);

    final envelope = EncryptedEnvelope(
      ciphertext: base64Encode(cipherBytes),
      iv: base64Encode(iv),
      mac: base64Encode(mac),
      ephemeralPub: base64Encode(ourRatchetPub),
      seq: sendSeq,
      messageType: messageType ?? 'text',
    );

    sendSeq++;
    return envelope;
  }

  /// Decrypt incoming message and ratchet forward
  String decrypt(EncryptedEnvelope envelope) {
    final incomingPub = base64Decode(envelope.ephemeralPub);

    // Check if remote ratchet pubkey changed (DH ratchet step)
    if (_bytesDifferent(incomingPub, recvRatchetPub)) {
      _dhRatchetStep(incomingPub);
    }

    // 1. Ratchet receive chain key forward: MK = HMAC(CKr, 0x01), CKr_next = HMAC(CKr, 0x02)
    final hmac1 = Hmac(sha256, recvChainKey);
    final messageKey = Uint8List.fromList(hmac1.convert([0x01]).bytes);
    recvChainKey = Uint8List.fromList(hmac1.convert([0x02]).bytes);

    // 2. Derive AES and MAC keys
    final derived = HKDF.deriveKey(
      salt: Uint8List(32),
      ikm: messageKey,
      info: utf8.encode('DoubleRatchet-MsgKeys') as Uint8List,
      length: 64,
    );
    final aesKey = derived.sublist(0, 32);
    final macKey = derived.sublist(32, 64);

    final iv = base64Decode(envelope.iv);
    final cipherBytes = base64Decode(envelope.ciphertext);
    final expectedMac = base64Decode(envelope.mac);

    // 3. Verify HMAC-SHA256 in constant time
    final macPayload = BytesBuilder();
    macPayload.add(iv);
    macPayload.add(cipherBytes);
    macPayload.add(incomingPub);
    macPayload.add([envelope.seq & 0xff, (envelope.seq >> 8) & 0xff]);

    final computedMac = Uint8List.fromList(Hmac(sha256, macKey).convert(macPayload.toBytes()).bytes);
    if (!_constantTimeEquals(computedMac, expectedMac)) {
      throw const FormatException('Cryptographic MAC verification failed. Message was tampered with or corrupted.');
    }

    // 4. Decrypt with AES-256-CTR
    final plainBytes = AES256.processCtr(key: aesKey, iv: iv, data: cipherBytes);
    recvSeq++;
    return utf8.decode(plainBytes);
  }

  void _dhRatchetStep(Uint8List newRemotePub) {
    recvRatchetPub = newRemotePub;

    // Receive DH step
    final dhRecv = X25519.scalarMult(ourRatchetPriv, recvRatchetPub);
    final derivedRecv = HKDF.deriveKey(
      salt: rootKey,
      ikm: dhRecv,
      info: utf8.encode('DoubleRatchet-RecvChain') as Uint8List,
      length: 64,
    );
    rootKey = derivedRecv.sublist(0, 32);
    recvChainKey = derivedRecv.sublist(32, 64);

    // Generate our new DH ratchet key pair
    ourRatchetPriv = X25519.generatePrivateKey();
    ourRatchetPub = X25519.scalarMultBase(ourRatchetPriv);

    // Send DH step
    final dhSend = X25519.scalarMult(ourRatchetPriv, recvRatchetPub);
    final derivedSend = HKDF.deriveKey(
      salt: rootKey,
      ikm: dhSend,
      info: utf8.encode('DoubleRatchet-SendChain') as Uint8List,
      length: 64,
    );
    rootKey = derivedSend.sublist(0, 32);
    sendChainKey = derivedSend.sublist(32, 64);
  }

  bool _bytesDifferent(Uint8List a, Uint8List b) {
    if (a.length != b.length) return true;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return true;
    }
    return false;
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

/// Encrypted Envelope transmitted through the Zero-Knowledge Blind Relay
class EncryptedEnvelope {
  final String ciphertext;
  final String iv;
  final String mac;
  final String ephemeralPub;
  final int seq;
  final String messageType;

  EncryptedEnvelope({
    required this.ciphertext,
    required this.iv,
    required this.mac,
    required this.ephemeralPub,
    required this.seq,
    required this.messageType,
  });

  Map<String, dynamic> toJson() => {
    'ciphertext': ciphertext,
    'iv': iv,
    'mac': mac,
    'ephemeral_pub': ephemeralPub,
    'seq': seq,
    'message_type': messageType,
  };

  factory EncryptedEnvelope.fromJson(Map<String, dynamic> json) => EncryptedEnvelope(
    ciphertext: json['ciphertext'] as String? ?? json['ciphertext_payload'] as String? ?? '',
    iv: json['iv'] as String? ?? '',
    mac: json['mac'] as String? ?? '',
    ephemeralPub: json['ephemeral_pub'] as String? ?? json['ephemeral_pubkey'] as String? ?? '',
    seq: json['seq'] as int? ?? 0,
    messageType: json['message_type'] as String? ?? 'text',
  );
}

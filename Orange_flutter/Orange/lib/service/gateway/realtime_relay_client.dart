import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:orange_ui/service/crypto/e2ee_manager.dart';
import 'package:orange_ui/service/session_manager.dart';
import 'package:orange_ui/utils/const_res.dart';
import 'package:orange_ui/utils/urls.dart';

class DecryptedMessage {
  final String messageUid;
  final int senderId;
  final int recipientId;
  final String messageType; // text, audio, image, video, card
  final String content;
  final String? mediaUrl;
  final int timestamp;
  final bool isMine;

  DecryptedMessage({
    required this.messageUid,
    required this.senderId,
    required this.recipientId,
    required this.messageType,
    required this.content,
    this.mediaUrl,
    required this.timestamp,
    required this.isMine,
  });

  Map<String, dynamic> toJson() => {
    'message_uid': messageUid,
    'sender_id': senderId,
    'recipient_id': recipientId,
    'message_type': messageType,
    'content': content,
    'media_url': mediaUrl,
    'timestamp': timestamp,
    'is_mine': isMine,
  };

  factory DecryptedMessage.fromJson(Map<String, dynamic> json) => DecryptedMessage(
    messageUid: json['message_uid'] as String,
    senderId: json['sender_id'] as int,
    recipientId: json['recipient_id'] as int,
    messageType: json['message_type'] as String,
    content: json['content'] as String,
    mediaUrl: json['media_url'] as String?,
    timestamp: json['timestamp'] as int,
    isMine: json['is_mine'] as bool? ?? false,
  );
}

/// Zero-Knowledge Blind Message Relay Client
class RealtimeRelayClient {
  static final RealtimeRelayClient instance = RealtimeRelayClient._();
  static RealtimeRelayClient get shared => instance;

  RealtimeRelayClient._();

  WebSocket? _webSocket;
  Timer? _pollingTimer;
  bool _isConnected = false;

  final _messageStreamController = StreamController<DecryptedMessage>.broadcast();
  Stream<DecryptedMessage> get onMessage => _messageStreamController.stream;

  bool get isConnected => _isConnected;

  /// Start duplex real-time connection and polling fallback
  void connect() {
    final myUserId = SessionManager.instance.getUserID();
    if (myUserId <= 0) return;

    _connectWebSocket(myUserId);

    // Fallback polling every 5 seconds to ensure zero missed messages
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchPendingMessages();
    });
  }

  void disconnect() {
    _pollingTimer?.cancel();
    _webSocket?.close();
    _webSocket = null;
    _isConnected = false;
  }

  Future<void> _connectWebSocket(int myUserId) async {
    try {
      // Connect to hardware streaming gateway / blind relay port 9090
      final wsUrl = 'ws://hearty.dmillers.org:9090';
      _webSocket = await WebSocket.connect(wsUrl).timeout(const Duration(seconds: 5));
      _isConnected = true;
      log('[RelayClient] Connected to blind relay gateway');

      // Register client ID with relay
      _webSocket!.add(jsonEncode({
        'type': 'register',
        'userId': myUserId,
      }));

      _webSocket!.listen(
        (data) {
          _handleIncomingRawData(data);
        },
        onError: (err) {
          log('[RelayClient] WebSocket error: $err');
          _isConnected = false;
        },
        onDone: () {
          log('[RelayClient] WebSocket closed, retrying in 10s...');
          _isConnected = false;
          Future.delayed(const Duration(seconds: 10), () => connect());
        },
      );
    } catch (e) {
      log('[RelayClient] WebSocket direct connection unavailable ($e), using HTTP mailbox sync');
      _isConnected = false;
    }
  }

  void _handleIncomingRawData(dynamic data) {
    try {
      final json = jsonDecode(data.toString());
      if (json['type'] == 'message' && json['envelope'] != null) {
        _processEnvelope(json['envelope'] as Map<String, dynamic>);
      }
    } catch (e) {
      log('[RelayClient] Failed to parse message frame: $e');
    }
  }

  /// Send an encrypted message through the Blind Relay
  Future<DecryptedMessage?> sendMessage({
    required int recipientId,
    required String text,
    String messageType = 'text',
    String? mediaUrl,
  }) async {
    final myUserId = SessionManager.instance.getUserID();
    if (myUserId <= 0) throw Exception('User not authenticated');

    try {
      // 1. Client-side E2EE encryption
      final envelope = await E2EEManager.shared.encryptMessage(
        peerUserId: recipientId,
        plaintext: text,
        messageType: messageType,
        mediaUrl: mediaUrl,
      );

      // 2. Dispatch to Blind Relay WebSocket if live
      if (_webSocket != null && _isConnected) {
        _webSocket!.add(jsonEncode({
          'type': 'relay_envelope',
          'envelope': envelope,
        }));
      }

      // 3. Guaranteed store-and-forward sync to Laravel Blind Relay queue
      await http.post(
        Uri.parse(Urls.e2eeMessageSend),
        headers: {
          Urls.apiKeyName: ConstRes.apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(envelope),
      ).timeout(const Duration(seconds: 10));

      final sentMessage = DecryptedMessage(
        messageUid: envelope['message_uid'] as String,
        senderId: myUserId,
        recipientId: recipientId,
        messageType: messageType,
        content: text,
        mediaUrl: mediaUrl,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        isMine: true,
      );

      return sentMessage;
    } catch (e) {
      log('[RelayClient] Error sending encrypted message: $e');
      rethrow;
    }
  }

  /// Poll and retrieve pending blind envelopes from mailbox
  Future<void> fetchPendingMessages() async {
    final myUserId = SessionManager.instance.getUserID();
    if (myUserId <= 0) return;

    try {
      final response = await http.post(
        Uri.parse(Urls.e2eeMessagePending),
        headers: {
          Urls.apiKeyName: ConstRes.apiKey,
        },
        body: {
          'user_id': myUserId.toString(),
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['messages'] is List) {
          final list = data['messages'] as List;
          for (final raw in list) {
            if (raw is Map<String, dynamic>) {
              await _processEnvelope(raw);
            }
          }
        }
      }
    } catch (e) {
      log('[RelayClient] Error fetching pending envelopes: $e');
    }
  }

  Future<void> _processEnvelope(Map<String, dynamic> raw) async {
    try {
      final senderId = raw['sender_id'] is int ? raw['sender_id'] as int : int.parse(raw['sender_id'].toString());
      final recipientId = raw['recipient_id'] is int ? raw['recipient_id'] as int : int.parse(raw['recipient_id'].toString());
      final messageUid = raw['message_uid'] as String;
      final messageType = raw['message_type'] as String? ?? 'text';
      final mediaUrl = raw['media_url'] as String?;

      // Decrypt client-side
      final decryptedText = E2EEManager.shared.decryptMessage(
        peerUserId: senderId,
        envelopeData: raw,
      );

      final msg = DecryptedMessage(
        messageUid: messageUid,
        senderId: senderId,
        recipientId: recipientId,
        messageType: messageType,
        content: decryptedText,
        mediaUrl: mediaUrl,
        timestamp: raw['timestamp'] != null
            ? (raw['timestamp'] is int ? raw['timestamp'] as int : int.tryParse(raw['timestamp'].toString()) ?? DateTime.now().millisecondsSinceEpoch)
            : DateTime.now().millisecondsSinceEpoch,
        isMine: false,
      );

      // Emit to listeners
      _messageStreamController.add(msg);

      // Send ACK to server to immediately delete ciphertext from database
      acknowledgeMessage(messageUid);
    } catch (e) {
      log('[RelayClient] Error decrypting incoming envelope: $e');
    }
  }

  /// Fire ACK to purge message from server database
  Future<void> acknowledgeMessage(String messageUid) async {
    try {
      await http.post(
        Uri.parse(Urls.e2eeMessageAck),
        headers: {
          Urls.apiKeyName: ConstRes.apiKey,
        },
        body: {
          'message_uid': messageUid,
        },
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      log('[RelayClient] ACK error for $messageUid: $e');
    }
  }

  /// Upload opaque encrypted media blob (Voice note, image, video)
  Future<String?> uploadEncryptedBlob(File file, String contentType) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(Urls.e2eeBlobUpload));
      request.headers[Urls.apiKeyName] = ConstRes.apiKey;
      request.fields['content_type'] = contentType;
      request.files.add(await http.MultipartFile.fromPath('blob', file.path));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 25));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['url'] != null) {
          return data['url'] as String;
        }
      }
      return null;
    } catch (e) {
      log('[RelayClient] Error uploading encrypted blob: $e');
      return null;
    }
  }
}

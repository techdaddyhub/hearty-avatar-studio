import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:orange_ui/service/crypto/e2ee_manager.dart';
import 'package:orange_ui/service/session_manager.dart';
import 'package:orange_ui/utils/const_res.dart';
import 'package:orange_ui/utils/urls.dart';
import 'package:stacked/stacked.dart';

class DecryptedMoment {
  final int momentId;
  final int authorId;
  final String authorName;
  final String? authorImage;
  final String content;
  final List<String> mediaUrls;
  final int timestamp;
  final int likeCount;
  final int commentCount;
  bool isLiked;

  DecryptedMoment({
    required this.momentId,
    required this.authorId,
    required this.authorName,
    this.authorImage,
    required this.content,
    required this.mediaUrls,
    required this.timestamp,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });
}

class MomentsScreenViewModel extends BaseViewModel {
  List<DecryptedMoment> moments = [];
  bool isLoading = true;
  bool isPublishing = false;

  void init() {
    fetchFeed();
  }

  Future<void> fetchFeed() async {
    isLoading = true;
    notifyListeners();

    try {
      final myUserId = SessionManager.instance.getUserID();
      final response = await http.post(
        Uri.parse(Urls.momentsFeed),
        headers: {Urls.apiKeyName: ConstRes.apiKey},
        body: {'user_id': myUserId.toString()},
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] is List) {
          final list = data['data'] as List;
          final decryptedList = <DecryptedMoment>[];

          for (final item in list) {
            try {
              final raw = item as Map<String, dynamic>;
              final author = raw['author'] as Map<String, dynamic>? ?? {};
              final authorId = raw['author_id'] is int ? raw['author_id'] as int : int.parse(raw['author_id'].toString());
              final momentId = raw['id'] is int ? raw['id'] as int : int.parse(raw['id'].toString());
              final myEnvelope = raw['my_key_envelope'] as Map<String, dynamic>?;

              // If it's my own post or we have a key envelope, decrypt
              String content = '';
              List<String> mediaUrls = [];

              if (authorId == myUserId) {
                // Author's own device plaintext or decrypt
                content = raw['plaintext_content'] ?? 'Encrypted Moment';
                mediaUrls = (raw['media_urls'] is List) ? List<String>.from(raw['media_urls']) : [];
              } else if (myEnvelope != null) {
                final decryptedJsonStr = E2EEManager.shared.decryptMoment(
                  authorId: authorId,
                  ciphertextB64: raw['ciphertext'] as String? ?? '',
                  ivB64: raw['iv'] as String? ?? '',
                  macB64: raw['mac'] as String? ?? '',
                  myKeyEnvelope: myEnvelope,
                );

                if (decryptedJsonStr != null) {
                  final parsed = jsonDecode(decryptedJsonStr) as Map<String, dynamic>;
                  content = parsed['content'] as String? ?? '';
                  if (parsed['media_urls'] is List) {
                    mediaUrls = List<String>.from(parsed['media_urls']);
                  }
                }
              }

              decryptedList.add(DecryptedMoment(
                momentId: momentId,
                authorId: authorId,
                authorName: author['fullname'] ?? author['full_name'] ?? 'Contact',
                authorImage: author['profile_image'] ?? author['image'],
                content: content.isNotEmpty ? content : '🔒 Encrypted Moment (Mutual contacts only)',
                mediaUrls: mediaUrls,
                timestamp: raw['created_at'] != null
                    ? (DateTime.tryParse(raw['created_at'].toString())?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch)
                    : DateTime.now().millisecondsSinceEpoch,
                likeCount: raw['likes_count'] is int ? raw['likes_count'] : 0,
                commentCount: raw['comments_count'] is int ? raw['comments_count'] : 0,
              ));
            } catch (e) {
              log('[Moments] Error decrypting moment: $e');
            }
          }

          moments = decryptedList;
        }
      }
    } catch (e) {
      log('[Moments] Error fetching moments feed: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> publishMoment({
    required String text,
    required List<String> mediaUrls,
    required List<int> friendIds,
  }) async {
    isPublishing = true;
    notifyListeners();

    try {
      final myUserId = SessionManager.instance.getUserID();

      // 1. Client-Side E2EE Encryption
      final encryptedBundle = await E2EEManager.shared.encryptMoment(
        textContent: text,
        mediaUrls: mediaUrls,
        friendUserIds: friendIds,
      );

      // 2. Publish to backend
      final payload = {
        'author_id': myUserId.toString(),
        'ciphertext': encryptedBundle['ciphertext'],
        'iv': encryptedBundle['iv'],
        'mac': encryptedBundle['mac'],
        'key_envelopes': jsonEncode(encryptedBundle['key_envelopes']),
      };

      final response = await http.post(
        Uri.parse(Urls.momentsPublish),
        headers: {Urls.apiKeyName: ConstRes.apiKey},
        body: payload,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          await fetchFeed();
          return true;
        }
      }
      return false;
    } catch (e) {
      log('[Moments] Error publishing moment: $e');
      return false;
    } finally {
      isPublishing = false;
      notifyListeners();
    }
  }

  void toggleLike(DecryptedMoment moment) {
    moment.isLiked = !moment.isLiked;
    notifyListeners();
  }
}


import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orange_ui/service/session_manager.dart';
import 'package:orange_ui/utils/const_res.dart';
import 'package:orange_ui/utils/urls.dart';
import 'package:stacked/stacked.dart';

class ContactItem {
  final int id;
  final int contactUserId;
  final String fullName;
  final String username;
  final String? profileImage;
  final String? remark;
  final bool isMuted;
  final bool isStarred;

  ContactItem({
    required this.id,
    required this.contactUserId,
    required this.fullName,
    required this.username,
    this.profileImage,
    this.remark,
    this.isMuted = false,
    this.isStarred = false,
  });

  String get displayName => (remark != null && remark!.isNotEmpty) ? remark! : (fullName.isNotEmpty ? fullName : username);

  factory ContactItem.fromJson(Map<String, dynamic> json) {
    final user = json['contact_user'] as Map<String, dynamic>? ?? {};
    return ContactItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      contactUserId: json['contact_user_id'] is int ? json['contact_user_id'] : int.tryParse(json['contact_user_id'].toString()) ?? 0,
      fullName: user['fullname'] ?? user['full_name'] ?? 'User',
      username: user['username'] ?? '',
      profileImage: user['profile_image'] ?? user['image'],
      remark: json['remark_name'],
      isMuted: (json['is_muted'] == 1 || json['is_muted'] == true),
      isStarred: (json['is_starred'] == 1 || json['is_starred'] == true),
    );
  }
}

class ContactRequestItem {
  final int id;
  final int requesterId;
  final String requesterName;
  final String? requesterImage;
  final String? greetingMessage;
  final String createdAt;

  ContactRequestItem({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    this.requesterImage,
    this.greetingMessage,
    required this.createdAt,
  });

  factory ContactRequestItem.fromJson(Map<String, dynamic> json) {
    final reqUser = json['requester'] as Map<String, dynamic>? ?? {};
    return ContactRequestItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      requesterId: json['requester_id'] is int ? json['requester_id'] : int.tryParse(json['requester_id'].toString()) ?? 0,
      requesterName: reqUser['fullname'] ?? reqUser['full_name'] ?? 'User',
      requesterImage: reqUser['profile_image'] ?? reqUser['image'],
      greetingMessage: json['greeting_message'],
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class ContactsScreenViewModel extends BaseViewModel {
  List<ContactItem> allContacts = [];
  Map<String, List<ContactItem>> groupedContacts = {};
  List<String> alphabetKeys = [];
  List<ContactRequestItem> pendingRequests = [];

  bool isLoading = true;
  String searchQuery = '';

  void init() {
    fetchContacts();
    fetchPendingRequests();
  }

  Future<void> fetchContacts() async {
    isLoading = true;
    notifyListeners();

    try {
      final myUserId = SessionManager.instance.getUserID();
      final response = await http.post(
        Uri.parse(Urls.contactsList),
        headers: {Urls.apiKeyName: ConstRes.apiKey},
        body: {'user_id': myUserId.toString()},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] is List) {
          final list = data['data'] as List;
          allContacts = list.map((e) => ContactItem.fromJson(e as Map<String, dynamic>)).toList();
          _organizeContacts();
        }
      }
    } catch (e) {
      log('[Contacts] Error fetching contacts: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPendingRequests() async {
    try {
      final myUserId = SessionManager.instance.getUserID();
      final response = await http.post(
        Uri.parse(Urls.contactsRequestList),
        headers: {Urls.apiKeyName: ConstRes.apiKey},
        body: {'user_id': myUserId.toString()},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] is List) {
          final list = data['data'] as List;
          pendingRequests = list.map((e) => ContactRequestItem.fromJson(e as Map<String, dynamic>)).toList();
          notifyListeners();
        }
      }
    } catch (e) {
      log('[Contacts] Error fetching pending requests: $e');
    }
  }

  void onSearchChanged(String query) {
    searchQuery = query.trim().toLowerCase();
    _organizeContacts();
    notifyListeners();
  }

  void _organizeContacts() {
    final filtered = searchQuery.isEmpty
        ? allContacts
        : allContacts.where((c) => c.displayName.toLowerCase().contains(searchQuery)).toList();

    groupedContacts = {};
    for (final contact in filtered) {
      final firstLetter = contact.displayName.isNotEmpty
          ? contact.displayName[0].toUpperCase()
          : '#';
      final key = RegExp(r'[A-Z]').hasMatch(firstLetter) ? firstLetter : '#';

      if (!groupedContacts.containsKey(key)) {
        groupedContacts[key] = [];
      }
      groupedContacts[key]!.add(contact);
    }

    // Sort group keys
    alphabetKeys = groupedContacts.keys.toList()..sort((a, b) {
      if (a == '#') return 1;
      if (b == '#') return -1;
      return a.compareTo(b);
    });

    // Sort contacts within each group
    for (final key in alphabetKeys) {
      groupedContacts[key]!.sort((a, b) => a.displayName.compareTo(b.displayName));
    }
  }

  Future<bool> respondToRequest(int requestId, String action) async {
    try {
      final myUserId = SessionManager.instance.getUserID();
      final response = await http.post(
        Uri.parse(Urls.contactsRequestRespond),
        headers: {Urls.apiKeyName: ConstRes.apiKey},
        body: {
          'user_id': myUserId.toString(),
          'request_id': requestId.toString(),
          'action': action, // accept or decline
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        pendingRequests.removeWhere((r) => r.id == requestId);
        if (action == 'accept') {
          await fetchContacts();
        } else {
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      log('[Contacts] Error responding to request: $e');
      return false;
    }
  }

  Future<bool> sendContactRequest(int targetUserId, String greeting) async {
    try {
      final myUserId = SessionManager.instance.getUserID();
      final response = await http.post(
        Uri.parse(Urls.contactsRequestSend),
        headers: {Urls.apiKeyName: ConstRes.apiKey},
        body: {
          'user_id': myUserId.toString(),
          'target_user_id': targetUserId.toString(),
          'greeting_message': greeting,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == true;
      }
      return false;
    } catch (e) {
      log('[Contacts] Error sending contact request: $e');
      return false;
    }
  }

  Future<bool> updateRemark(int contactId, String remark) async {
    try {
      final myUserId = SessionManager.instance.getUserID();
      final response = await http.post(
        Uri.parse(Urls.contactsRemark),
        headers: {Urls.apiKeyName: ConstRes.apiKey},
        body: {
          'user_id': myUserId.toString(),
          'contact_id': contactId.toString(),
          'remark_name': remark,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await fetchContacts();
        return true;
      }
      return false;
    } catch (e) {
      log('[Contacts] Error updating remark: $e');
      return false;
    }
  }

  Future<bool> deleteContact(int contactId) async {
    try {
      final myUserId = SessionManager.instance.getUserID();
      final response = await http.post(
        Uri.parse(Urls.contactsDelete),
        headers: {Urls.apiKeyName: ConstRes.apiKey},
        body: {
          'user_id': myUserId.toString(),
          'contact_id': contactId.toString(),
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await fetchContacts();
        return true;
      }
      return false;
    } catch (e) {
      log('[Contacts] Error deleting contact: $e');
      return false;
    }
  }
}

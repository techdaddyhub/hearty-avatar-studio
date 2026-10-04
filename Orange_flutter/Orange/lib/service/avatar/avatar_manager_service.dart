import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:orange_ui/model/avatar/live_avatar_model.dart';
import 'package:orange_ui/service/session_manager.dart';
import 'package:orange_ui/utils/urls.dart';

class AvatarManagerService extends GetxService {
  static AvatarManagerService get to => Get.find<AvatarManagerService>();

  final RxList<LiveAvatarModel> userAvatars = <LiveAvatarModel>[].obs;
  final RxList<LiveAvatarModel> presetAvatars = <LiveAvatarModel>[].obs;
  final Rx<LiveAvatarModel?> selectedAvatar = Rx<LiveAvatarModel?>(null);
  final RxBool isLoading = false.obs;

  final GetStorage _storage = GetStorage('Orange');
  static const String _storageKeySelectedAvatar = 'selected_avatar_id';

  @override
  void onInit() {
    super.onInit();
    presetAvatars.assignAll(LiveAvatarModel.defaultPresets);
    _restoreSelectedAvatar();
    fetchAvatars();
  }

  void _restoreSelectedAvatar() {
    final savedId = _storage.read<String>(_storageKeySelectedAvatar);
    if (savedId != null) {
      final found = presetAvatars.firstWhereOrNull((a) => a.id == savedId);
      if (found != null) {
        selectedAvatar.value = found;
        return;
      }
    }
    selectedAvatar.value = presetAvatars.first;
  }

  /// Fetch user and preset avatars from Laravel backend
  Future<void> fetchAvatars() async {
    final user = SessionManager.instance.getUser();
    if (user == null || user.id == null) return;

    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse('${Urls.aBaseUrl}api/v1/avatars/list'),
        headers: {
          'apikey': Urls.apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'user_id': user.id}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final rawUser = data['data']['user_avatars'] as List? ?? [];
          final rawPresets = data['data']['preset_avatars'] as List? ?? [];

          userAvatars.assignAll(rawUser.map((j) => LiveAvatarModel.fromJson(j)).toList());

          if (rawPresets.isNotEmpty) {
            presetAvatars.assignAll(rawPresets.map((j) => LiveAvatarModel.fromJson(j)).toList());
          }

          // Restore selection or pick default
          final savedId = _storage.read<String>(_storageKeySelectedAvatar);
          final match = [...userAvatars, ...presetAvatars].firstWhereOrNull((a) => a.id == savedId);
          if (match != null) {
            selectedAvatar.value = match;
          } else if (userAvatars.isNotEmpty) {
            selectedAvatar.value = userAvatars.first;
          }
        }
      }
    } catch (e) {
      // Offline fallback: keep default presets
    } finally {
      isLoading.value = false;
    }
  }

  /// Select an avatar as active
  void selectAvatar(LiveAvatarModel avatar) {
    selectedAvatar.value = avatar;
    _storage.write(_storageKeySelectedAvatar, avatar.id);
  }

  /// Add custom photo or 3D avatar
  Future<bool> saveCustomAvatar({
    required String name,
    required AvatarType type,
    String? localFilePath,
    String? thumbnailPath,
  }) async {
    final customAvatar = LiveAvatarModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      localFilePath: localFilePath,
      previewAsset: thumbnailPath,
      isCustomUpload: true,
    );

    userAvatars.insert(0, customAvatar);
    selectAvatar(customAvatar);
    return true;
  }
}

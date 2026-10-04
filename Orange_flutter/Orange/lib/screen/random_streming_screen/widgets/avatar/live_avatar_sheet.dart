import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/model/avatar/live_avatar_model.dart';
import 'package:orange_ui/service/avatar/avatar_manager_service.dart';
import 'package:orange_ui/service/avatar/voice_movement_sync_controller.dart';
import 'package:orange_ui/utils/color_res.dart';

class LiveAvatarSheet extends StatelessWidget {
  final VoiceMovementSyncController controller;

  const LiveAvatarSheet({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final avatarService = Get.isRegistered<AvatarManagerService>()
        ? Get.find<AvatarManagerService>()
        : Get.put(AvatarManagerService());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF141724),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Master Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Avatar Studio',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Voice Lip-Sync & Face Tracking',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: controller.isAvatarEnabled,
                    activeColor: ColorRes.themeColor,
                    onChanged: (val) => controller.setAvatarEnabled(val),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick Controls (Face Tracking, Virtual Cam, Mic indicator)
              Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      label: 'Face Tracking',
                      icon: Icons.face,
                      isActive: controller.isCameraTracking,
                      onTap: controller.toggleCameraTracking,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildToggleButton(
                      label: 'Virtual Cam',
                      icon: Icons.videocam,
                      isActive: controller.isVirtualCameraActive,
                      onTap: controller.toggleVirtualCamera,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Avatar Catalog
              const Text(
                'Choose Avatar',
                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Obx(() {
                final allAvatars = [
                  ...avatarService.presetAvatars,
                  ...avatarService.userAvatars,
                ];

                return SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: allAvatars.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = allAvatars[index];
                      final isSelected = controller.currentAvatar?.id == item.id;

                      return InkWell(
                        onTap: () {
                          controller.selectAvatar(item);
                          avatarService.selectAvatar(item);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 80,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? ColorRes.themeColor.withOpacity(0.2) : Colors.white10,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? ColorRes.themeColor : Colors.white12,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white24,
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: Icon(
                                  item.type == AvatarType.gltf3D
                                      ? Icons.view_in_ar
                                      : item.type == AvatarType.aiPhoto
                                          ? Icons.camera_front
                                          : Icons.pets,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected ? ColorRes.themeColor : Colors.white,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? ColorRes.themeColor.withOpacity(0.2) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? ColorRes.themeColor : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isActive ? ColorRes.themeColor : Colors.white60),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


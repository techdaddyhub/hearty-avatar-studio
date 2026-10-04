import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/screen/desktop/sections/desktop_avatar_studio_section.dart';
import 'package:orange_ui/screen/desktop/sections/desktop_home_section.dart';
import 'package:orange_ui/screen/desktop/sections/desktop_live_stream_section.dart';
import 'package:orange_ui/screen/desktop/sections/desktop_media_section.dart';
import 'package:orange_ui/screen/desktop/sections/desktop_obs_studio_section.dart';
import 'package:orange_ui/screen/desktop/sections/desktop_recordings_section.dart';
import 'package:orange_ui/screen/desktop/sections/desktop_settings_section.dart';
import 'package:orange_ui/screen/desktop/sections/desktop_social_accounts_section.dart';
import 'package:orange_ui/screen/desktop/sections/desktop_video_calls_section.dart';
import 'package:orange_ui/screen/desktop/sections/desktop_virtual_camera_section.dart';
import 'package:orange_ui/screen/desktop/widgets/desktop_performance_hud.dart';
import 'package:orange_ui/service/avatar/avatar_manager_service.dart';
import 'package:orange_ui/service/avatar/voice_movement_sync_controller.dart';
import 'package:orange_ui/service/calls/livekit_call_service.dart';
import 'package:orange_ui/service/obs/obs_websocket_service.dart';
import 'package:orange_ui/service/virtual_camera/virtual_camera_service.dart';
import 'package:orange_ui/utils/color_res.dart';

class AvatarStudioDesktopApp extends StatefulWidget {
  const AvatarStudioDesktopApp({super.key});

  @override
  State<AvatarStudioDesktopApp> createState() => _AvatarStudioDesktopAppState();
}

class _AvatarStudioDesktopAppState extends State<AvatarStudioDesktopApp> {
  int _currentSectionIndex = 0;
  late final VoiceMovementSyncController _syncController;

  final List<Map<String, dynamic>> _navigationItems = [
    {'title': 'HOME', 'icon': Icons.home_filled},
    {'title': 'AVATAR STUDIO', 'icon': Icons.auto_awesome},
    {'title': 'VIDEO CALLS', 'icon': Icons.video_call},
    {'title': 'LIVE STREAM', 'icon': Icons.sensors},
    {'title': 'SOCIAL ACCOUNTS', 'icon': Icons.hub},
    {'title': 'OBS STUDIO', 'icon': Icons.cast_connected},
    {'title': 'VIRTUAL CAMERA', 'icon': Icons.videocam},
    {'title': 'RECORDINGS', 'icon': Icons.video_library},
    {'title': 'MEDIA', 'icon': Icons.perm_media},
    {'title': 'SETTINGS', 'icon': Icons.settings},
  ];

  @override
  void initState() {
    super.initState();
    _syncController = VoiceMovementSyncController();
    Get.put(_syncController);
    Get.put(AvatarManagerService());
    Get.put(ObsWebSocketService());
    Get.put(VirtualCameraService());
    Get.put(LiveKitCallService());
  }

  @override
  void dispose() {
    _syncController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090B12),
      body: Row(
        children: [
          // Left Workstation Sidebar
          Container(
            width: 240,
            decoration: const BoxDecoration(
              color: Color(0xFF0E111C),
              border: Border(right: BorderSide(color: Color(0xFF1E2336), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Branding Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF7A00), Color(0xFFFF0055)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: ColorRes.themeColor.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.bolt, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AVATAR STUDIO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'PRO EDITION',
                            style: TextStyle(
                              color: ColorRes.themeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF1E2336), height: 1),
                const SizedBox(height: 12),

                // Navigation Items
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _navigationItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final item = _navigationItems[index];
                      final isSelected = _currentSectionIndex == index;

                      return InkWell(
                        onTap: () => setState(() => _currentSectionIndex = index),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? ColorRes.themeColor.withOpacity(0.18) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? ColorRes.themeColor.withOpacity(0.4) : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                size: 18,
                                color: isSelected ? ColorRes.themeColor : Colors.white60,
                              ),
                              const SizedBox(width: 14),
                              Text(
                                item['title'] as String,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom User Profile Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF090B12),
                    border: Border(top: BorderSide(color: Color(0xFF1E2336), width: 1)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: ColorRes.themeColor.withOpacity(0.2),
                        child: const Icon(Icons.person, color: ColorRes.themeColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Creator Studio',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Hardware Accelerated',
                              style: TextStyle(color: Color(0xFF00E676), fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right Workspace Content Area
          Expanded(
            child: Column(
              children: [
                // Top Performance HUD Bar
                DesktopPerformanceHud(
                  controller: _syncController,
                  onStartCall: () => setState(() => _currentSectionIndex = 2), // VIDEO CALLS
                  onStartStream: () => setState(() => _currentSectionIndex = 3), // LIVE STREAM
                ),

                // Active Section View
                Expanded(
                  child: _buildSectionContent(_currentSectionIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(int index) {
    switch (index) {
      case 0:
        return DesktopHomeSection(
          controller: _syncController,
          onNavigate: (i) => setState(() => _currentSectionIndex = i),
        );
      case 1:
        return DesktopAvatarStudioSection(controller: _syncController);
      case 2:
        return DesktopVideoCallsSection(controller: _syncController);
      case 3:
        return DesktopLiveStreamSection(controller: _syncController);
      case 4:
        return const DesktopSocialAccountsSection();
      case 5:
        return const DesktopObsStudioSection();
      case 6:
        return DesktopVirtualCameraSection(controller: _syncController);
      case 7:
        return const DesktopRecordingsSection();
      case 8:
        return const DesktopMediaSection();
      case 9:
        return DesktopSettingsSection(controller: _syncController);
      default:
        return DesktopHomeSection(
          controller: _syncController,
          onNavigate: (i) => setState(() => _currentSectionIndex = i),
        );
    }
  }
}

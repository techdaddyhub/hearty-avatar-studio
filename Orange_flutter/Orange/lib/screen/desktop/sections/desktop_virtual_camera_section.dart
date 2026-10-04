import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/screen/random_streming_screen/widgets/avatar/live_avatar_sync_widget.dart';
import 'package:orange_ui/service/avatar/voice_movement_sync_controller.dart';
import 'package:orange_ui/service/virtual_camera/virtual_camera_service.dart';
import 'package:orange_ui/utils/color_res.dart';

class DesktopVirtualCameraSection extends StatelessWidget {
  final VoiceMovementSyncController controller;

  const DesktopVirtualCameraSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final vcamService = Get.isRegistered<VirtualCameraService>()
        ? Get.find<VirtualCameraService>()
        : Get.put(VirtualCameraService());

    return Row(
      children: [
        // Left Column: Device Driver Controls & Specs
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SYSTEM VIRTUAL CAMERA DRIVER',
                  style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Output Avatar directly to Zoom, Teams, Meet & Discord',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Exposes the avatar as a native hardware-recognized camera device without requiring window capture or screen recording.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 28),

                // Device Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131726),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF22283E)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Obx(() {
                                final isLive = vcamService.status.value == VirtualCameraStatus.streaming;
                                return Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: isLive ? const Color(0xFF00E676) : Colors.orangeAccent,
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() => Text(
                                        vcamService.deviceName.value,
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      )),
                                  Text(
                                    vcamService.platformDriver,
                                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Obx(() {
                            final isLive = vcamService.status.value == VirtualCameraStatus.streaming;
                            return ElevatedButton.icon(
                              onPressed: vcamService.toggleVirtualCamera,
                              icon: Icon(isLive ? Icons.videocam_off : Icons.videocam, size: 18),
                              label: Text(isLive ? 'Stop Virtual Cam' : 'Start Virtual Cam'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isLive ? Colors.redAccent : ColorRes.themeColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Format & FPS settings
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => DropdownButtonFormField<String>(
                                  value: vcamService.availableResolutions.first,
                                  dropdownColor: const Color(0xFF1B2034),
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  decoration: InputDecoration(
                                    labelText: 'Resolution Format',
                                    labelStyle: const TextStyle(color: Colors.white54),
                                    filled: true,
                                    fillColor: const Color(0xFF1B2034),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  ),
                                  items: vcamService.availableResolutions.map((res) {
                                    return DropdownMenuItem(value: res, child: Text(res));
                                  }).toList(),
                                  onChanged: (val) {},
                                )),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() => DropdownButtonFormField<int>(
                                  value: vcamService.targetFps.value,
                                  dropdownColor: const Color(0xFF1B2034),
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  decoration: InputDecoration(
                                    labelText: 'Target Frame Rate',
                                    labelStyle: const TextStyle(color: Colors.white54),
                                    filled: true,
                                    fillColor: const Color(0xFF1B2034),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  ),
                                  items: vcamService.availableFps.map((fps) {
                                    return DropdownMenuItem(value: fps, child: Text('$fps FPS (Hardware Sync)'));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) vcamService.targetFps.value = val;
                                  },
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Platform Integration Instructions
                const Text(
                  'COMPATIBLE APPLICATIONS',
                  style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                const SizedBox(height: 12),

                _buildAppIntegrationTile(
                  name: 'OBS Studio',
                  instruction: 'Add Video Capture Device -> "Avatar Studio Camera". Direct 1080p60 texture.',
                  icon: Icons.cast_connected,
                ),
                const SizedBox(height: 8),
                _buildAppIntegrationTile(
                  name: 'Zoom Video Communications',
                  instruction: 'Settings -> Video -> Camera -> Select "Avatar Studio Camera". HD enabled.',
                  icon: Icons.video_call,
                ),
                const SizedBox(height: 8),
                _buildAppIntegrationTile(
                  name: 'Google Meet',
                  instruction: 'More options (...) -> Settings -> Video -> Select "Avatar Studio Camera".',
                  icon: Icons.meeting_room,
                ),
                const SizedBox(height: 8),
                _buildAppIntegrationTile(
                  name: 'Discord / MS Teams',
                  instruction: 'User Settings -> Voice & Video -> Camera -> Select "Avatar Studio Camera".',
                  icon: Icons.forum,
                ),
              ],
            ),
          ),
        ),

        // Right Column: Live Driver Feed Preview
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.only(top: 28, right: 28, bottom: 28),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0E17),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF22283E)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LiveAvatarSyncWidget(
                    controller: controller,
                    showStats: false,
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Obx(() {
                            final isLive = vcamService.status.value == VirtualCameraStatus.streaming;
                            return Text(
                              isLive ? '🔴 DRIVER ACTIVE: "Avatar Studio Camera"' : '⚪ VCAM STANDBY',
                              style: TextStyle(
                                color: isLive ? Colors.redAccent : Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppIntegrationTile({
    required String name,
    required String instruction,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131726),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF22283E)),
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorRes.themeColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                Text(instruction, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_outline, color: Color(0xFF00E676), size: 18),
        ],
      ),
    );
  }
}

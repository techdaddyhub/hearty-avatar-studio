import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/model/avatar/live_avatar_model.dart';
import 'package:orange_ui/service/avatar/avatar_manager_service.dart';
import 'package:orange_ui/service/avatar/voice_movement_sync_controller.dart';
import 'package:orange_ui/utils/color_res.dart';

class DesktopHomeSection extends StatelessWidget {
  final VoiceMovementSyncController controller;
  final Function(int) onNavigate;

  const DesktopHomeSection({
    super.key,
    required this.controller,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final avatarService = Get.isRegistered<AvatarManagerService>()
        ? Get.find<AvatarManagerService>()
        : Get.put(AvatarManagerService());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2640), Color(0xFF121526)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2C3558)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ColorRes.themeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PROFESSIONAL AVATAR WORKSTATION',
                          style: TextStyle(
                            color: ColorRes.themeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'AI Avatar Studio & Live Streaming',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Control hyper-expressive 2D, 3D, and AI photorealistic avatars with real-time lip-sync, zero-latency virtual camera output, and multi-platform social broadcasting.',
                        style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => onNavigate(1), // AVATAR STUDIO
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: const Text('Open Avatar Studio'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorRes.themeColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          OutlinedButton.icon(
                            onPressed: () => onNavigate(3), // LIVE STREAM
                            icon: const Icon(Icons.sensors, size: 18),
                            label: const Text('Broadcast Setup'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderBorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Active Avatar Preview Card
                Obx(() {
                  final active = avatarService.selectedAvatar.value ?? LiveAvatarModel.defaultPresets.first;
                  return Container(
                    width: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141829),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2E385C)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFFFF7A00), Color(0xFF5A1C00)],
                            ),
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: const Icon(Icons.face, size: 44, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          active.name,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          active.type.name.toUpperCase(),
                          style: const TextStyle(color: ColorRes.themeColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => onNavigate(1),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              foregroundColor: Colors.white70,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Change Avatar', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Core Workflow Modules Grid
          const Text(
            'STUDIO MODULES',
            style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.1,
            children: [
              _buildFeatureCard(
                title: 'Live Video Calls',
                desc: 'Call friends with your animated avatar via LiveKit SFU',
                icon: Icons.video_call,
                color: const Color(0xFF2979FF),
                onTap: () => onNavigate(2),
              ),
              _buildFeatureCard(
                title: 'Multi-Destination Live',
                desc: 'Simulcast to YouTube, Facebook, TikTok, & RTMP',
                icon: Icons.cell_tower,
                color: const Color(0xFFFF1744),
                onTap: () => onNavigate(3),
              ),
              _buildFeatureCard(
                title: 'OBS Studio Integration',
                desc: 'Direct WebSocket 5.x scene and source automation',
                icon: Icons.cast_connected,
                color: const Color(0xFF00E676),
                onTap: () => onNavigate(5),
              ),
              _buildFeatureCard(
                title: 'Virtual Camera Driver',
                desc: 'Zero-copy direct video source for Zoom & Meet',
                icon: Icons.videocam,
                color: const Color(0xFFFF9100),
                onTap: () => onNavigate(6),
              ),
              _buildFeatureCard(
                title: 'Social Accounts',
                desc: 'Secure OAuth2 streaming channels and tokens',
                icon: Icons.hub,
                color: const Color(0xFFAA00FF),
                onTap: () => onNavigate(4),
              ),
              _buildFeatureCard(
                title: 'Session Recordings',
                desc: 'Archive studio sessions, calls, and streams locally',
                icon: Icons.video_library,
                color: const Color(0xFF00B0FF),
                onTap: () => onNavigate(7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF131726),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF22283E)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

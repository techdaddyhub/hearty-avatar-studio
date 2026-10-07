import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/screen/contacts/widgets/user_qr_card_sheet.dart';
import 'package:orange_ui/screen/live_grid_screen/live_grid_screen.dart';
import 'package:orange_ui/screen/mini_program/mini_program_list_screen.dart';
import 'package:orange_ui/screen/moments/moments_screen.dart';
import 'package:orange_ui/utils/color_res.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        title: const Text(
          'Discover',
          style: TextStyle(color: Color(0xFF191919), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFFEDEDED),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // Section 1: Moments (朋友圈)
          _buildDiscoverGroup([
            _buildDiscoverTile(
              icon: Icons.camera_rounded,
              iconColor: const Color(0xFF10AEFF),
              title: 'Moments',
              subtitle: 'Encrypted Contact Feed',
              hasBadge: true,
              onTap: () => Get.to(() => const MomentsScreen()),
            ),
          ]),
          const SizedBox(height: 10),

          // Section 2: Scan QR & Card Exchange (扫一扫)
          _buildDiscoverGroup([
            _buildDiscoverTile(
              icon: Icons.qr_code_scanner,
              iconColor: const Color(0xFF07C160),
              title: 'Scan QR / Card Exchange',
              onTap: () => Get.to(() => const UserQrCardSheet()),
            ),
          ]),
          const SizedBox(height: 10),

          // Section 3: Live Streaming & Video Channels (直播)
          _buildDiscoverGroup([
            _buildDiscoverTile(
              icon: Icons.live_tv_rounded,
              iconColor: const Color(0xFFFA9D3B),
              title: 'Live Streams & Avatars',
              subtitle: 'Watch broadcasters & AI personas',
              onTap: () => Get.to(() => const LiveGridScreen()),
            ),
          ]),
          const SizedBox(height: 10),

          // Section 4: Mini-Programs (小程序)
          _buildDiscoverGroup([
            _buildDiscoverTile(
              icon: Icons.apps_rounded,
              iconColor: const Color(0xFF7B68EE),
              title: 'Mini-Programs',
              subtitle: 'Date Planner, Games, Widgets',
              onTap: () => Get.to(() => const MiniProgramListScreen()),
            ),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDiscoverGroup(List<Widget> children) {
    return Container(
      color: Colors.white,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDiscoverTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    bool hasBadge = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF191919),
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ),
            ),
            if (hasBadge)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

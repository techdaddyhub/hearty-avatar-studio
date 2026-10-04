import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/screen/random_streming_screen/widgets/avatar/live_avatar_sync_widget.dart';
import 'package:orange_ui/service/avatar/voice_movement_sync_controller.dart';
import 'package:orange_ui/service/calls/livekit_call_service.dart';
import 'package:orange_ui/utils/color_res.dart';

class DesktopVideoCallsSection extends StatelessWidget {
  final VoiceMovementSyncController controller;

  const DesktopVideoCallsSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final callService = Get.isRegistered<LiveKitCallService>()
        ? Get.find<LiveKitCallService>()
        : Get.put(LiveKitCallService());

    return Obx(() {
      final state = callService.callState.value;

      if (state == VideoCallState.active) {
        return _buildActiveCallRoom(context, callService);
      } else {
        return _buildCallDashboard(context, callService);
      }
    });
  }

  Widget _buildCallDashboard(BuildContext context, LiveKitCallService callService) {
    final roomIdController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AVATAR VIDEO CALLS (LIVEKIT SFU)',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect in 1-to-1 or group video calls with your animated avatar',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Quick Start Call Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF131726),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF22283E)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: roomIdController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter Room ID or User Identity...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.meeting_room, color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1B2034),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final target = roomIdController.text.trim().isEmpty ? 'Room_Alpha' : roomIdController.text.trim();
                    callService.startCall(
                      targetUserId: 2,
                      targetUserName: target,
                      avatar: controller.currentAvatar,
                    );
                  },
                  icon: const Icon(Icons.video_call, size: 20),
                  label: const Text('Start Avatar Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorRes.themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Recent Contacts
          const Text(
            'RECENT CALL CONTACTS',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 14),

          Expanded(
            child: ListView(
              children: [
                _buildContactTile(
                  name: 'Emma Watson',
                  status: 'Online • In Studio',
                  avatarKey: 'preset_anime_luna',
                  onCall: () => callService.startCall(
                    targetUserId: 101,
                    targetUserName: 'Emma Watson',
                    avatar: controller.currentAvatar,
                  ),
                ),
                _buildContactTile(
                  name: 'Lucas Vance (Director)',
                  status: 'Active on Desktop',
                  avatarKey: 'preset_cyber_fox',
                  onCall: () => callService.startCall(
                    targetUserId: 102,
                    targetUserName: 'Lucas Vance',
                    avatar: controller.currentAvatar,
                  ),
                ),
                _buildContactTile(
                  name: 'Studio Production Room',
                  status: 'Group Room • 3 Participants',
                  avatarKey: 'preset_ai_executive',
                  onCall: () => callService.startCall(
                    targetUserId: 103,
                    targetUserName: 'Studio Production Room',
                    avatar: controller.currentAvatar,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required String name,
    required String status,
    required String avatarKey,
    required VoidCallback onCall,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131726),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF22283E)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: ColorRes.themeColor.withOpacity(0.2),
            child: const Icon(Icons.person, color: ColorRes.themeColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text(status, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onCall,
            icon: const Icon(Icons.phone, size: 16),
            label: const Text('Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2979FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCallRoom(BuildContext context, LiveKitCallService callService) {
    final session = callService.activeSession.value;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Call Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF131726),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF22283E)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Connected: ${session?.remoteUserName ?? "Room"}',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Obx(() => Text(
                      'Quality: ${callService.networkQuality.value}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main Call Viewport (2-pane split: Local Avatar vs Remote Participant)
          Expanded(
            child: Row(
              children: [
                // Local Participant (Your animated avatar)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0E17),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2B3352)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          LiveAvatarSyncWidget(
                            controller: controller,
                            showStats: false,
                            allowInteractiveTracking: true,
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('You (AI Avatar)', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Remote Participant
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0E17),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF22283E)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: Colors.white12,
                            child: const Icon(Icons.person, size: 48, color: Colors.white60),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            session?.remoteUserName ?? 'Remote User',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'LiveKit WebRTC Stream Active (Audio/Video)',
                            style: TextStyle(color: Color(0xFF00E676), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // In-Call Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF131726),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF22283E)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mute
                Obx(() => _buildCallControlBtn(
                      icon: callService.isMuted.value ? Icons.mic_off : Icons.mic,
                      color: callService.isMuted.value ? Colors.redAccent : Colors.white24,
                      onTap: callService.toggleMute,
                    )),
                const SizedBox(width: 14),

                // Avatar Mode Toggle
                Obx(() => _buildCallControlBtn(
                      icon: Icons.face,
                      color: callService.isAvatarMode.value ? ColorRes.themeColor : Colors.white24,
                      onTap: callService.toggleAvatarMode,
                    )),
                const SizedBox(width: 14),

                // Speaker
                Obx(() => _buildCallControlBtn(
                      icon: callService.isSpeakerOn.value ? Icons.volume_up : Icons.volume_off,
                      color: Colors.white24,
                      onTap: callService.toggleSpeaker,
                    )),
                const SizedBox(width: 14),

                // Screen Share
                Obx(() => _buildCallControlBtn(
                      icon: Icons.screen_share,
                      color: callService.isScreenSharing.value ? Colors.blueAccent : Colors.white24,
                      onTap: callService.toggleScreenShare,
                    )),
                const SizedBox(width: 24),

                // End Call
                ElevatedButton.icon(
                  onPressed: callService.endCall,
                  icon: const Icon(Icons.call_end, size: 18),
                  label: const Text('End Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControlBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

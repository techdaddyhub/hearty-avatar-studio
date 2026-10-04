import 'package:flutter/material.dart';
import 'package:orange_ui/screen/random_streming_screen/widgets/avatar/live_avatar_sync_widget.dart';
import 'package:orange_ui/service/avatar/voice_movement_sync_controller.dart';
import 'package:orange_ui/utils/color_res.dart';

class DesktopLiveStreamSection extends StatefulWidget {
  final VoiceMovementSyncController controller;

  const DesktopLiveStreamSection({
    super.key,
    required this.controller,
  });

  @override
  State<DesktopLiveStreamSection> createState() => _DesktopLiveStreamSectionState();
}

class _DesktopLiveStreamSectionState extends State<DesktopLiveStreamSection> {
  bool _isBroadcasting = false;
  final TextEditingController _titleController = TextEditingController(text: 'Live AI Avatar Interactive Stream');
  final TextEditingController _rtmpUrlController = TextEditingController(text: 'rtmp://stream.antigravity.internal/live');
  final TextEditingController _streamKeyController = TextEditingController(text: 'live_user_avatar_77a92b');

  bool _destYoutube = true;
  bool _destFacebook = true;
  bool _destTiktok = false;
  bool _destCustom = false;

  int _viewers = 142;
  String _streamUptime = '00:14:28';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Column: Stream Configuration & Destinations
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MULTI-PLATFORM LIVE STREAMING',
                  style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Broadcast your avatar to all social platforms simultaneously',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Stream Title & Description
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Stream Broadcast Title',
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF131726),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),

                // Ingress URL & Key
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextField(
                        controller: _rtmpUrlController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'RTMP Ingress Gateway',
                          labelStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF131726),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _streamKeyController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Stream Key',
                          labelStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF131726),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Simulcast Destinations
                const Text(
                  'MULTI-STREAM DESTINATIONS',
                  style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                const SizedBox(height: 12),

                _buildDestinationCard(
                  platform: 'YouTube Live',
                  accountName: 'Antigravity Studio Official',
                  icon: Icons.play_circle_filled,
                  color: const Color(0xFFFF0000),
                  enabled: _destYoutube,
                  onChanged: (v) => setState(() => _destYoutube = v),
                ),
                const SizedBox(height: 10),
                _buildDestinationCard(
                  platform: 'Facebook Live',
                  accountName: 'Creator Page',
                  icon: Icons.facebook,
                  color: const Color(0xFF1877F2),
                  enabled: _destFacebook,
                  onChanged: (v) => setState(() => _destFacebook = v),
                ),
                const SizedBox(height: 10),
                _buildDestinationCard(
                  platform: 'TikTok Live',
                  accountName: '@avatar_studio_live',
                  icon: Icons.music_note,
                  color: const Color(0xFF00F2FE),
                  enabled: _destTiktok,
                  onChanged: (v) => setState(() => _destTiktok = v),
                ),
                const SizedBox(height: 10),
                _buildDestinationCard(
                  platform: 'Custom RTMP Server',
                  accountName: 'rtmp://custom.cdn.net/app',
                  icon: Icons.cloud_upload,
                  color: const Color(0xFF00E676),
                  enabled: _destCustom,
                  onChanged: (v) => setState(() => _destCustom = v),
                ),
                const SizedBox(height: 28),

                // Master Go Live Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isBroadcasting = !_isBroadcasting;
                      });
                    },
                    icon: Icon(_isBroadcasting ? Icons.stop_circle : Icons.sensors, size: 22),
                    label: Text(
                      _isBroadcasting ? 'STOP BROADCAST' : 'GO LIVE TO ALL DESTINATIONS',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isBroadcasting ? Colors.redAccent : const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right Column: Live Stream Monitor & Chat
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.only(top: 28, right: 28, bottom: 28),
            decoration: BoxDecoration(
              color: const Color(0xFF131726),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF22283E)),
            ),
            child: Column(
              children: [
                // Live Viewport Preview
                Container(
                  height: 280,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0C0E17),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        LiveAvatarSyncWidget(
                          controller: widget.controller,
                          showStats: false,
                        ),
                        Positioned(
                          top: 14,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isBroadcasting ? Colors.red : Colors.grey[800],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isBroadcasting ? 'LIVE ON AIR' : 'OFFLINE PREVIEW',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isBroadcasting)
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '👁️ $_viewers Viewers • $_streamUptime',
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Live Chat Console
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'COMBINED STREAM CHAT',
                          style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView(
                            children: const [
                              _ChatMessage('YouTube', 'TechLover', 'Your avatar lip-sync looks amazing! 60 FPS is buttery smooth.'),
                              _ChatMessage('Facebook', 'Sarah_Dev', 'Is this using the GPU directly? What virtual camera?'),
                              _ChatMessage('TikTok', 'AlexGamer', 'Cyber Fox is sick 🔥🔥🔥'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationCard({
    required String platform,
    required String accountName,
    required IconData icon,
    required Color color,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF181C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2B3352)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(platform, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                Text(accountName, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            activeColor: ColorRes.themeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final String platform;
  final String user;
  final String message;

  const _ChatMessage(this.platform, this.user, this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '[$platform] ',
              style: const TextStyle(color: ColorRes.themeColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '$user: ',
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: message,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

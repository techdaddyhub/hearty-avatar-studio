import 'package:flutter/material.dart';
import 'package:orange_ui/utils/color_res.dart';

class DesktopSocialAccountsSection extends StatefulWidget {
  const DesktopSocialAccountsSection({super.key});

  @override
  State<DesktopSocialAccountsSection> createState() => _DesktopSocialAccountsSectionState();
}

class _DesktopSocialAccountsSectionState extends State<DesktopSocialAccountsSection> {
  final List<Map<String, dynamic>> _accounts = [
    {
      'platform': 'YouTube',
      'channelName': 'Antigravity Studio',
      'channelHandle': '@antigravity_avatar',
      'icon': Icons.play_circle_filled,
      'color': const Color(0xFFFF0000),
      'isConnected': true,
      'scope': 'Broadcast Live, Read Chat',
    },
    {
      'platform': 'Facebook',
      'channelName': 'Avatar Live Gaming',
      'channelHandle': 'fb.com/avatar_live_game',
      'icon': Icons.facebook,
      'color': const Color(0xFF1877F2),
      'isConnected': true,
      'scope': 'Pages Live Video',
    },
    {
      'platform': 'TikTok',
      'channelName': 'VTuber Studio',
      'channelHandle': '@vtuber_studio_live',
      'icon': Icons.music_note,
      'color': const Color(0xFF00F2FE),
      'isConnected': false,
      'scope': 'Live Streaming Partner RTMP',
    },
    {
      'platform': 'Instagram',
      'channelName': 'Creator Avatar',
      'channelHandle': '@creator_avatar_official',
      'icon': Icons.camera_alt,
      'color': const Color(0xFFE1306C),
      'isConnected': false,
      'scope': 'Instagram Live Producer',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SOCIAL MEDIA ACCOUNTS & CHANNELS',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect accounts for authorized, zero-setup multi-streaming',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tokens are protected using hardware-backed AES-256 envelope encryption. Official platform OAuth2 APIs ensure compliance.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 28),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _accounts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = _accounts[index];
              final bool isConnected = item['isConnected'];

              return Container(
                padding: const EdgeInsets.all(20),
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
                        color: (item['color'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'], color: item['color'], size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item['platform'],
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isConnected ? const Color(0xFF00E676).withOpacity(0.15) : Colors.white10,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isConnected ? 'LINKED' : 'NOT CONNECTED',
                                  style: TextStyle(
                                    color: isConnected ? const Color(0xFF00E676) : Colors.white38,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isConnected ? '${item['channelName']} (${item['channelHandle']})' : 'Not linked to any channel yet',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Permissions: ${item['scope']}',
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          item['isConnected'] = !isConnected;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isConnected ? const Color(0xFF262C42) : ColorRes.themeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(isConnected ? 'Disconnect' : 'Connect Account'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

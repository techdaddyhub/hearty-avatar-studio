import 'package:flutter/material.dart';
import 'package:orange_ui/utils/color_res.dart';

class DesktopRecordingsSection extends StatelessWidget {
  const DesktopRecordingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final recordings = [
      {
        'title': 'Avatar Live Stream Session #42',
        'date': 'Oct 4, 2026 • 10:15 AM',
        'duration': '01:14:22',
        'resolution': '1080p60',
        'size': '2.4 GB',
        'type': 'Stream',
      },
      {
        'title': 'Video Call with Director Lucas',
        'date': 'Oct 3, 2026 • 04:30 PM',
        'duration': '00:24:10',
        'resolution': '1080p60',
        'size': '780 MB',
        'type': 'Call',
      },
      {
        'title': 'Studio Avatar Calibration & Lip-Sync Test',
        'date': 'Oct 2, 2026 • 02:18 PM',
        'duration': '00:08:45',
        'resolution': '1080p60',
        'size': '260 MB',
        'type': 'Studio',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SESSION RECORDINGS & EXPORTS',
                    style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Local Hardware-Encoded Video Library',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.folder_open, size: 18),
                label: const Text('Open Output Folder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B3352),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView.separated(
              itemCount: recordings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final rec = recordings[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131726),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF22283E)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 120,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C0E17),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Icon(Icons.play_circle_outline, size: 36, color: ColorRes.themeColor),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec['title']!,
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${rec['date']} • Duration: ${rec['duration']} • ${rec['resolution']} • ${rec['size']}',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.download, color: Colors.white70),
                        tooltip: 'Export MP4',
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.delete_outline, color: Colors.white38),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

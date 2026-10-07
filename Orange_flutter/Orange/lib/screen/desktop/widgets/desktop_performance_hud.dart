import 'package:flutter/material.dart';
import 'package:orange_ui/service/avatar/voice_movement_sync_controller.dart';
import 'package:orange_ui/utils/color_res.dart';

class DesktopPerformanceHud extends StatelessWidget {
  final VoiceMovementSyncController controller;
  final VoidCallback onStartCall;
  final VoidCallback onStartStream;

  const DesktopPerformanceHud({
    super.key,
    required this.controller,
    required this.onStartCall,
    required this.onStartStream,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final fps = controller.stats.fps.toStringAsFixed(0);
        final latency = controller.stats.latencyMs.toStringAsFixed(1);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF141721),
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: Row(
            children: [
              // Avatar Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: controller.isAvatarEnabled
                      ? ColorRes.themeColor.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: controller.isAvatarEnabled
                        ? ColorRes.themeColor
                        : Colors.white12,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.face,
                      size: 16,
                      color: controller.isAvatarEnabled
                          ? ColorRes.themeColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      controller.currentAvatar?.name ?? 'No Avatar',
                      style: TextStyle(
                        color: controller.isAvatarEnabled
                            ? Colors.white
                            : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Metrics Chips
              _buildMetricChip(
                icon: Icons.speed,
                label: '$fps FPS',
                color: controller.stats.fps > 25 ? Colors.greenAccent : Colors.orangeAccent,
              ),
              const SizedBox(width: 10),
              _buildMetricChip(
                icon: Icons.timer_outlined,
                label: '${latency}ms',
                color: Colors.cyanAccent,
              ),
              const SizedBox(width: 10),
              _buildStatusIndicator(
                label: 'MIC',
                isActive: controller.isMicActive,
              ),
              const SizedBox(width: 8),
              _buildStatusIndicator(
                label: 'CAM',
                isActive: controller.isCameraTracking,
              ),
              const SizedBox(width: 8),
              _buildStatusIndicator(
                label: 'VCAM',
                isActive: controller.isVirtualCameraActive,
              ),
              const SizedBox(width: 8),
              _buildStatusIndicator(
                label: 'OBS',
                isActive: controller.isObsConnected,
              ),

              const Spacer(),

              // Quick Action Buttons
              OutlinedButton.icon(
                onPressed: onStartCall,
                icon: const Icon(Icons.video_call, size: 16),
                label: const Text('Start Call', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: onStartStream,
                icon: const Icon(Icons.live_tv, size: 16),
                label: const Text('Go Live', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorRes.themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator({
    required String label,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.greenAccent.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? Colors.greenAccent : Colors.white12,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.greenAccent : Colors.grey,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

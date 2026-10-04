import 'package:flutter/material.dart';
import 'package:orange_ui/model/avatar/live_avatar_model.dart';
import 'package:orange_ui/screen/random_streming_screen/widgets/avatar/avatar_canvas_painter.dart';
import 'package:orange_ui/service/avatar/voice_movement_sync_controller.dart';

/// Full interactive Live Avatar Widget with physics rendering, expression HUD, and performance stats
class LiveAvatarSyncWidget extends StatefulWidget {
  final VoiceMovementSyncController controller;
  final bool showStats;
  final bool allowInteractiveTracking;

  const LiveAvatarSyncWidget({
    super.key,
    required this.controller,
    this.showStats = false,
    this.allowInteractiveTracking = true,
  });

  @override
  State<LiveAvatarSyncWidget> createState() => _LiveAvatarSyncWidgetState();
}

class _LiveAvatarSyncWidgetState extends State<LiveAvatarSyncWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final avatar = widget.controller.currentAvatar ?? LiveAvatarModel.defaultPresets.first;
        final pose = widget.controller.pose;
        final stats = widget.controller.stats;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Background ambient studio atmosphere
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.2),
                  radius: 1.2,
                  colors: [
                    Color(0xFF1E2640),
                    Color(0xFF0D111A),
                  ],
                ),
              ),
            ),

            // Interactive Gesture detector for head/gaze control
            GestureDetector(
              onPanUpdate: (details) {
                if (!widget.allowInteractiveTracking) return;
                final size = MediaQuery.of(context).size;
                final dx = ((details.localPosition.dx / size.width) - 0.5) * 2.0;
                final dy = ((details.localPosition.dy / size.height) - 0.5) * 2.0;
                widget.controller.updateFaceTracking(
                  yaw: dx,
                  pitch: dy,
                  roll: -dx * 0.25,
                  eyeGazeX: dx * 0.8,
                  eyeGazeY: dy * 0.8,
                );
              },
              onPanEnd: (_) {
                widget.controller.updateFaceTracking(
                  yaw: 0.0,
                  pitch: 0.0,
                  roll: 0.0,
                  eyeGazeX: 0.0,
                  eyeGazeY: 0.0,
                );
              },
              child: CustomPaint(
                painter: AvatarCanvasPainter(
                  pose: pose,
                  avatar: avatar,
                  isGlowing: true,
                ),
                size: Size.infinite,
              ),
            ),

            // Performance telemetry HUD
            if (widget.showStats)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00FF66),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${stats.fps.toStringAsFixed(0)} FPS',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${stats.latencyMs.toStringAsFixed(1)} ms',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CPU: ${stats.cpuPercent.toStringAsFixed(1)}% | GPU: ${stats.gpuPercent.toStringAsFixed(1)}%',
                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),

            // Floating quick expression trigger bar
            Positioned(
              bottom: 24,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildExpressionChip(ExpressionPreset.smile, '😊'),
                  const SizedBox(height: 8),
                  _buildExpressionChip(ExpressionPreset.laugh, '😂'),
                  const SizedBox(height: 8),
                  _buildExpressionChip(ExpressionPreset.surprised, '😲'),
                  const SizedBox(height: 8),
                  _buildExpressionChip(ExpressionPreset.wink, '😉'),
                  const SizedBox(height: 8),
                  _buildExpressionChip(ExpressionPreset.neutral, '😐'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpressionChip(ExpressionPreset preset, String emoji) {
    return InkWell(
      onTap: () => widget.controller.triggerExpression(preset),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

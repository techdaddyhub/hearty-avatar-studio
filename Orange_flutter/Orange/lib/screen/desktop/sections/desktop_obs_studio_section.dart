import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/service/obs/obs_websocket_service.dart';
import 'package:orange_ui/utils/color_res.dart';

class DesktopObsStudioSection extends StatefulWidget {
  const DesktopObsStudioSection({super.key});

  @override
  State<DesktopObsStudioSection> createState() => _DesktopObsStudioSectionState();
}

class _DesktopObsStudioSectionState extends State<DesktopObsStudioSection> {
  final TextEditingController _hostController = TextEditingController(text: '127.0.0.1');
  final TextEditingController _portController = TextEditingController(text: '4455');
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final obsService = Get.isRegistered<ObsWebSocketService>()
        ? Get.find<ObsWebSocketService>()
        : Get.put(ObsWebSocketService());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OBS STUDIO WEBSOCKET 5.X INTEGRATION',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 8),
          const Text(
            'Direct OBS Automation, Scene Management & Video Sources',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Stream and record directly through OBS Studio using hardware encoders (NVENC, AMF, QuickSync) with zero CPU screen capture overhead.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 28),

          // Connection Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF131726),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF22283E)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Obx(() {
                          final isConn = obsService.isConnected.value;
                          return Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isConn ? const Color(0xFF00E676) : Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                        const SizedBox(width: 12),
                        Obx(() => Text(
                              obsService.isConnected.value ? 'OBS WebSocket Connected (v5.x)' : 'OBS Disconnected',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                    Obx(() {
                      final isConn = obsService.isConnected.value;
                      return ElevatedButton.icon(
                        onPressed: () {
                          if (isConn) {
                            obsService.disconnect();
                          } else {
                            obsService.connect(
                              host: _hostController.text.trim(),
                              port: int.tryParse(_portController.text.trim()) ?? 4455,
                              password: _passwordController.text,
                            );
                          }
                        },
                        icon: Icon(isConn ? Icons.link_off : Icons.link, size: 18),
                        label: Text(isConn ? 'Disconnect OBS' : 'Connect to OBS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isConn ? const Color(0xFF2B3352) : ColorRes.themeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                // Host, Port, Password Inputs
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _hostController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Server Host / IP',
                          labelStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF1B2034),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _portController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Port (Default 4455)',
                          labelStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF1B2034),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Server Password (if enabled)',
                          labelStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF1B2034),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // OBS Broadcast Controls
          const Text(
            'BROADCAST CONTROLS',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              // Start/Stop Stream
              Expanded(
                child: Obx(() {
                  final isStreaming = obsService.isStreaming.value;
                  return _buildControlTile(
                    title: isStreaming ? 'STREAMING ACTIVE' : 'OBS STREAM IDLE',
                    actionLabel: isStreaming ? 'Stop OBS Stream' : 'Start OBS Stream',
                    icon: Icons.sensors,
                    isActive: isStreaming,
                    color: isStreaming ? Colors.redAccent : const Color(0xFF2E7D32),
                    onTap: obsService.toggleStream,
                  );
                }),
              ),
              const SizedBox(width: 16),

              // Start/Stop Record
              Expanded(
                child: Obx(() {
                  final isRec = obsService.isRecording.value;
                  return _buildControlTile(
                    title: isRec ? 'RECORDING IN PROGRESS' : 'OBS RECORDING IDLE',
                    actionLabel: isRec ? 'Stop Recording' : 'Start Recording',
                    icon: Icons.fiber_manual_record,
                    isActive: isRec,
                    color: isRec ? Colors.redAccent : const Color(0xFF1E88E5),
                    onTap: obsService.toggleRecord,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Scene Switcher
          const Text(
            'ACTIVE SCENE SELECTION',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 14),

          Obx(() {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: obsService.scenes.map((scene) {
                final isCurrent = obsService.currentScene.value == scene;
                return InkWell(
                  onTap: () => obsService.setScene(scene),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: isCurrent ? ColorRes.themeColor.withOpacity(0.2) : const Color(0xFF131726),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent ? ColorRes.themeColor : const Color(0xFF22283E),
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCurrent ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 16,
                          color: isCurrent ? ColorRes.themeColor : Colors.white38,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          scene,
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.white70,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 28),

          // Source Integration Guide
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF10131F),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1E2336)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: ColorRes.themeColor, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Recommended OBS Setup Workflow (Zero CPU Overhead)',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  '1. In OBS Studio, add a new "Video Capture Device" source.\n'
                  '2. Select "Avatar Studio Camera" from the device dropdown.\n'
                  '3. Set Resolution/FPS Type to "Custom" -> 1920x1080 @ 60 FPS.\n'
                  '4. The avatar frames stream directly through GPU shared memory with zero window-capture artifacting.',
                  style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlTile({
    required String title,
    required String actionLabel,
    required IconData icon,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
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
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(actionLabel, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isActive ? 'Stop' : 'Start'),
          ),
        ],
      ),
    );
  }
}

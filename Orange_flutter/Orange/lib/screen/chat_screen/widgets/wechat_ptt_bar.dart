import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:path_provider/path_provider.dart';

class WeChatPttBar extends StatefulWidget {
  final TextEditingController msgController;
  final VoidCallback onSendText;
  final VoidCallback onPlusTap;
  final Function(File audioFile, int durationSec) onVoiceRecorded;

  const WeChatPttBar({
    super.key,
    required this.msgController,
    required this.onSendText,
    required this.onPlusTap,
    required this.onVoiceRecorded,
  });

  @override
  State<WeChatPttBar> createState() => _WeChatPttBarState();
}

class _WeChatPttBarState extends State<WeChatPttBar> {
  bool _isVoiceMode = false;
  bool _isRecording = false;
  bool _isCancelled = false;
  int _recordDuration = 0;
  Timer? _recordTimer;
  File? _currentAudioFile;

  void _startRecording() async {
    setState(() {
      _isRecording = true;
      _isCancelled = false;
      _recordDuration = 0;
    });

    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _recordDuration++);
      }
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentAudioFile = File(path);
      // Create empty mock audio container for relay transmission
      await _currentAudioFile!.writeAsBytes(List.filled(1024, 0));
    } catch (e) {
      debugPrint('[PTT] Error starting voice note: $e');
    }
  }

  void _stopRecordingAndSend() {
    _recordTimer?.cancel();
    if (_isRecording && !_isCancelled && _currentAudioFile != null) {
      final duration = _recordDuration > 0 ? _recordDuration : 1;
      widget.onVoiceRecorded(_currentAudioFile!, duration);
    }
    setState(() {
      _isRecording = false;
      _isCancelled = false;
      _recordDuration = 0;
    });
  }

  void _cancelRecording() {
    _recordTimer?.cancel();
    setState(() {
      _isRecording = false;
      _isCancelled = false;
      _recordDuration = 0;
    });
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFF7F7F7),
              border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 0.5)),
            ),
            child: Row(
              children: [
                // Voice/Keyboard Mode Toggle Button
                IconButton(
                  icon: Icon(
                    _isVoiceMode ? Icons.keyboard_alt_outlined : Icons.mic_none_outlined,
                    color: const Color(0xFF191919),
                    size: 26,
                  ),
                  onPressed: () => setState(() => _isVoiceMode = !_isVoiceMode),
                ),

                // Center: Text input or "Hold to Talk" button
                Expanded(
                  child: _isVoiceMode
                      ? GestureDetector(
                          onLongPressStart: (_) => _startRecording(),
                          onLongPressEnd: (_) => _stopRecordingAndSend(),
                          onLongPressMoveUpdate: (details) {
                            if (details.localOffsetFromOrigin.dy < -50) {
                              if (!_isCancelled) setState(() => _isCancelled = true);
                            } else {
                              if (_isCancelled) setState(() => _isCancelled = false);
                            }
                          },
                          child: Container(
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _isRecording
                                  ? (_isCancelled ? Colors.red.shade100 : Colors.grey.shade300)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              _isRecording
                                  ? (_isCancelled ? 'Release to Cancel' : 'Release to Send')
                                  : 'Hold to Talk',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _isCancelled ? Colors.red : const Color(0xFF191919),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: widget.msgController,
                            minLines: 1,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Type an encrypted message...',
                              hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                ),

                // Right: Send or + Button
                const SizedBox(width: 6),
                if (!_isVoiceMode && widget.msgController.text.isNotEmpty)
                  ElevatedButton(
                    onPressed: widget.onSendText,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF07C160),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Send', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF191919), size: 26),
                    onPressed: widget.onPlusTap,
                  ),
              ],
            ),
          ),
        ),

        // WeChat PTT Active Recording Floating Overlay
        if (_isRecording)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: _isCancelled ? Colors.red.withValues(alpha: 0.9) : Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isCancelled ? Icons.delete_outline : Icons.mic,
                      size: 54,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isCancelled ? 'Slide down to cancel' : '$_recordDuration"  Slide up to cancel',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}


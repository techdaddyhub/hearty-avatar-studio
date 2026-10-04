import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/model/avatar/live_avatar_model.dart';
import 'package:orange_ui/screen/random_streming_screen/widgets/avatar/live_avatar_sync_widget.dart';
import 'package:orange_ui/service/avatar/avatar_manager_service.dart';
import 'package:orange_ui/service/avatar/voice_movement_sync_controller.dart';
import 'package:orange_ui/utils/color_res.dart';

class DesktopAvatarStudioSection extends StatefulWidget {
  final VoiceMovementSyncController controller;

  const DesktopAvatarStudioSection({
    super.key,
    required this.controller,
  });

  @override
  State<DesktopAvatarStudioSection> createState() => _DesktopAvatarStudioSectionState();
}

class _DesktopAvatarStudioSectionState extends State<DesktopAvatarStudioSection> {
  double _headPitchSlider = 0.0;
  double _headYawSlider = 0.0;
  double _micGainSlider = 1.0;

  @override
  Widget build(BuildContext context) {
    final avatarService = Get.isRegistered<AvatarManagerService>()
        ? Get.find<AvatarManagerService>()
        : Get.put(AvatarManagerService());

    return Row(
      children: [
        // Center: Large Real-Time Avatar Canvas Viewport
        Expanded(
          flex: 7,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0E17),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF22283E), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Main real-time avatar viewport
                  LiveAvatarSyncWidget(
                    controller: widget.controller,
                    showStats: true,
                    allowInteractiveTracking: true,
                  ),

                  // Viewport Header Overlay
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
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
                          const SizedBox(width: 8),
                          const Text(
                            'LIVE GPU PIPELINE: 60 FPS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Interactive Drag Hint
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '💡 Click & drag canvas to test head yaw/pitch and eye gaze tracking',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Right Inspector Panel: Avatar Catalog & Rig Tuning
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.only(top: 20, right: 20, bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF131726),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF22283E)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AVATAR SELECTOR',
                    style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 12),

                  // Avatar Catalog List
                  Obx(() {
                    final allAvatars = [
                      ...avatarService.presetAvatars,
                      ...avatarService.userAvatars,
                    ];

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allAvatars.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final avatar = allAvatars[index];
                        final isSelected = widget.controller.currentAvatar?.id == avatar.id;

                        return InkWell(
                          onTap: () {
                            widget.controller.selectAvatar(avatar);
                            avatarService.selectAvatar(avatar);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? ColorRes.themeColor.withOpacity(0.18) : const Color(0xFF1B2034),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? ColorRes.themeColor : const Color(0xFF2B3352),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white12,
                                    border: Border.all(color: isSelected ? ColorRes.themeColor : Colors.white24),
                                  ),
                                  child: Icon(
                                    avatar.type == AvatarType.gltf3D
                                        ? Icons.view_in_ar
                                        : avatar.type == AvatarType.aiPhoto
                                            ? Icons.camera_front
                                            : Icons.pets,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        avatar.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        avatar.type.name.toUpperCase(),
                                        style: TextStyle(
                                          color: isSelected ? ColorRes.themeColor : Colors.white38,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: ColorRes.themeColor, size: 18),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 14),

                  // Upload Custom Avatar Button
                  OutlinedButton.icon(
                    onPressed: () => _showUploadDialog(context, avatarService),
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('Upload Avatar (3D GLB / Photo)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Divider(color: Color(0xFF22283E)),
                  const SizedBox(height: 12),

                  const Text(
                    'FACIAL EXPRESSIONS',
                    style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildExpressionBtn('Smile 😊', ExpressionPreset.smile),
                      _buildExpressionBtn('Laugh 😂', ExpressionPreset.laugh),
                      _buildExpressionBtn('Surprise 😲', ExpressionPreset.surprised),
                      _buildExpressionBtn('Sad 😢', ExpressionPreset.sad),
                      _buildExpressionBtn('Angry 😠', ExpressionPreset.angry),
                      _buildExpressionBtn('Wink 😉', ExpressionPreset.wink),
                      _buildExpressionBtn('Neutral 😐', ExpressionPreset.neutral),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Divider(color: Color(0xFF22283E)),
                  const SizedBox(height: 12),

                  const Text(
                    'PHYSICS & MOTION TUNING',
                    style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 12),

                  // Head Yaw
                  _buildSlider(
                    label: 'Head Yaw',
                    value: _headYawSlider,
                    min: -0.8,
                    max: 0.8,
                    onChanged: (val) {
                      setState(() => _headYawSlider = val);
                      widget.controller.updateFaceTracking(
                        yaw: val,
                        pitch: _headPitchSlider,
                        roll: 0.0,
                      );
                    },
                  ),

                  // Head Pitch
                  _buildSlider(
                    label: 'Head Pitch',
                    value: _headPitchSlider,
                    min: -0.6,
                    max: 0.6,
                    onChanged: (val) {
                      setState(() => _headPitchSlider = val);
                      widget.controller.updateFaceTracking(
                        yaw: _headYawSlider,
                        pitch: val,
                        roll: 0.0,
                      );
                    },
                  ),

                  // Mic Lip-Sync Gain
                  _buildSlider(
                    label: 'Lip-Sync Sensitivity',
                    value: _micGainSlider,
                    min: 0.2,
                    max: 2.0,
                    onChanged: (val) {
                      setState(() => _micGainSlider = val);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpressionBtn(String label, ExpressionPreset preset) {
    return InkWell(
      onTap: () => widget.controller.triggerExpression(preset),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2034),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2B3352)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(value.toStringAsFixed(2), style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: ColorRes.themeColor,
            inactiveTrackColor: Colors.white12,
            thumbColor: ColorRes.themeColor,
            overlayColor: ColorRes.themeColor.withOpacity(0.2),
            trackHeight: 3,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _showUploadDialog(BuildContext context, AvatarManagerService service) {
    final nameController = TextEditingController();
    AvatarType selectedType = AvatarType.custom2D;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF161A2B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Custom Avatar', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Avatar Name',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ColorRes.themeColor)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Format Type', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 8),
              DropdownButton<AvatarType>(
                value: selectedType,
                dropdownColor: const Color(0xFF1E243A),
                isExpanded: true,
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: AvatarType.custom2D, child: Text('2D Vector / Sprite Canvas')),
                  DropdownMenuItem(value: AvatarType.gltf3D, child: Text('3D Humanoid (GLB / GLTF)')),
                  DropdownMenuItem(value: AvatarType.aiPhoto, child: Text('AI Photo Neural Mesh')),
                  DropdownMenuItem(value: AvatarType.vrmHumanoid, child: Text('VRM VTuber Model')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedType = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim().isEmpty ? 'Custom Avatar' : nameController.text.trim();
                service.saveCustomAvatar(name: name, type: selectedType);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: ColorRes.themeColor),
              child: const Text('Import Avatar'),
            ),
          ],
        ),
      ),
    );
  }
}

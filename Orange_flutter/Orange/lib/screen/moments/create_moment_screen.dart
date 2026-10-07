import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orange_ui/screen/contacts/contacts_screen_view_model.dart';
import 'package:orange_ui/screen/moments/moments_screen_view_model.dart';
import 'package:orange_ui/service/gateway/realtime_relay_client.dart';
import 'package:orange_ui/utils/color_res.dart';

class CreateMomentScreen extends StatefulWidget {
  final MomentsScreenViewModel viewModel;

  const CreateMomentScreen({super.key, required this.viewModel});

  @override
  State<CreateMomentScreen> createState() => _CreateMomentScreenState();
}

class _CreateMomentScreenState extends State<CreateMomentScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        for (final xf in picked) {
          if (_selectedImages.length < 9) {
            _selectedImages.add(File(xf.path));
          }
        }
      });
    }
  }

  Future<void> _publish() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something or attach photos')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Upload encrypted blobs for any selected images
      final uploadedUrls = <String>[];
      for (final imageFile in _selectedImages) {
        final blobUrl = await RealtimeRelayClient.shared.uploadEncryptedBlob(imageFile, 'image/jpeg');
        if (blobUrl != null) {
          uploadedUrls.add(blobUrl);
        }
      }

      // 2. Fetch contact friend IDs for key envelope distribution
      final contactsVm = ContactsScreenViewModel();
      await contactsVm.fetchContacts();
      final friendIds = contactsVm.allContacts.map((c) => c.contactUserId).toList();

      // 3. Encrypt & publish
      final ok = await widget.viewModel.publishMoment(
        text: text,
        mediaUrls: uploadedUrls,
        friendIds: friendIds,
      );

      if (mounted) {
        setState(() => _isUploading = false);
        if (ok) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Moment posted (End-to-End Encrypted)!'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to publish moment'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.black87, fontSize: 16)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: _isUploading ? null : _publish,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07C160), // WeChat Green
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: _isUploading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Text Input
          TextField(
            controller: _textController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Share what\'s on your mind...',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 16),

          // Photo Selector Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedImages.length < 9 ? _selectedImages.length + 1 : 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              if (index == _selectedImages.length && _selectedImages.length < 9) {
                return InkWell(
                  onTap: _pickImages,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Icon(Icons.add_photo_alternate_outlined, size: 36, color: Colors.grey),
                    ),
                  ),
                );
              }

              final file = _selectedImages[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(file, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImages.removeAt(index)),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Privacy Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.shield_outlined, color: Colors.green, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Client-side encrypted. Only mutual contacts can decrypt and view this Moment.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


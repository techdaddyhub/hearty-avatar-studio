import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/model/chat_and_live_stream/chat.dart';
import 'package:orange_ui/screen/chat_screen/chat_screen.dart';
import 'package:orange_ui/screen/contacts/contacts_screen_view_model.dart';
import 'package:orange_ui/utils/color_res.dart';

class ContactDetailScreen extends StatefulWidget {
  final ContactItem contact;
  final ContactsScreenViewModel viewModel;

  const ContactDetailScreen({
    super.key,
    required this.contact,
    required this.viewModel,
  });

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late String _currentRemark;

  @override
  void initState() {
    super.initState();
    _currentRemark = widget.contact.remark ?? '';
  }

  void _showEditRemarkDialog() {
    final controller = TextEditingController(text: _currentRemark);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Remark / Alias'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Remark Name',
              hintText: 'e.g. Best Friend, Partner',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newRemark = controller.text.trim();
                Navigator.pop(context);
                final ok = await widget.viewModel.updateRemark(widget.contact.id, newRemark);
                if (ok && mounted) {
                  setState(() => _currentRemark = newRemark);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Remark updated successfully')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: ColorRes.themeColor),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Contact'),
          content: Text('Are you sure you want to remove ${widget.contact.displayName} from your WeChat contacts?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final ok = await widget.viewModel.deleteContact(widget.contact.id);
                if (ok && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact removed')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.contact;
    final displayName = _currentRemark.isNotEmpty ? _currentRemark : contact.fullName;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onSelected: (val) {
              if (val == 'remark') _showEditRemarkDialog();
              if (val == 'delete') _showDeleteConfirm();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'remark', child: Text('Edit Remark')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Contact', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          // Header Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: ColorRes.themeColor.withValues(alpha: 0.2),
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 28, color: ColorRes.themeColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF191919)),
                      ),
                      if (_currentRemark.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Name: ${contact.fullName}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'WeChat ID: ${contact.contactUserId}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Remark & Tags Setting
          Container(
            color: Colors.white,
            child: ListTile(
              title: const Text('Remark & Tags', style: TextStyle(fontSize: 16)),
              subtitle: _currentRemark.isNotEmpty ? Text(_currentRemark) : null,
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: _showEditRemarkDialog,
            ),
          ),
          const SizedBox(height: 12),

          // Privacy & E2EE Info
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: Colors.green, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Double Ratchet End-to-End Encrypted', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      SizedBox(height: 2),
                      Text('Messages and calls are secured with X25519 & AES-256', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons (Send Message, Call)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final convId = 'e2ee_${widget.contact.contactUserId}';
                      final conv = Conversation(
                        user: ChatUser(
                          userid: widget.contact.contactUserId,
                          username: widget.contact.displayName,
                          image: widget.contact.profileImage,
                        ),
                        conversationId: convId,
                      );
                      Get.to(() => ChatScreen(conversation: conv));
                    },
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                    label: const Text('Send Encrypted Message', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF07C160), // WeChat Green
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Starting Secure Audio/Video Call...')),
                      );
                    },
                    icon: const Icon(Icons.videocam_outlined, color: ColorRes.themeColor, size: 20),
                    label: const Text('Audio / Video Call', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ColorRes.themeColor)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: ColorRes.themeColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
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

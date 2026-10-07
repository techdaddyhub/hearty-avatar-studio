import 'package:flutter/material.dart';
import 'package:orange_ui/screen/contacts/contacts_screen_view_model.dart';
import 'package:orange_ui/utils/color_res.dart';

class NewFriendsSheet extends StatefulWidget {
  final ContactsScreenViewModel viewModel;

  const NewFriendsSheet({super.key, required this.viewModel});

  @override
  State<NewFriendsSheet> createState() => _NewFriendsSheetState();
}

class _NewFriendsSheetState extends State<NewFriendsSheet> {
  final TextEditingController _targetIdController = TextEditingController();
  final TextEditingController _greetingController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _targetIdController.dispose();
    _greetingController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Add Friend / Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _targetIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'User ID or Orange ID',
                  hintText: 'Enter numerical ID (e.g. 102)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _greetingController,
                decoration: InputDecoration(
                  labelText: 'Greeting Message',
                  hintText: "I'm connecting from Hearty!",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final targetId = int.tryParse(_targetIdController.text.trim());
                if (targetId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid User ID')),
                  );
                  return;
                }
                Navigator.pop(context);
                setState(() => _isSubmitting = true);
                final ok = await widget.viewModel.sendContactRequest(
                  targetId,
                  _greetingController.text.trim().isNotEmpty
                      ? _greetingController.text.trim()
                      : "Let's connect on WeChat E2EE!",
                );
                setState(() => _isSubmitting = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Friend request sent!' : 'User not found or already added'),
                      backgroundColor: ok ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: ColorRes.themeColor),
              child: const Text('Send Request', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = widget.viewModel.pendingRequests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Friends', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: ColorRes.themeColor),
            onPressed: _showAddDialog,
            tooltip: 'Add Friend by ID',
          ),
        ],
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No pending friend requests',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Contact by ID'),
                        style: ElevatedButton.styleFrom(backgroundColor: ColorRes.themeColor),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: ColorRes.themeColor.withValues(alpha: 0.2),
                        child: Text(
                          req.requesterName.isNotEmpty ? req.requesterName[0].toUpperCase() : '?',
                          style: const TextStyle(color: ColorRes.themeColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(req.requesterName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        req.greetingMessage ?? 'Requested to add you as contact',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        maxLines: 2,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => widget.viewModel.respondToRequest(req.id, 'decline'),
                            child: const Text('Decline', style: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () => widget.viewModel.respondToRequest(req.id, 'accept'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF07C160), // WeChat Green
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            child: const Text('Accept', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}


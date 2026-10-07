import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/screen/contacts/contact_detail_screen.dart';
import 'package:orange_ui/screen/contacts/contacts_screen_view_model.dart';
import 'package:orange_ui/screen/contacts/widgets/alphabet_scroll_bar.dart';
import 'package:orange_ui/screen/contacts/widgets/contact_tile.dart';
import 'package:orange_ui/screen/contacts/widgets/new_friends_sheet.dart';
import 'package:orange_ui/screen/contacts/widgets/user_qr_card_sheet.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:stacked/stacked.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ContactsScreenViewModel>.reactive(
      viewModelBuilder: () => ContactsScreenViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFEDEDED),
          appBar: AppBar(
            backgroundColor: const Color(0xFFEDEDED),
            elevation: 0,
            title: const Text(
              'Contacts',
              style: TextStyle(
                color: Color(0xFF191919),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_alt_1, color: Color(0xFF191919)),
                onPressed: () {
                  Get.to(() => NewFriendsSheet(viewModel: model));
                },
                tooltip: 'Add Friend',
              ),
            ],
          ),
          body: Column(
            children: [
              // Search Input
              Container(
                color: const Color(0xFFEDEDED),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    onChanged: model.onSearchChanged,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                      hintText: 'Search Contacts',
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 9),
                    ),
                  ),
                ),
              ),

              // Main List
              Expanded(
                child: model.isLoading
                    ? const Center(child: CircularProgressIndicator(color: ColorRes.themeColor))
                    : Stack(
                        children: [
                          CustomScrollView(
                            slivers: [
                              // Fixed Top Action Items
                              SliverToBoxAdapter(
                                child: Container(
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      _buildActionTile(
                                        icon: Icons.person_add_alt_1,
                                        iconBg: const Color(0xFFFA9D3B), // WeChat Orange
                                        title: 'New Friends',
                                        badgeCount: model.pendingRequests.length,
                                        onTap: () => Get.to(() => NewFriendsSheet(viewModel: model)),
                                      ),
                                      const Divider(height: 1, indent: 56),
                                      _buildActionTile(
                                        icon: Icons.qr_code,
                                        iconBg: const Color(0xFF10AEFF), // WeChat Blue
                                        title: 'My QR Namecard',
                                        onTap: () => Get.to(() => const UserQrCardSheet()),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Grouped Contacts
                              if (model.allContacts.isEmpty)
                                const SliverFillRemaining(
                                  child: Center(
                                    child: Text(
                                      'No contacts yet.\nTap + to add friends!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey, fontSize: 15),
                                    ),
                                  ),
                                )
                              else
                                ...model.alphabetKeys.map((letter) {
                                  final contactsInGroup = model.groupedContacts[letter] ?? [];
                                  return SliverMainAxisGroup(
                                    slivers: [
                                      SliverToBoxAdapter(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                          color: const Color(0xFFEDEDED),
                                          child: Text(
                                            letter,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (context, idx) {
                                            final contact = contactsInGroup[idx];
                                            return ContactTile(
                                              contact: contact,
                                              onTap: () => Get.to(() => ContactDetailScreen(
                                                contact: contact,
                                                viewModel: model,
                                              )),
                                            );
                                          },
                                          childCount: contactsInGroup.length,
                                        ),
                                      ),
                                    ],
                                  );
                                }),

                              // Bottom Contact Counter
                              if (model.allContacts.isNotEmpty)
                                SliverToBoxAdapter(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${model.allContacts.length} Contacts',
                                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // Alphabet Scrubber Bar on right edge
                          if (model.alphabetKeys.isNotEmpty)
                            Positioned(
                              top: 80,
                              right: 2,
                              bottom: 80,
                              child: AlphabetScrollBar(
                                alphabets: model.alphabetKeys,
                                onSelect: (letter) {
                                  // Scrub action
                                },
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconBg,
    required String title,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF191919),
                ),
              ),
            ),
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

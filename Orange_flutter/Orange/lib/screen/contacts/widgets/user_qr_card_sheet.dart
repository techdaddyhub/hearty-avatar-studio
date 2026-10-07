import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:orange_ui/service/crypto/e2ee_manager.dart';
import 'package:orange_ui/service/session_manager.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:share_plus/share_plus.dart';

class UserQrCardSheet extends StatelessWidget {
  const UserQrCardSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SessionManager.instance.getUser();
    final myUserId = SessionManager.instance.getUserID();
    final identityKey = E2EEManager.shared.identityPublicKeyBase64;
    final cardPayload = jsonEncode({
      'type': 'wechat_card',
      'user_id': myUserId,
      'name': user?.fullname ?? 'Hearty User',
      'identity_key': identityKey,
    });

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My QR Code Card', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              Share.share('Connect with me on Hearty WeChat E2EE! User ID: $myUserId\nIdentity: $identityKey');
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: ColorRes.themeColor.withValues(alpha: 0.2),
                    child: Text(
                      (user?.fullname != null && user!.fullname!.isNotEmpty)
                          ? user.fullname![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ColorRes.themeColor),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullname ?? 'Hearty User',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hearty ID: $myUserId',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Visual QR Card Matrix Container
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Matrix QR Pattern Simulation
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 15,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: 225,
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (context, index) {
                        final hash = (cardPayload.hashCode ^ (index * 31));
                        final isDark = (hash % 3 == 0) || (index % 14 == 0) || (index < 30 && index % 2 == 0);
                        return Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black : Colors.transparent,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        );
                      },
                    ),

                    // Central Badge
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.lock, color: ColorRes.themeColor, size: 24),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              const Text(
                'Scan QR code to add me to contacts',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Cryptographic Fingerprint
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Fingerprint: ${identityKey.length > 20 ? identityKey.substring(0, 20) : identityKey}...',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:orange_ui/screen/mini_program/mini_program_container_screen.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:orange_ui/utils/const_res.dart';
import 'package:orange_ui/utils/urls.dart';

class MiniProgramItem {
  final String appId;
  final String name;
  final String description;
  final String iconUrl;
  final String entryUrl;
  final String category;

  MiniProgramItem({
    required this.appId,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.entryUrl,
    required this.category,
  });

  factory MiniProgramItem.fromJson(Map<String, dynamic> json) {
    return MiniProgramItem(
      appId: json['app_id'] ?? 'app_${json['id']}',
      name: json['name'] ?? 'Mini Program',
      description: json['description'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      entryUrl: json['entry_url'] ?? '',
      category: json['category'] ?? 'Utility',
    );
  }
}

class MiniProgramListScreen extends StatefulWidget {
  const MiniProgramListScreen({super.key});

  @override
  State<MiniProgramListScreen> createState() => _MiniProgramListScreenState();
}

class _MiniProgramListScreenState extends State<MiniProgramListScreen> {
  List<MiniProgramItem> _programs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMiniPrograms();
  }

  Future<void> _fetchMiniPrograms() async {
    try {
      final response = await http.post(
        Uri.parse(Urls.miniProgramsList),
        headers: {Urls.apiKeyName: ConstRes.apiKey},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] is List) {
          final list = data['data'] as List;
          setState(() {
            _programs = list.map((e) => MiniProgramItem.fromJson(e as Map<String, dynamic>)).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      log('[MiniPrograms] Error fetching: $e');
    }

    // Default seeded programs if network offline
    setState(() {
      _programs = [
        MiniProgramItem(
          appId: 'hearty.date.planner',
          name: 'Date Planner',
          description: 'Curate romantic itineraries and interactive reservations.',
          iconUrl: '',
          entryUrl: 'about:blank',
          category: 'Lifestyle',
        ),
        MiniProgramItem(
          appId: 'hearty.games.icebreaker',
          name: 'Icebreaker Games',
          description: 'Fun multiplayer mini-games and questions for contacts.',
          iconUrl: '',
          entryUrl: 'about:blank',
          category: 'Games',
        ),
        MiniProgramItem(
          appId: 'hearty.horoscope.match',
          name: 'Horoscope Compatibility',
          description: 'Calculate astrological and personality harmony.',
          iconUrl: '',
          entryUrl: 'about:blank',
          category: 'Entertainment',
        ),
        MiniProgramItem(
          appId: 'hearty.gift.shop',
          name: 'Virtual Gift Shop',
          description: 'Send custom animated badges, gifts, and bouquets.',
          iconUrl: '',
          entryUrl: 'about:blank',
          category: 'Shopping',
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Mini-Programs', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ColorRes.themeColor))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                // Top Search / Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF07C160), Color(0xFF069A4C)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.apps, color: Colors.white, size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Sandboxed Super App Hub', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 2),
                            Text('Lightweight Web Apps running in OrangeBridge container', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text('Available Mini-Programs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF191919))),
                const SizedBox(height: 10),

                ..._programs.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF07C160).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.widgets_outlined, color: Color(0xFF07C160), size: 24),
                      ),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text(item.description, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 2),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Get.to(() => MiniProgramContainerScreen(
                            title: item.name,
                            appId: item.appId,
                            initialUrl: item.entryUrl,
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF07C160),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Open', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:orange_ui/utils/color_res.dart';

class DesktopMediaSection extends StatefulWidget {
  const DesktopMediaSection({super.key});

  @override
  State<DesktopMediaSection> createState() => _DesktopMediaSectionState();
}

class _DesktopMediaSectionState extends State<DesktopMediaSection> {
  int _selectedTab = 0;

  final List<Map<String, String>> _models = [
    {'name': 'Luna Star VTuber', 'format': 'VRM 1.0', 'size': '24.5 MB', 'date': '2026-10-01'},
    {'name': 'Cyber Fox Mecha', 'format': 'GLB Skeletal', 'size': '18.2 MB', 'date': '2026-09-28'},
    {'name': 'Nova Humanoid', 'format': 'VRM 0.x', 'size': '31.0 MB', 'date': '2026-09-25'},
    {'name': 'Nexus Executive AI', 'format': 'Neural Landmark Map', 'size': '12.4 MB', 'date': '2026-09-20'},
  ];

  final List<Map<String, String>> _backgrounds = [
    {'name': 'Cyberpunk Studio Neon', 'format': '1920x1080 WebP', 'size': '2.1 MB'},
    {'name': 'Modern Minimalist Loft', 'format': '3840x2160 PNG', 'size': '5.8 MB'},
    {'name': 'Abstract Dark Void', 'format': '1920x1080 MP4 Loop', 'size': '14.2 MB'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STUDIO MEDIA & ASSET VAULT',
                    style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '3D Models, Textures, Backgrounds & Viseme Mappings',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Import Media File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorRes.themeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tabs
          Row(
            children: [
              _buildTab('3D Models (GLB / VRM)', 0),
              const SizedBox(width: 12),
              _buildTab('Virtual Sets & Backgrounds', 1),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _selectedTab == 0 ? _buildModelsGrid() : _buildBackgroundsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ColorRes.themeColor.withOpacity(0.18) : const Color(0xFF131726),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? ColorRes.themeColor : const Color(0xFF22283E)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildModelsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.25,
      ),
      itemCount: _models.length,
      itemBuilder: (context, index) {
        final item = _models[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF131726),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF22283E)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorRes.themeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.view_in_ar, color: ColorRes.themeColor, size: 22),
                  ),
                  Text(item['size']!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
              const Spacer(),
              Text(item['name']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(item['format']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.6,
      ),
      itemCount: _backgrounds.length,
      itemBuilder: (context, index) {
        final bg = _backgrounds[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF131726),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF22283E)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C0E17),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.wallpaper, color: Colors.white24, size: 36),
                ),
              ),
              const Spacer(),
              Text(bg['name']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Text(bg['format']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/screen/moments/create_moment_screen.dart';
import 'package:orange_ui/screen/moments/moments_screen_view_model.dart';
import 'package:orange_ui/screen/moments/widgets/moment_post_card.dart';
import 'package:orange_ui/service/session_manager.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:stacked/stacked.dart';

class MomentsScreen extends StatelessWidget {
  const MomentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SessionManager.instance.getUser();

    return ViewModelBuilder<MomentsScreenViewModel>.reactive(
      viewModelBuilder: () => MomentsScreenViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: () => model.fetchFeed(),
            color: ColorRes.themeColor,
            child: CustomScrollView(
              slivers: [
                // Top Cover Sliver App Bar
                SliverAppBar(
                  expandedHeight: 260,
                  pinned: true,
                  backgroundColor: const Color(0xFF191919),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                      onPressed: () {
                        Get.to(() => CreateMomentScreen(viewModel: model));
                      },
                      tooltip: 'Post Moment',
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text('Moments', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Cover Graphic
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                            ),
                          ),
                          child: Center(
                            child: Icon(Icons.landscape, size: 80, color: Colors.white.withValues(alpha: 0.15)),
                          ),
                        ),

                        // User Name & Floating Avatar on Bottom Right
                        Positioned(
                          right: 16,
                          bottom: 12,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                user?.fullname ?? 'Me',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white, width: 2),
                                  color: ColorRes.themeColor,
                                ),
                                child: Center(
                                  child: Text(
                                    (user?.fullname != null && user!.fullname!.isNotEmpty)
                                        ? user.fullname![0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Moments List Body
                if (model.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: ColorRes.themeColor)),
                  )
                else if (model.moments.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'No Moments yet.\nShare your first encrypted moment!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => Get.to(() => CreateMomentScreen(viewModel: model)),
                            icon: const Icon(Icons.add_a_photo, size: 18),
                            label: const Text('Post Moment'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF07C160)),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final moment = model.moments[index];
                        return MomentPostCard(
                          moment: moment,
                          onLike: () => model.toggleLike(moment),
                        );
                      },
                      childCount: model.moments.length,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:orange_ui/common/hearty_logo.dart';
import 'package:orange_ui/screen/splash_screen/splash_screen_view_model.dart';
import 'package:stacked/stacked.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SplashScreenViewModel>.reactive(
      onViewModelReady: (viewModel) => viewModel.init(),
      viewModelBuilder: () => SplashScreenViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0B15),
          body: const Center(
            child: HeartyLogo(
              size: 140,
              showText: true,
              isDark: true,
            ),
          ),
        );
      },
    );
  }
}

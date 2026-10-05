import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:orange_ui/api_provider/api_provider.dart';
import 'package:orange_ui/model/setting_model.dart';
import 'package:orange_ui/model/user/registration_user.dart';
import 'package:orange_ui/screen/auth_screen/auth_screen.dart';
import 'package:orange_ui/screen/auth_screen/auth_screen_view_model.dart';
import 'package:orange_ui/screen/on_boarding_screen/on_boarding_screen.dart';
import 'package:orange_ui/service/session_manager.dart';
import 'package:stacked/stacked.dart';

class SplashScreenViewModel extends BaseViewModel {
  bool _hasNavigated = false;

  void init() {
    // Safety watchdog: guarantees navigation never hangs longer than 3.5 seconds
    Timer(const Duration(milliseconds: 3500), () {
      if (!_hasNavigated) {
        debugPrint('[Splash] Safety watchdog triggered navigation');
        _navigateNext(null);
      }
    });

    _startApp();
  }

  void _startApp() async {
    // Give user at least 1.5 seconds to appreciate the Hearty logo
    final minSplashDuration = Future.delayed(const Duration(milliseconds: 1500));

    SettingModel? setting;
    try {
      setting = await ApiProvider()
          .getSettingData()
          .timeout(const Duration(milliseconds: 2000), onTimeout: () {
        debugPrint('[Splash] getSettingData timed out');
        return SettingModel(status: false, message: 'Timeout');
      });
    } catch (e) {
      debugPrint('[Splash] getSettingData caught error: $e');
      setting = SettingModel(status: false, message: e.toString());
    }

    // Wait until minimum splash duration has elapsed
    await minSplashDuration;

    _navigateNext(setting);
  }

  void _navigateNext(SettingModel? setting) {
    if (_hasNavigated) return;
    _hasNavigated = true;

    try {
      bool isLogin =
          SessionManager.instance.getBool(key: SessionKeys.isLogin);

      if (isLogin) {
        fetchProfile();
      } else {
        final List<Onboarding> onBoardingItems =
            setting?.data?.onboardingScreen ?? [];
        bool isDating = setting?.data?.appdata?.isDating == 1;
        if (isDating && onBoardingItems.isNotEmpty) {
          Get.off(() => OnBoardingScreen(onBoarding: onBoardingItems));
        } else {
          Get.off(() => const AuthScreen());
        }
      }
    } catch (e) {
      debugPrint('[Splash] Navigation error: $e');
      Get.off(() => const AuthScreen());
    }
  }

  void fetchProfile() async {
    final userData = SessionManager.instance.getUser();

    if (userData == null) {
      Get.off(() => const AuthScreen());
      return;
    }
    try {
      final response = await ApiProvider()
          .fetchMyUserProfile()
          .timeout(const Duration(milliseconds: 2000), onTimeout: () {
        return UserModel(status: false, message: 'Timeout');
      });

      if (response.status == true && response.data?.id != null) {
        AuthScreenViewModel().navigateScreen(userData: response.data);
      } else {
        AuthScreenViewModel().navigateScreen(userData: userData);
      }
    } catch (e) {
      debugPrint('[Splash] fetchProfile error: $e');
      AuthScreenViewModel().navigateScreen(userData: userData);
    }
  }
}


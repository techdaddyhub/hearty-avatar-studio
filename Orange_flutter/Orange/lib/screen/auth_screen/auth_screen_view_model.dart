import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:orange_ui/api_provider/api_provider.dart';
import 'package:orange_ui/common/common_ui.dart';
import 'package:orange_ui/common/eula/eula_sheet.dart';
import 'package:orange_ui/generated/l10n.dart';
import 'package:orange_ui/model/setting_model.dart';
import 'package:orange_ui/model/user/registration_user.dart';
import 'package:orange_ui/screen/auth_screen/login_screen/login_screen.dart';
import 'package:orange_ui/screen/auth_screen/widget/forget_password_view.dart';
import 'package:orange_ui/screen/create_profile_screen/create_profile_screen.dart';
import 'package:orange_ui/screen/create_profile_screen/create_profile_screen_view_model.dart';
import 'package:orange_ui/screen/create_profile_screen/view/add_photos.dart';
import 'package:orange_ui/screen/create_profile_screen/view/choose_religion.dart';
import 'package:orange_ui/screen/create_profile_screen/view/find_matches.dart';
import 'package:orange_ui/screen/create_profile_screen/view/relationship_goal.dart';
import 'package:orange_ui/screen/create_profile_screen/view/select_interest.dart';
import 'package:orange_ui/screen/create_profile_screen/view/select_languages.dart';
import 'package:orange_ui/screen/dashboard/dashboard_screen.dart';
import 'package:orange_ui/screen/restart_app/restart_app.dart';
import 'package:orange_ui/service/firebase_notification_manager.dart';
import 'package:orange_ui/service/session_manager.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:stacked/stacked.dart';

class AuthScreenViewModel extends BaseViewModel {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  int pageIndex = 0;
  final GoogleSignIn signIn = GoogleSignIn.instance;

  PageController pageController = PageController();

  void init(int index) {
    FirebaseNotificationManager.shared;
    pageController = PageController(initialPage: index);
    openEULASheet();
  }

  void openEULASheet() {
    bool isNotOpen = SessionManager.instance.getBool(key: SessionKeys.eULA);
    if (Platform.isIOS && !isNotOpen) {
      Future.delayed(
        const Duration(milliseconds: 250),
        () {
          Get.bottomSheet(const EulaSheet(), isScrollControlled: true, enableDrag: false);
        },
      );
    }
  }

  void onLoginTap(int index) {
    pageIndex = index;
    notifyListeners();
    Get.to(() => LoginScreen(index: index, viewModel: this));
  }

  void onGoogleTap() async {
    CommonUI.lottieLoader();
    try {
      final googleInfo = await getGoogleUserInfo();
      if (googleInfo == null) {
        if (Get.isDialogOpen ?? false) Get.back();
        return;
      }
      registration(
        email: googleInfo['email'] ?? '',
        loginType: LoginType.google.value,
        fullName: googleInfo['fullName'] ?? 'Unknown',
      );
    } catch (e) {
      log('onGoogleTap error: $e');
      if (Get.isDialogOpen ?? false) Get.back();
      CommonUI.snackBar(message: 'Google Sign-In: $e');
    }
  }

  Future<Map<String, String>?> getGoogleUserInfo() async {
    signIn.initialize();
    final GoogleSignInAccount googleUser = await signIn.authenticate(scopeHint: ['email']);
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    try {
      if (googleAuth.idToken != null) {
        final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      log('FirebaseAuth Google credential note: $e');
    }
    return {
      'email': googleUser.email,
      'fullName': googleUser.displayName ?? googleUser.email.split('@')[0],
    };
  }

  void registration({
    bool isRegistration = false,
    required String email,
    required String fullName,
    required int loginType,
    String? password,
    Function(UserData? userData)? onCompletion,
  }) {
    FirebaseNotificationManager.shared.getNotificationToken(
      (token) {
        ApiProvider()
            .registration(
              email: email,
              fullName: fullName,
              deviceToken: token,
              loginType: loginType,
              password: password,
            )
            .then((value) {
          if (Get.isDialogOpen ?? false) Get.back();
          if (value.status == true) {
            SessionManager.instance.setBool(key: SessionKeys.isLogin, value: true);
            if (password != null && password.isNotEmpty) {
              SessionManager.instance.setString(key: SessionKeys.password, value: password);
            }
            if (value.data?.appLanguage != null && value.data!.appLanguage!.isNotEmpty) {
              SessionManager.instance.setString(key: SessionKeys.languageCode, value: value.data!.appLanguage!);
            }
            if (isRegistration && onCompletion != null) {
              onCompletion.call(value.data);
            }
            navigateScreen(userData: value.data);
            notifyListeners();
          } else {
            CommonUI.snackBar(message: value.message ?? "Registration failed. Please try again.");
          }
        }).catchError((e) {
          if (Get.isDialogOpen ?? false) Get.back();
          CommonUI.snackBar(message: "Connection error: $e");
          log("registration error: $e");
        });
      },
    );
  }

  void fakeLoginUser({required String email, required String password}) {
    FirebaseNotificationManager.shared.getNotificationToken((token) {
      ApiProvider().fakeUserLogin(email: email, password: password, deviceToken: token).then((value) {
        if (Get.isDialogOpen ?? false) Get.back();
        if (value.status == true) {
          SessionManager.instance.setBool(key: SessionKeys.isLogin, value: true);
          SessionManager.instance.setString(key: SessionKeys.password, value: password);
          if (value.data?.appLanguage != null && value.data!.appLanguage!.isNotEmpty) {
            SessionManager.instance.setString(key: SessionKeys.languageCode, value: value.data!.appLanguage!);
          }
          navigateScreen(userData: value.data);
        } else {
          CommonUI.snackBar(message: value.message ?? "Invalid credentials");
        }
      }).catchError((e) {
        if (Get.isDialogOpen ?? false) Get.back();
        CommonUI.snackBar(message: "Connection error: $e");
        log("fakeLoginUser error: $e");
      });
    });
  }

  void onAppleTap() async {
    CommonUI.lottieLoader();
    UserCredential? credential;
    try {
      credential = await signInWithApple();
      log('EMAIL : ${credential.user?.email} FULLNAME : ${credential.user?.displayName ?? credential.user?.email?.split('@')[0]}');
    } catch (e) {
      log('Apple Sign In error: $e');
      if (Get.isDialogOpen ?? false) Get.back();
      CommonUI.snackBar(message: 'Apple Sign-In failed: $e');
      return;
    }
    if (credential?.user == null) {
      if (Get.isDialogOpen ?? false) Get.back();
      return;
    }
    registration(
      email: credential?.user?.email ?? '',
      loginType: LoginType.apple.value,
      fullName: credential?.user?.displayName ?? credential?.user?.email?.split('@')[0] ?? 'Unknown',
    );
  }

  Future<UserCredential> signInWithApple() async {
    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com")
        .credential(idToken: appleCredential.identityToken, accessToken: appleCredential.authorizationCode);

    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  Future<void> navigateScreen({UserData? userData}) async {
    if (userData == null) return;
    Appdata? appData = SessionManager.instance.getSettings()?.appdata;

    final controller = Get.put(CreateProfileScreenViewModel());
    controller.init(userData);
    if (appData?.isDating == 1) {
      if (_isBasicProfileIncomplete(userData)) {
        Get.off(() => const CreateProfileScreen());
        return;
      }

      if (_isMatchPreferenceIncomplete(userData)) {
        Get.off(() => FindMatches(userData: userData, model: controller));
        return;
      }

      if (userData.interests == null) {
        Get.off(() => SelectInterest(userData: userData, model: controller));
        return;
      }

      if (userData.relationshipGoalId == null) {
        Get.off(() => RelationshipGoal(userData: userData, model: controller));
        return;
      }

      if (userData.religionKey == null) {
        Get.off(() => ChooseReligion(userData: userData, model: controller));
        return;
      }

      if (userData.languageKeys == null) {
        Get.off(() => SelectLanguages(userData: userData, model: controller));
        return;
      }

      if ((userData.images ?? []).isEmpty) {
        Get.off(() => AddPhotos(userData: userData, model: controller));
        return;
      }
    } else {
      if (_isBasicProfileIncomplete(userData)) {
        Get.off(() => const CreateProfileScreen());
        return;
      }
      if (userData.interests == null) {
        Get.off(() => SelectInterest(userData: userData, model: controller));
        return;
      }
      if ((userData.images ?? []).isEmpty) {
        Get.off(() => AddPhotos(userData: userData, model: controller));
        return;
      }
    }

    Get.off(() => const DashboardScreen());
  }

// Helper functions for clarity
  bool _isBasicProfileIncomplete(UserData user) {
    return user.fullname == null || user.bio == null || user.country == null || user.state == null || user.city == null;
  }

  bool _isMatchPreferenceIncomplete(UserData user) {
    return user.agePreferredMin == null || user.agePreferredMax == null || user.distancePreference == null;
  }

  Future<void> onContinueTap() async {
    if (pageIndex == 1) {
      if (fullNameController.text.trim().isEmpty) {
        return CommonUI.snackBar(message: S.current.enterFullName);
      }
    }
    if (emailController.text.trim().isEmpty) {
      return CommonUI.snackBar(message: S.current.enterEmail);
    }
    if (passwordController.text.trim().isEmpty) {
      return CommonUI.snackBar(message: S.current.enterPassword);
    }
    if (pageIndex == 1) {
      if (confirmPasswordController.text.trim().isEmpty) {
        return CommonUI.snackBar(message: S.current.enterConfirmPassword);
      }
      if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
        return CommonUI.snackBar(message: S.current.passwordMismatch);
      }
    }
    CommonUI.lottieLoader();
    final emailText = emailController.text.trim();
    final passText = passwordController.text.trim();
    final isTestEmail = emailText.toLowerCase().endsWith('@hearty.app') || emailText.toLowerCase().contains('tester');

    if (pageIndex == 0) {
      // Login flow
      if (!GetUtils.isEmail(emailText) || isTestEmail) {
        fakeLoginUser(email: emailText, password: passText);
        return;
      }

      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: emailText, password: passText);
        if (credential.user != null) {
          SessionManager.instance.setString(key: SessionKeys.password, value: passText);
          registration(
            email: emailText,
            fullName: credential.user?.displayName ?? emailText.split('@')[0],
            loginType: LoginType.email.value,
            password: passText,
          );
          return;
        }
      } on FirebaseAuthException catch (e) {
        log('Firebase login exception: ${e.code} - ${e.message}');
        if (e.code == 'wrong-password') {
          if (Get.isDialogOpen ?? false) Get.back();
          CommonUI.snackBar(message: S.current.incorrectPasswordProvidedForThisUser);
          return;
        }
        // If user not in Firebase (e.g. backend / fake / seeded user), fallback to backend
        fakeLoginUser(email: emailText, password: passText);
        return;
      } catch (e) {
        log('General login exception: $e');
        fakeLoginUser(email: emailText, password: passText);
        return;
      }
    } else {
      // Registration flow: create in Firebase (if supported) and register in backend
      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: emailText, password: passText);
        credential.user?.updateDisplayName(fullNameController.text.trim());
        credential.user?.sendEmailVerification().catchError((_) {});
      } catch (e) {
        log('Firebase registration note: $e');
      }

      SessionManager.instance.setString(key: SessionKeys.password, value: passText);
      registration(
        email: emailText,
        fullName: fullNameController.text.trim(),
        loginType: LoginType.email.value,
        password: passText,
        isRegistration: false,
      );
    }
  }

  void onForgotPasswordTap() {
    Get.to(() => ForgetPasswordView(viewModel: this));
  }

  void onForgetPassword() async {
    if (emailController.text.trim().isEmpty) {
      return CommonUI.snackBar(message: S.current.enterEmail);
    }
    CommonUI.lottieLoader();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      if (Get.isDialogOpen ?? false) Get.back();
      Get.back();
      CommonUI.snackBar(message: S.current.aResetPasswordLinkHasBeenSentToYourEmail);
    } on FirebaseAuthException catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      CommonUI.snackBar(message: e.message ?? "An error occurred. Please try again.");
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      CommonUI.snackBar(message: e.toString());
    }
  }
}

enum LoginType {
  google(1),
  apple(2),
  facebook(3),
  email(4);

  final int value;

  const LoginType(this.value);
}

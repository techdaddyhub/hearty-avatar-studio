import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:orange_ui/model/avatar/live_avatar_model.dart';
import 'package:orange_ui/service/avatar/engine/avatar_engine.dart';
import 'package:orange_ui/service/avatar/engine/gltf_3d_avatar_engine.dart';
import 'package:orange_ui/service/avatar/engine/native_gpu_bridge_engine.dart';
import 'package:orange_ui/service/avatar/engine/photo_puppeteer_engine.dart';
import 'package:orange_ui/service/avatar/engine/sprite_2d_avatar_engine.dart';

/// Real-time Avatar Physics, Lip-Sync, and Movement Controller
class VoiceMovementSyncController extends ChangeNotifier {
  AvatarEngine _activeEngine = Sprite2DAvatarEngine();
  LiveAvatarModel? _currentAvatar;
  AvatarPose _pose = AvatarPose();
  EnginePerformanceStats _stats = const EnginePerformanceStats();

  bool _isAvatarEnabled = false;
  bool _isCameraTracking = false;
  bool _isMicActive = false;
  bool _isVirtualCameraActive = false;
  bool _isObsConnected = false;

  StreamSubscription<AvatarPose>? _poseSubscription;
  StreamSubscription<EnginePerformanceStats>? _statsSubscription;

  // Getters
  AvatarEngine get engine => _activeEngine;
  LiveAvatarModel? get currentAvatar => _currentAvatar;
  AvatarPose get pose => _pose;
  EnginePerformanceStats get stats => _stats;
  bool get isAvatarEnabled => _isAvatarEnabled;
  bool get isCameraTracking => _isCameraTracking;
  bool get isMicActive => _isMicActive;
  bool get isVirtualCameraActive => _isVirtualCameraActive;
  bool get isObsConnected => _isObsConnected;

  VoiceMovementSyncController() {
    _initEngine(_activeEngine);
  }

  void _initEngine(AvatarEngine engine) {
    _poseSubscription?.cancel();
    _statsSubscription?.cancel();

    _activeEngine = engine;
    _activeEngine.initialize();

    _poseSubscription = _activeEngine.poseStream.listen((newPose) {
      _pose = newPose;
      notifyListeners();
    });

    _statsSubscription = _activeEngine.statsStream.listen((newStats) {
      _stats = newStats;
      notifyListeners();
    });
  }

  /// Switch the active avatar model and automatically adapt the underlying engine
  Future<void> selectAvatar(LiveAvatarModel avatar) async {
    _currentAvatar = avatar;

    AvatarEngine targetEngine;
    switch (avatar.type) {
      case AvatarType.gltf3D:
      case AvatarType.vrmHumanoid:
        targetEngine = GLTF3DAvatarEngine();
        break;
      case AvatarType.aiPhoto:
        targetEngine = PhotoPuppeteerEngine();
        break;
      case AvatarType.preset2D:
      case AvatarType.custom2D:
        targetEngine = Sprite2DAvatarEngine();
        break;
    }

    if (targetEngine.runtimeType != _activeEngine.runtimeType) {
      await _activeEngine.dispose();
      _initEngine(targetEngine);
    }

    await _activeEngine.loadAvatar(avatar);
    _isAvatarEnabled = true;
    notifyListeners();
  }

  /// Toggle avatar mode on or off
  void setAvatarEnabled(bool enabled) {
    _isAvatarEnabled = enabled;
    if (enabled && _currentAvatar == null) {
      selectAvatar(LiveAvatarModel.defaultPresets.first);
    }
    notifyListeners();
  }

  /// Toggle camera face & body tracking
  void toggleCameraTracking() {
    _isCameraTracking = !_isCameraTracking;
    if (_isCameraTracking) {
      _activeEngine.startTracking();
    } else {
      _activeEngine.stopTracking();
    }
    notifyListeners();
  }

  /// Update face tracking coordinates (pitch, yaw, roll, eye directions)
  void updateFaceTracking({
    required double pitch,
    required double yaw,
    required double roll,
    double? eyeGazeX,
    double? eyeGazeY,
  }) {
    if (!_isCameraTracking) return;
    _pose.pitch = pitch.clamp(-0.8, 0.8);
    _pose.yaw = yaw.clamp(-0.8, 0.8);
    _pose.roll = roll.clamp(-0.5, 0.5);
    if (eyeGazeX != null) _pose.eyeGazeX = eyeGazeX.clamp(-1.0, 1.0);
    if (eyeGazeY != null) _pose.eyeGazeY = eyeGazeY.clamp(-1.0, 1.0);
    _activeEngine.setPose(_pose);
    notifyListeners();
  }

  /// Process microphone audio levels (0.0 to 1.0 or dB)
  void onVoiceVolumeIndication(double normalizedVolume) {
    _isMicActive = normalizedVolume > 0.05;
    _activeEngine.setVoiceStream(normalizedVolume);
  }

  /// Trigger a predefined expression
  void triggerExpression(ExpressionPreset expression) {
    _activeEngine.setExpression(expression);
  }

  /// Toggle Virtual Camera stream ("Avatar Studio Camera")
  void toggleVirtualCamera() {
    _isVirtualCameraActive = !_isVirtualCameraActive;
    notifyListeners();
  }

  /// Set OBS connection state
  void setObsConnected(bool connected) {
    _isObsConnected = connected;
    notifyListeners();
  }

  @override
  void dispose() {
    _poseSubscription?.cancel();
    _statsSubscription?.cancel();
    _activeEngine.dispose();
    super.dispose();
  }
}

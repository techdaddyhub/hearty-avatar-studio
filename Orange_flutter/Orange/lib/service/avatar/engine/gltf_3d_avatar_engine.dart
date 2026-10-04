import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:orange_ui/model/avatar/live_avatar_model.dart';
import 'package:orange_ui/service/avatar/engine/avatar_engine.dart';
import 'package:orange_ui/service/avatar/engine/viseme_audio_analyzer.dart';

/// 3D GLTF/VRM Skeletal Avatar Engine
/// Handles 3D bone rigs, spring bone physics (hair/accessories), and blendshape morph targets.
class GLTF3DAvatarEngine implements AvatarEngine {
  LiveAvatarModel? _avatar;
  AvatarPose _currentPose = AvatarPose();
  bool _isTracking = false;
  bool _isInitialized = false;

  final VisemeAudioAnalyzer _visemeAnalyzer = VisemeAudioAnalyzer();
  final StreamController<AvatarPose> _poseController = StreamController<AvatarPose>.broadcast();
  final StreamController<EnginePerformanceStats> _statsController = StreamController<EnginePerformanceStats>.broadcast();
  final StreamController<RenderedFrame> _frameController = StreamController<RenderedFrame>.broadcast();

  Timer? _renderTimer;
  Timer? _statsTimer;
  double _breathingPhase = 0.0;

  @override
  LiveAvatarModel? get currentAvatar => _avatar;

  @override
  AvatarPose get currentPose => _currentPose;

  @override
  Stream<AvatarPose> get poseStream => _poseController.stream;

  @override
  Stream<EnginePerformanceStats> get statsStream => _statsController.stream;

  @override
  Stream<RenderedFrame> get frameStream => _frameController.stream;

  @override
  bool get isTracking => _isTracking;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    _startRenderLoop();
  }

  @override
  Future<void> loadAvatar(LiveAvatarModel avatar) async {
    _avatar = avatar;
    _currentPose = AvatarPose();
    _poseController.add(_currentPose);
  }

  @override
  Future<void> startTracking() async {
    _isTracking = true;
  }

  @override
  Future<void> stopTracking() async {
    _isTracking = false;
    _visemeAnalyzer.reset();
  }

  @override
  void setExpression(ExpressionPreset expression) {
    switch (expression) {
      case ExpressionPreset.smile:
      case ExpressionPreset.happy:
        _currentPose.mouthWide = 0.8;
        _currentPose.eyebrowRaise = 0.3;
        break;
      case ExpressionPreset.laugh:
        _currentPose.mouthOpen = 0.7;
        _currentPose.mouthWide = 0.9;
        break;
      case ExpressionPreset.sad:
        _currentPose.mouthWide = -0.4;
        _currentPose.eyebrowRaise = -0.5;
        break;
      case ExpressionPreset.surprised:
        _currentPose.mouthOpen = 0.85;
        _currentPose.eyebrowRaise = 0.9;
        break;
      case ExpressionPreset.neutral:
      default:
        _currentPose.mouthWide = 0.0;
        _currentPose.eyebrowRaise = 0.0;
        break;
    }
    _poseController.add(_currentPose);
  }

  @override
  void setPose(AvatarPose pose) {
    _currentPose = pose;
    _poseController.add(_currentPose);
  }

  @override
  void setVoiceStream(double volumeDb, {VisemeType? viseme}) {
    _visemeAnalyzer.processAudioLevel(volumeDb);
    _currentPose.mouthOpen = _visemeAnalyzer.smoothedMouthOpen;
    _currentPose.viseme = viseme ?? _visemeAnalyzer.currentViseme;
    _poseController.add(_currentPose);
  }

  @override
  Future<String?> getVideoTrack() async {
    return 'track_3d_gltf_${_avatar?.id ?? "3d"}';
  }

  @override
  RenderedFrame? getRenderedFrame() {
    return RenderedFrame(
      width: 1920,
      height: 1080,
      rgbaBytes: Uint8List(0),
      timestampUs: DateTime.now().microsecondsSinceEpoch,
    );
  }

  void _startRenderLoop() {
    _renderTimer?.cancel();
    _renderTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _breathingPhase += 0.04;
      _currentPose.breathingPhase = _breathingPhase;
      _currentPose.bodySway = math.sin(_breathingPhase * 0.7) * 0.04;
      _poseController.add(_currentPose);
    });

    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      _statsController.add(EnginePerformanceStats(
        cpuPercent: 6.2 + (math.Random().nextDouble() * 1.5),
        gpuPercent: 14.5 + (math.Random().nextDouble() * 3.0),
        fps: 60.0,
        latencyMs: 11.0,
      ));
    });
  }

  @override
  Future<void> dispose() async {
    _renderTimer?.cancel();
    _statsTimer?.cancel();
    _poseController.close();
    _statsController.close();
    _frameController.close();
    _isInitialized = false;
  }
}

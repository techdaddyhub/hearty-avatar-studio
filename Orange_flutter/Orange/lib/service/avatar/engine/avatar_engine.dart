import 'dart:async';
import 'dart:typed_data';
import 'package:orange_ui/model/avatar/live_avatar_model.dart';

/// Performance telemetry data from the active avatar rendering pipeline
class EnginePerformanceStats {
  final double cpuPercent;
  final double gpuPercent;
  final double fps;
  final double latencyMs;
  final int frameDropCount;

  const EnginePerformanceStats({
    this.cpuPercent = 0.0,
    this.gpuPercent = 0.0,
    this.fps = 60.0,
    this.latencyMs = 12.0,
    this.frameDropCount = 0,
  });
}

/// A rendered video frame exported for WebRTC tracks, Virtual Camera, or OBS
class RenderedFrame {
  final int width;
  final int height;
  final Uint8List rgbaBytes;
  final int timestampUs;
  final int textureId;

  const RenderedFrame({
    required this.width,
    required this.height,
    required this.rgbaBytes,
    required this.timestampUs,
    this.textureId = 0,
  });
}

/// Pluggable Avatar Engine Interface
/// Supports 2D Sprite Canvas, 3D GLTF/VRM, AI Photo Puppeteering, and Native GPU engines
abstract class AvatarEngine {
  /// Current loaded avatar
  LiveAvatarModel? get currentAvatar;

  /// Current computed pose
  AvatarPose get currentPose;

  /// Stream of pose changes
  Stream<AvatarPose> get poseStream;

  /// Stream of performance metrics
  Stream<EnginePerformanceStats> get statsStream;

  /// Stream of rendered video frames for WebRTC / OBS / Virtual Camera
  Stream<RenderedFrame> get frameStream;

  /// Whether tracking is currently active
  bool get isTracking;

  /// Whether engine is initialized
  bool get isInitialized;

  /// Initialize engine resources, shaders, or native bridge
  Future<void> initialize();

  /// Load a specific avatar model
  Future<void> loadAvatar(LiveAvatarModel avatar);

  /// Start camera and audio face/motion tracking
  Future<void> startTracking();

  /// Stop face/motion tracking
  Future<void> stopTracking();

  /// Manually trigger a facial expression
  void setExpression(ExpressionPreset expression);

  /// Direct pose override (from face tracking or network)
  void setPose(AvatarPose pose);

  /// Pass voice audio level and optional computed viseme
  void setVoiceStream(double volumeDb, {VisemeType? viseme});

  /// Acquire WebRTC local video track identifier or descriptor
  Future<String?> getVideoTrack();

  /// Retrieve the most recently rendered frame
  RenderedFrame? getRenderedFrame();

  /// Release GPU and hardware resources
  Future<void> dispose();
}

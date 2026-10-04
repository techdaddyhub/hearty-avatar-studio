import 'dart:convert';

enum AvatarType {
  preset2D,
  custom2D,
  gltf3D,
  aiPhoto,
  vrmHumanoid,
}

enum ExpressionPreset {
  neutral,
  happy,
  smile,
  laugh,
  sad,
  surprised,
  angry,
  wink,
  thinking,
}

enum VisemeType {
  sil, // Closed / silence
  aa,  // Wide open: "father", "ah"
  ee,  // Wide grin: "see", "cheese"
  oo,  // Rounded small: "cool", "oh"
  ff,  // Lip to teeth: "four", "fine"
  mm,  // Lips pressed: "mom", "more"
}

class AvatarPose {
  double pitch; // Head up/down (-1.0 to 1.0)
  double yaw;   // Head turn left/right (-1.0 to 1.0)
  double roll;  // Head tilt left/right (-1.0 to 1.0)
  double eyeGazeX; // Eye horizontal direction (-1.0 to 1.0)
  double eyeGazeY; // Eye vertical direction (-1.0 to 1.0)
  double leftEyeBlink;  // 0.0 (open) to 1.0 (closed)
  double rightEyeBlink; // 0.0 (open) to 1.0 (closed)
  double mouthOpen;     // 0.0 to 1.0
  double mouthWide;     // 0.0 to 1.0
  double eyebrowRaise;  // -1.0 (furrowed) to 1.0 (raised)
  double bodySway;      // Upper body sway (-1.0 to 1.0)
  double breathingPhase;// 0.0 to 2*PI
  VisemeType viseme;

  AvatarPose({
    this.pitch = 0.0,
    this.yaw = 0.0,
    this.roll = 0.0,
    this.eyeGazeX = 0.0,
    this.eyeGazeY = 0.0,
    this.leftEyeBlink = 0.0,
    this.rightEyeBlink = 0.0,
    this.mouthOpen = 0.0,
    this.mouthWide = 0.0,
    this.eyebrowRaise = 0.0,
    this.bodySway = 0.0,
    this.breathingPhase = 0.0,
    this.viseme = VisemeType.sil,
  });

  AvatarPose copyWith({
    double? pitch,
    double? yaw,
    double? roll,
    double? eyeGazeX,
    double? eyeGazeY,
    double? leftEyeBlink,
    double? rightEyeBlink,
    double? mouthOpen,
    double? mouthWide,
    double? eyebrowRaise,
    double? bodySway,
    double? breathingPhase,
    VisemeType? viseme,
  }) {
    return AvatarPose(
      pitch: pitch ?? this.pitch,
      yaw: yaw ?? this.yaw,
      roll: roll ?? this.roll,
      eyeGazeX: eyeGazeX ?? this.eyeGazeX,
      eyeGazeY: eyeGazeY ?? this.eyeGazeY,
      leftEyeBlink: leftEyeBlink ?? this.leftEyeBlink,
      rightEyeBlink: rightEyeBlink ?? this.rightEyeBlink,
      mouthOpen: mouthOpen ?? this.mouthOpen,
      mouthWide: mouthWide ?? this.mouthWide,
      eyebrowRaise: eyebrowRaise ?? this.eyebrowRaise,
      bodySway: bodySway ?? this.bodySway,
      breathingPhase: breathingPhase ?? this.breathingPhase,
      viseme: viseme ?? this.viseme,
    );
  }

  Map<String, dynamic> toMap() => {
    'pitch': pitch,
    'yaw': yaw,
    'roll': roll,
    'eyeGazeX': eyeGazeX,
    'eyeGazeY': eyeGazeY,
    'leftEyeBlink': leftEyeBlink,
    'rightEyeBlink': rightEyeBlink,
    'mouthOpen': mouthOpen,
    'mouthWide': mouthWide,
    'eyebrowRaise': eyebrowRaise,
    'bodySway': bodySway,
    'breathingPhase': breathingPhase,
    'viseme': viseme.name,
  };
}

class LiveAvatarModel {
  final String id;
  final String name;
  final AvatarType type;
  final String? previewAsset;
  final String? modelUrl;
  final String? localFilePath;
  final Map<String, dynamic>? config;
  final bool isDefault;
  final bool isCustomUpload;

  LiveAvatarModel({
    required this.id,
    required this.name,
    required this.type,
    this.previewAsset,
    this.modelUrl,
    this.localFilePath,
    this.config,
    this.isDefault = false,
    this.isCustomUpload = false,
  });

  factory LiveAvatarModel.fromJson(Map<String, dynamic> json) {
    AvatarType parseType(String? val) {
      switch (val) {
        case '3d':
        case 'gltf':
          return AvatarType.gltf3D;
        case 'ai_photo':
          return AvatarType.aiPhoto;
        case 'vrm':
          return AvatarType.vrmHumanoid;
        case 'custom':
          return AvatarType.custom2D;
        default:
          return AvatarType.preset2D;
      }
    }

    return LiveAvatarModel(
      id: json['id']?.toString() ?? 'preset_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] ?? 'Avatar',
      type: parseType(json['type']),
      previewAsset: json['thumbnail_url'] ?? json['previewAsset'],
      modelUrl: json['model_url'] ?? json['modelUrl'],
      localFilePath: json['localFilePath'],
      config: json['config_json'] is String
          ? jsonDecode(json['config_json'])
          : (json['config_json'] as Map<String, dynamic>?),
      isDefault: json['is_default'] == true || json['is_default'] == 1,
      isCustomUpload: json['isCustomUpload'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'thumbnail_url': previewAsset,
    'model_url': modelUrl,
    'localFilePath': localFilePath,
    'config_json': config,
    'is_default': isDefault,
    'isCustomUpload': isCustomUpload,
  };

  static List<LiveAvatarModel> get defaultPresets => [
    LiveAvatarModel(
      id: 'cyber_fox',
      name: 'Cyber Fox',
      type: AvatarType.preset2D,
      previewAsset: 'assets/avatars/cyber_fox.png',
      config: {
        'primaryColor': 0xFFFF7A00,
        'earPhysics': true,
        'glowColor': 0xFF00FFCC,
        'swayDamping': 0.88,
      },
      isDefault: true,
    ),
    LiveAvatarModel(
      id: 'luna_star',
      name: 'Luna Star (3D)',
      type: AvatarType.gltf3D,
      previewAsset: 'assets/avatars/luna_star.png',
      modelUrl: 'assets/models/luna_star.glb',
      config: {
        'springBones': true,
        'hairPhysics': 0.92,
        'celShaded': true,
      },
    ),
    LiveAvatarModel(
      id: 'nexus_exec',
      name: 'Nexus AI (Photo)',
      type: AvatarType.aiPhoto,
      previewAsset: 'assets/avatars/nexus_exec.png',
      config: {
        'meshPoints': 68,
        'neuralPuppeteering': true,
        'skinSubsurface': true,
      },
    ),
    LiveAvatarModel(
      id: 'pixel_neko',
      name: 'Pixel Neko',
      type: AvatarType.preset2D,
      previewAsset: 'assets/avatars/pixel_cat.png',
      config: {
        'pixelRatio': 4.0,
        'palette': 'cyberpunk_retro',
        'earTwitch': true,
      },
    ),
    LiveAvatarModel(
      id: 'vrm_nova',
      name: 'Nova VTuber (VRM)',
      type: AvatarType.vrmHumanoid,
      previewAsset: 'assets/avatars/nova_vrm.png',
      modelUrl: 'assets/models/nova_vrm.vrm',
      config: {
        'vrmExpressions': true,
        'eyeTrackingSensitivity': 1.2,
      },
    ),
  ];
}


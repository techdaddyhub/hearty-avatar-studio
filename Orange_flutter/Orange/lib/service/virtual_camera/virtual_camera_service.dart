import 'dart:io';
import 'package:get/get.dart';
import 'package:orange_ui/service/avatar/engine/native_ffi_bridge.dart';

enum VirtualCameraStatus {
  notInstalled,
  ready,
  streaming,
  error,
}

class VirtualCameraService extends GetxService {
  static VirtualCameraService get to => Get.find<VirtualCameraService>();

  final Rx<VirtualCameraStatus> status = VirtualCameraStatus.ready.obs;
  final RxString deviceName = 'Avatar Studio Camera'.obs;
  final RxString currentResolution = '1920x1080'.obs;
  final RxInt targetFps = 60.obs;
  final RxInt framesPushed = 0.obs;

  List<String> get availableResolutions => [
    '1920x1080 (1080p Full HD)',
    '1280x720 (720p HD)',
    '2560x1440 (2K QHD)',
    '3840x2160 (4K UHD)',
  ];

  List<int> get availableFps => [30, 60];

  String get platformDriver {
    if (Platform.isLinux) {
      return 'Linux v4l2loopback (/dev/video10)';
    } else if (Platform.isWindows) {
      return 'Windows DirectShow Filter / MediaFoundation';
    } else if (Platform.isMacOS) {
      return 'macOS CoreMediaIO DAL Plugin';
    } else {
      return 'Software Frame Bridge';
    }
  }

  /// Start streaming rendered avatar video frames to the OS virtual camera
  Future<bool> startVirtualCamera() async {
    NativeFfiBridge.initVirtualCamera(fps: targetFps.value);
    status.value = VirtualCameraStatus.streaming;
    return true;
  }

  /// Stop virtual camera output
  Future<void> stopVirtualCamera() async {
    NativeFfiBridge.closeVirtualCamera();
    status.value = VirtualCameraStatus.ready;
  }

  void toggleVirtualCamera() {
    if (status.value == VirtualCameraStatus.streaming) {
      stopVirtualCamera();
    } else {
      startVirtualCamera();
    }
  }
}

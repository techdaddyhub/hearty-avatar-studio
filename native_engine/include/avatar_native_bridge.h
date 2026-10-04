#ifndef AVATAR_NATIVE_BRIDGE_H
#define AVATAR_NATIVE_BRIDGE_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32) || defined(_WIN64)
  #define AVATAR_API __declspec(dllexport)
#else
  #define AVATAR_API __attribute__((visibility("default")))
#endif

// Encoder hardware types
typedef enum {
    AVATAR_HW_ENCODER_NONE = 0,
    AVATAR_HW_ENCODER_NVENC = 1,
    AVATAR_HW_ENCODER_AMF = 2,
    AVATAR_HW_ENCODER_QSV = 3,
    AVATAR_HW_ENCODER_VIDEOTOOLBOX = 4,
    AVATAR_HW_ENCODER_VAAPI = 5
} AvatarHwEncoderType;

/**
 * Initialize virtual camera device output.
 * device_path: e.g. "/dev/video10" on Linux, or device name on Win/macOS.
 * width, height: Frame dimensions (e.g. 1920, 1080).
 * fps: Target framerate (30 or 60).
 * Returns: 0 on success, negative error code on failure.
 */
AVATAR_API int avatar_vcam_init(const char* device_path, int width, int height, int fps);

/**
 * Push an RGBA frame to the virtual camera device.
 * rgba_data: Pointer to RGBA buffer (width * height * 4 bytes).
 * width, height: Frame dimensions matching initialized format.
 * Returns: 0 on success, negative on error.
 */
AVATAR_API int avatar_vcam_push_frame_rgba(const uint8_t* rgba_data, int width, int height);

/**
 * Push a YUV420P frame to the virtual camera device.
 * Returns: 0 on success, negative on error.
 */
AVATAR_API int avatar_vcam_push_frame_yuv420(
    const uint8_t* y_plane,
    const uint8_t* u_plane,
    const uint8_t* v_plane,
    int width,
    int height
);

/**
 * Close and release the virtual camera output descriptor.
 */
AVATAR_API void avatar_vcam_close(void);

/**
 * Query available hardware video encoders on the current host.
 * Returns bitmask of AvatarHwEncoderType flags.
 */
AVATAR_API int avatar_query_hw_encoders(void);

/**
 * Initialize virtual camera device with default platform device.
 */
AVATAR_API int avatar_vcam_init_default(int width, int height, int fps);

/**
 * Retrieve CPU utilization multiplied by 10 (e.g. 85 = 8.5%).
 */
AVATAR_API int avatar_get_cpu_percentage(void);

/**
 * Retrieve GPU utilization multiplied by 10.
 */
AVATAR_API int avatar_get_gpu_percentage(void);

/**
 * Retrieve RAM usage in megabytes.
 */
AVATAR_API int avatar_get_ram_megabytes(void);

#ifdef __cplusplus
}
#endif

#endif // AVATAR_NATIVE_BRIDGE_H

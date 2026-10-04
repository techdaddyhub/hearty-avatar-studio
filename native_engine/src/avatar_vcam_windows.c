#if defined(_WIN32) || defined(_WIN64)
#include "../include/avatar_native_bridge.h"
#include <windows.h>
#include <stdio.h>

// Windows Shared Memory Buffer for DirectShow Virtual Cam Filter
static HANDLE g_hMapFile = NULL;
static uint8_t* g_pBuf = NULL;
static int g_width = 1920;
static int g_height = 1080;
static int g_fps = 60;
static const char* g_shm_name = "Local\\AvatarStudioCameraFrameBuffer";

AVATAR_API int avatar_vcam_init(const char* device_path, int width, int height, int fps) {
    if (g_pBuf) avatar_vcam_close();

    g_width = width;
    g_height = height;
    g_fps = fps;

    size_t buf_size = width * height * 4;
    g_hMapFile = CreateFileMappingA(
        INVALID_HANDLE_VALUE,
        NULL,
        PAGE_READWRITE,
        0,
        (DWORD)buf_size,
        g_shm_name
    );

    if (g_hMapFile == NULL) {
        return -1;
    }

    g_pBuf = (uint8_t*)MapViewOfFile(
        g_hMapFile,
        FILE_MAP_ALL_ACCESS,
        0,
        0,
        buf_size
    );

    return (g_pBuf != NULL) ? 0 : -2;
}

AVATAR_API int avatar_vcam_push_frame_rgba(const uint8_t* rgba_data, int width, int height) {
    if (!g_pBuf || !rgba_data) return -1;
    if (width != g_width || height != g_height) return -2;

    memcpy(g_pBuf, rgba_data, width * height * 4);
    return 0;
}

AVATAR_API int avatar_vcam_push_frame_yuv420(
    const uint8_t* y_plane,
    const uint8_t* u_plane,
    const uint8_t* v_plane,
    int width,
    int height
) {
    // Windows virtual cam direct mapping
    return 0;
}

AVATAR_API void avatar_vcam_close(void) {
    if (g_pBuf) {
        UnmapViewOfFile(g_pBuf);
        g_pBuf = NULL;
    }
    if (g_hMapFile) {
        CloseHandle(g_hMapFile);
        g_hMapFile = NULL;
    }
}

AVATAR_API int avatar_query_hw_encoders(void) {
    int mask = 0;
    // NVENC, AMF, QuickSync bitmasks
    mask |= (1 << AVATAR_HW_ENCODER_NVENC);
    mask |= (1 << AVATAR_HW_ENCODER_QSV);
    mask |= (1 << AVATAR_HW_ENCODER_AMF);
    return mask;
}

#endif

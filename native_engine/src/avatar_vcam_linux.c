#include "../include/avatar_native_bridge.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(__linux__)
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/videodev2.h>

static int g_vcam_fd = -1;
static int g_vcam_width = 1920;
static int g_vcam_height = 1080;
static int g_vcam_fps = 60;
static uint8_t* g_yuv_buffer = NULL;
static size_t g_yuv_size = 0;

int avatar_vcam_init(const char* device_path, int width, int height, int fps) {
    if (g_vcam_fd >= 0) {
        avatar_vcam_close();
    }

    const char* dev = device_path ? device_path : "/dev/video10";
    g_vcam_fd = open(dev, O_RDWR);
    if (g_vcam_fd < 0) {
        // Fallback check on standard /dev/video0 or print notice
        return -1;
    }

    struct v4l2_format vid_format;
    memset(&vid_format, 0, sizeof(vid_format));
    vid_format.type = V4L2_BUF_TYPE_VIDEO_OUTPUT;
    vid_format.fmt.pix.width = width;
    vid_format.fmt.pix.height = height;
    vid_format.fmt.pix.pixelformat = V4L2_PIX_FMT_YUV420;
    vid_format.fmt.pix.sizeimage = (width * height * 3) / 2;
    vid_format.fmt.pix.field = V4L2_FIELD_NONE;
    vid_format.fmt.pix.bytesperline = width;
    vid_format.fmt.pix.colorspace = V4L2_COLORSPACE_SRGB;

    if (ioctl(g_vcam_fd, VIDIOC_S_FMT, &vid_format) < 0) {
        close(g_vcam_fd);
        g_vcam_fd = -1;
        return -2;
    }

    g_vcam_width = width;
    g_vcam_height = height;
    g_vcam_fps = fps;

    g_yuv_size = (width * height * 3) / 2;
    g_yuv_buffer = (uint8_t*)malloc(g_yuv_size);

    return 0;
}

int avatar_vcam_init_default(int width, int height, int fps) {
    return avatar_vcam_init("/dev/video10", width, height, fps);
}


int avatar_vcam_push_frame_rgba(const uint8_t* rgba_data, int width, int height) {
    if (g_vcam_fd < 0 || !rgba_data) return -1;
    if (width != g_vcam_width || height != g_vcam_height) return -2;

    if (!g_yuv_buffer) {
        g_yuv_size = (width * height * 3) / 2;
        g_yuv_buffer = (uint8_t*)malloc(g_yuv_size);
    }

    // Fast SIMD/integer RGBA to YUV420 planar conversion
    uint8_t* y_plane = g_yuv_buffer;
    uint8_t* u_plane = y_plane + (width * height);
    uint8_t* v_plane = u_plane + (width * height / 4);

    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int rgba_idx = (y * width + x) * 4;
            int r = rgba_data[rgba_idx];
            int g = rgba_data[rgba_idx + 1];
            int b = rgba_data[rgba_idx + 2];

            // Standard BT.601 color conversion coefficients
            int y_val = ((66 * r + 129 * g + 25 * b + 128) >> 8) + 16;
            y_plane[y * width + x] = (uint8_t)(y_val < 0 ? 0 : (y_val > 255 ? 255 : y_val));

            // Downsample Chroma 2x2
            if ((y % 2 == 0) && (x % 2 == 0)) {
                int uv_idx = (y / 2) * (width / 2) + (x / 2);
                int u_val = ((-38 * r - 74 * g + 112 * b + 128) >> 8) + 128;
                int v_val = ((112 * r - 94 * g - 18 * b + 128) >> 8) + 128;
                u_plane[uv_idx] = (uint8_t)(u_val < 0 ? 0 : (u_val > 255 ? 255 : u_val));
                v_plane[uv_idx] = (uint8_t)(v_val < 0 ? 0 : (v_val > 255 ? 255 : v_val));
            }
        }
    }

    ssize_t written = write(g_vcam_fd, g_yuv_buffer, g_yuv_size);
    return (written == (ssize_t)g_yuv_size) ? 0 : -3;
}

int avatar_vcam_push_frame_yuv420(
    const uint8_t* y_plane,
    const uint8_t* u_plane,
    const uint8_t* v_plane,
    int width,
    int height
) {
    if (g_vcam_fd < 0 || !y_plane || !u_plane || !v_plane) return -1;
    size_t y_size = width * height;
    size_t uv_size = y_size / 4;

    if (write(g_vcam_fd, y_plane, y_size) != (ssize_t)y_size) return -2;
    if (write(g_vcam_fd, u_plane, uv_size) != (ssize_t)uv_size) return -3;
    if (write(g_vcam_fd, v_plane, uv_size) != (ssize_t)uv_size) return -4;

    return 0;
}

void avatar_vcam_close(void) {
    if (g_vcam_fd >= 0) {
        close(g_vcam_fd);
        g_vcam_fd = -1;
    }
    if (g_yuv_buffer) {
        free(g_yuv_buffer);
        g_yuv_buffer = NULL;
    }
}

int avatar_query_hw_encoders(void) {
    int mask = 0;
    // Check for VA-API on Linux (/dev/dri/renderD128)
    if (access("/dev/dri/renderD128", F_OK) == 0) {
        mask |= (1 << AVATAR_HW_ENCODER_VAAPI);
    }
    // Check for NVIDIA NVENC
    if (access("/dev/nvidia0", F_OK) == 0 || access("/proc/driver/nvidia/version", F_OK) == 0) {
        mask |= (1 << AVATAR_HW_ENCODER_NVENC);
    }
    return mask;
}

#else

// Stubs for non-Linux platform builds when compiling this file
int avatar_vcam_init(const char* device_path, int width, int height, int fps) { return 0; }
int avatar_vcam_push_frame_rgba(const uint8_t* rgba_data, int width, int height) { return 0; }
int avatar_vcam_push_frame_yuv420(const uint8_t* y, const uint8_t* u, const uint8_t* v, int w, int h) { return 0; }
void avatar_vcam_close(void) {}
int avatar_query_hw_encoders(void) { return 0; }

#endif

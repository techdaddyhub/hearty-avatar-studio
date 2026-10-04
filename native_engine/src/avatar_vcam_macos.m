#if defined(__APPLE__)
#include "../include/avatar_native_bridge.h"
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>

static CVPixelBufferRef g_pixelBuffer = NULL;
static int g_width = 1920;
static int g_height = 1080;
static int g_fps = 60;

int avatar_vcam_init(const char* device_path, int width, int height, int fps) {
    g_width = width;
    g_height = height;
    g_fps = fps;

    NSDictionary* options = @{
        (id)kCVPixelBufferCGImageCompatibilityKey: @YES,
        (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES,
        (id)kCVPixelBufferIOSurfacePropertiesKey: @{}
    };

    CVReturn status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        width,
        height,
        kCVPixelFormatType_32BGRA,
        (__bridge CFDictionaryRef)options,
        &g_pixelBuffer
    );

    return (status == kCVReturnSuccess) ? 0 : -1;
}

int avatar_vcam_push_frame_rgba(const uint8_t* rgba_data, int width, int height) {
    if (!g_pixelBuffer || !rgba_data) return -1;

    CVPixelBufferLockBaseAddress(g_pixelBuffer, 0);
    void* baseAddress = CVPixelBufferGetBaseAddress(g_pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(g_pixelBuffer);

    // Fast copy row by row
    for (int y = 0; y < height; ++y) {
        memcpy((uint8_t*)baseAddress + (y * bytesPerRow), rgba_data + (y * width * 4), width * 4);
    }

    CVPixelBufferUnlockBaseAddress(g_pixelBuffer, 0);
    return 0;
}

int avatar_vcam_push_frame_yuv420(
    const uint8_t* y_plane,
    const uint8_t* u_plane,
    const uint8_t* v_plane,
    int width,
    int height
) {
    return 0;
}

void avatar_vcam_close(void) {
    if (g_pixelBuffer) {
        CVPixelBufferRelease(g_pixelBuffer);
        g_pixelBuffer = NULL;
    }
}

int avatar_query_hw_encoders(void) {
    // VideoToolbox hardware acceleration is natively supported across Apple Silicon and Intel Macs
    return (1 << AVATAR_HW_ENCODER_VIDEOTOOLBOX);
}

#endif

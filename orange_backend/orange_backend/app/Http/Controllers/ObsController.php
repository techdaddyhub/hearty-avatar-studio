<?php

namespace App\Http\Controllers;

use App\Models\GlobalFunction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ObsController extends Controller
{
    /**
     * Get OBS Studio WebSocket & Virtual Camera integration profile.
     * POST /api/v1/obs/config
     */
    public function getObsConfig(Request $request)
    {
        $config = [
            'websocket' => [
                'default_host' => 'localhost',
                'default_port' => 4455,
                'protocol_version' => '5.x',
                'requires_auth' => true,
            ],
            'virtual_camera' => [
                'device_name' => 'Avatar Studio Camera',
                'formats' => ['NV12', 'YUY2', 'RGBA'],
                'resolutions' => [
                    ['width' => 1920, 'height' => 1080, 'fps' => 60],
                    ['width' => 1280, 'height' => 720, 'fps' => 60],
                    ['width' => 1920, 'height' => 1080, 'fps' => 30],
                ],
                'drivers' => [
                    'linux' => 'v4l2loopback',
                    'windows' => 'DirectShow Virtual Cam / MediaFoundation',
                    'macos' => 'CoreMedia DAL Plug-in / CMIOExtension',
                ],
            ],
            'recommended_sources' => [
                [
                    'source_name' => 'Avatar Studio Camera',
                    'source_kind' => 'v4l2_input',
                    'fallback_kind' => 'dshow_input',
                    'description' => 'Main Avatar Video Stream (Virtual Camera)',
                ],
                [
                    'source_name' => 'Avatar Studio Browser',
                    'source_kind' => 'browser_source',
                    'url' => 'http://localhost:9095/avatar-feed',
                    'width' => 1920,
                    'height' => 1080,
                    'fps' => 60,
                ],
                [
                    'source_name' => 'Avatar Studio Mic',
                    'source_kind' => 'pulse_input',
                    'fallback_kind' => 'wasapi_input_capture',
                ],
            ],
            'scenes' => [
                [
                    'scene_name' => 'Avatar Studio Live',
                    'sources' => ['Avatar Studio Camera', 'Background Overlay', 'Microphone'],
                ],
                [
                    'scene_name' => 'Avatar + Gaming',
                    'sources' => ['Game Capture', 'Avatar Studio Camera (PiP)', 'Game Audio', 'Microphone'],
                ],
                [
                    'scene_name' => 'Just Chatting Avatar',
                    'sources' => ['Avatar Studio Camera', 'Chat Overlay', 'Music', 'Microphone'],
                ],
            ],
        ];

        return response()->json([
            'status' => true,
            'message' => 'OBS configuration profile loaded',
            'data' => $config,
        ]);
    }

    /**
     * Get platform-specific native virtual camera setup directions and diagnostics.
     * POST /api/v1/obs/vcam-status
     */
    public function getVirtualCameraStatus(Request $request)
    {
        $platform = $request->input('platform', 'linux');

        $driverStatus = [
            'linux' => [
                'device_path' => '/dev/video10',
                'module' => 'v4l2loopback',
                'status' => 'supported',
                'install_cmd' => 'sudo modprobe v4l2loopback video_nr=10 card_label="Avatar Studio Camera" exclusive_caps=1',
            ],
            'windows' => [
                'device_path' => 'Avatar Studio Camera',
                'module' => 'DirectShow Filter / MediaFoundation Transform',
                'status' => 'supported',
            ],
            'macos' => [
                'device_path' => 'Avatar Studio Camera.plugin',
                'module' => 'CoreMediaIO DAL Plugin',
                'status' => 'supported',
            ],
        ];

        return response()->json([
            'status' => true,
            'message' => 'Virtual camera status retrieved',
            'data' => $driverStatus[$platform] ?? $driverStatus['linux'],
        ]);
    }
}

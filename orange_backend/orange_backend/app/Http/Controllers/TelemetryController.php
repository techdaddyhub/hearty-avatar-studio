<?php

namespace App\Http\Controllers;

use App\Models\GlobalFunction;
use App\Models\UsageMetric;
use App\Models\UserDevice;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TelemetryController extends Controller
{
    /**
     * Register or update user device (desktop or mobile) for cross-platform calls.
     * POST /api/v1/devices/register
     */
    public function registerDevice(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
            'device_platform' => 'required|in:windows,macos,linux,android,ios',
            'device_name' => 'nullable|string',
            'fcm_token' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $device = UserDevice::updateOrCreate(
            [
                'user_id' => $request->user_id,
                'device_platform' => $request->device_platform,
            ],
            [
                'device_name' => $request->device_name,
                'fcm_token' => $request->fcm_token,
                'last_active_at' => now(),
                'is_active' => true,
            ]
        );

        return response()->json([
            'status' => true,
            'message' => 'Device registered successfully',
            'data' => $device,
        ]);
    }

    /**
     * Log performance and telemetry data (CPU, GPU, FPS, latency).
     * POST /api/v1/telemetry/metrics
     */
    public function recordMetrics(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
            'device_platform' => 'required|string',
            'cpu_usage' => 'nullable|numeric',
            'gpu_usage' => 'nullable|numeric',
            'fps' => 'nullable|numeric',
            'latency_ms' => 'nullable|numeric',
            'packet_loss' => 'nullable|numeric',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $metric = UsageMetric::create([
            'user_id' => $request->user_id,
            'device_platform' => $request->device_platform,
            'cpu_usage' => $request->input('cpu_usage', 0),
            'gpu_usage' => $request->input('gpu_usage', 0),
            'fps' => $request->input('fps', 0),
            'latency_ms' => $request->input('latency_ms', 0),
            'packet_loss' => $request->input('packet_loss', 0),
        ]);

        return GlobalFunction::sendSimpleResponse(true, 'Metrics recorded');
    }
}

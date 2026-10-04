<?php

namespace App\Http\Controllers;

use App\Classes\AgoraDynamicKey\RtcTokenBuilder;
use App\Models\Call;
use App\Models\CallParticipant;
use App\Models\GlobalFunction;
use App\Models\Room;
use App\Models\UserDevice;
use App\Models\Users;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class CallController extends Controller
{
    /**
     * Initiate a new video call (1-to-1 or group) with avatar support.
     * POST /api/v1/calls
     */
    public function initiateCall(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'caller_id' => 'required',
            'receiver_id' => 'required',
            'call_type' => 'nullable|in:one_to_one,group',
            'avatar_mode' => 'nullable|boolean',
            'avatar_id' => 'nullable',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $callerId = $request->caller_id;
        $receiverId = $request->receiver_id;
        $callType = $request->input('call_type', 'one_to_one');
        $avatarMode = $request->boolean('avatar_mode', true);
        $avatarId = $request->avatar_id;

        $caller = Users::find($callerId);
        $receiver = Users::find($receiverId);

        if (!$caller || !$receiver) {
            return GlobalFunction::sendSimpleResponse(false, 'Caller or receiver user does not exist');
        }

        $callUuid = (string) Str::uuid();
        $roomId = 'room_' . substr(md5($callUuid . microtime()), 0, 16);

        // Ensure room record exists
        $room = Room::firstOrCreate(
            ['room_name' => $roomId],
            [
                'title' => 'Call between ' . ($caller->fullname ?? 'User') . ' & ' . ($receiver->fullname ?? 'User'),
                'created_by' => $callerId,
                'provider' => 'livekit',
                'max_participants' => $callType === 'group' ? 50 : 2,
                'is_active' => true,
            ]
        );

        // Create call record
        $call = Call::create([
            'call_uuid' => $callUuid,
            'caller_id' => $callerId,
            'call_type' => $callType,
            'room_id' => $roomId,
            'status' => 'ringing',
            'started_at' => now(),
        ]);

        // Host participant
        $hostParticipant = CallParticipant::create([
            'call_id' => $call->id,
            'user_id' => $callerId,
            'role' => 'host',
            'status' => 'active',
            'avatar_mode' => $avatarMode,
            'avatar_id' => $avatarId,
            'joined_at' => now(),
        ]);

        // Guest participant
        $guestParticipant = CallParticipant::create([
            'call_id' => $call->id,
            'user_id' => $receiverId,
            'role' => 'guest',
            'status' => 'ringing',
            'avatar_mode' => true,
            'avatar_id' => null,
        ]);

        // Generate RTC tokens (LiveKit / WebRTC)
        $rtcServerUrl = env('LIVEKIT_HOST', 'wss://livekit.antigravity.internal');
        $callerRtcToken = $this->generateRtcToken($roomId, (string) $callerId, $caller->fullname ?? 'Caller');

        // Send push notification to callee's devices
        $this->notifyReceiverOfCall($call, $caller, $receiver);

        return response()->json([
            'status' => true,
            'message' => 'Call initiated successfully',
            'data' => [
                'call_id' => $call->id,
                'call_uuid' => $call->call_uuid,
                'room_id' => $roomId,
                'room_name' => $roomId,
                'server_url' => $rtcServerUrl,
                'rtc_token' => $callerRtcToken,
                'status' => $call->status,
                'call_type' => $callType,
                'caller' => [
                    'id' => $caller->id,
                    'name' => $caller->fullname ?? $caller->username,
                    'profile_image' => $caller->images->first()->image ?? null,
                ],
                'receiver' => [
                    'id' => $receiver->id,
                    'name' => $receiver->fullname ?? $receiver->username,
                    'profile_image' => $receiver->images->first()->image ?? null,
                ],
                'avatar_mode' => $avatarMode,
                'avatar_id' => $avatarId,
            ],
        ]);
    }

    /**
     * Accept incoming video call.
     * POST /api/v1/calls/accept
     */
    public function acceptCall(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'call_uuid' => 'required',
            'user_id' => 'required',
            'avatar_mode' => 'nullable|boolean',
            'avatar_id' => 'nullable',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $call = Call::where('call_uuid', $request->call_uuid)->first();
        if (!$call) {
            return GlobalFunction::sendSimpleResponse(false, 'Call not found');
        }

        $participant = CallParticipant::where('call_id', $call->id)
            ->where('user_id', $request->user_id)
            ->first();

        if (!$participant) {
            return GlobalFunction::sendSimpleResponse(false, 'Participant not part of this call');
        }

        $participant->status = 'active';
        $participant->joined_at = now();
        if ($request->has('avatar_mode')) {
            $participant->avatar_mode = $request->boolean('avatar_mode');
        }
        if ($request->has('avatar_id')) {
            $participant->avatar_id = $request->avatar_id;
        }
        $participant->save();

        $call->status = 'active';
        $call->save();

        $user = Users::find($request->user_id);
        $rtcServerUrl = env('LIVEKIT_HOST', 'wss://livekit.antigravity.internal');
        $token = $this->generateRtcToken($call->room_id, (string) $request->user_id, $user->fullname ?? 'User');

        return response()->json([
            'status' => true,
            'message' => 'Call accepted',
            'data' => [
                'call_uuid' => $call->call_uuid,
                'room_id' => $call->room_id,
                'server_url' => $rtcServerUrl,
                'rtc_token' => $token,
                'status' => 'active',
            ],
        ]);
    }

    /**
     * Reject incoming video call.
     * POST /api/v1/calls/reject
     */
    public function rejectCall(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'call_uuid' => 'required',
            'user_id' => 'required',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $call = Call::where('call_uuid', $request->call_uuid)->first();
        if (!$call) {
            return GlobalFunction::sendSimpleResponse(false, 'Call not found');
        }

        CallParticipant::where('call_id', $call->id)
            ->where('user_id', $request->user_id)
            ->update(['status' => 'rejected', 'left_at' => now()]);

        if ($call->call_type === 'one_to_one') {
            $call->status = 'rejected';
            $call->ended_at = now();
            $call->save();
        }

        return GlobalFunction::sendSimpleResponse(true, 'Call rejected');
    }

    /**
     * End active video call.
     * POST /api/v1/calls/end
     */
    public function endCall(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'call_uuid' => 'required',
            'user_id' => 'required',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $call = Call::where('call_uuid', $request->call_uuid)->first();
        if (!$call) {
            return GlobalFunction::sendSimpleResponse(false, 'Call not found');
        }

        CallParticipant::where('call_id', $call->id)
            ->where('user_id', $request->user_id)
            ->update(['status' => 'left', 'left_at' => now()]);

        // If caller ended or 1-to-1 call, mark call as ended
        if ($call->caller_id == $request->user_id || $call->call_type === 'one_to_one') {
            $call->status = 'ended';
            $call->ended_at = now();
            $call->save();
        }

        return GlobalFunction::sendSimpleResponse(true, 'Call ended successfully');
    }

    /**
     * Fetch call status & participant list.
     * POST /api/v1/calls/status
     */
    public function getCallStatus(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'call_uuid' => 'required',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $call = Call::with(['participants.user', 'participants.avatar'])
            ->where('call_uuid', $request->call_uuid)
            ->first();

        if (!$call) {
            return GlobalFunction::sendSimpleResponse(false, 'Call not found');
        }

        return response()->json([
            'status' => true,
            'message' => 'Call status fetched',
            'data' => $call,
        ]);
    }

    /**
     * Update participant's active avatar in an ongoing call.
     * POST /api/v1/calls/update-avatar
     */
    public function updateCallAvatar(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'call_uuid' => 'required',
            'user_id' => 'required',
            'avatar_mode' => 'required|boolean',
            'avatar_id' => 'nullable',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $call = Call::where('call_uuid', $request->call_uuid)->first();
        if (!$call) {
            return GlobalFunction::sendSimpleResponse(false, 'Call not found');
        }

        $participant = CallParticipant::where('call_id', $call->id)
            ->where('user_id', $request->user_id)
            ->first();

        if ($participant) {
            $participant->avatar_mode = $request->boolean('avatar_mode');
            $participant->avatar_id = $request->avatar_id;
            $participant->save();
        }

        return GlobalFunction::sendSimpleResponse(true, 'Call avatar updated');
    }

    /**
     * Generates a signed WebRTC / LiveKit JWT token for client connection.
     */
    private function generateRtcToken(string $roomName, string $identity, string $displayName): string
    {
        $apiKey = env('LIVEKIT_API_KEY', 'devkey');
        $apiSecret = env('LIVEKIT_API_SECRET', 'secret_key_antigravity_avatar_studio_2026');

        $header = ['alg' => 'HS256', 'typ' => 'JWT'];
        $now = time();
        $exp = $now + 86400; // 24 hours validity

        $payload = [
            'iss' => $apiKey,
            'sub' => $identity,
            'name' => $displayName,
            'nbf' => $now - 5,
            'exp' => $exp,
            'video' => [
                'room' => $roomName,
                'roomJoin' => true,
                'canPublish' => true,
                'canSubscribe' => true,
                'canPublishData' => true,
            ],
        ];

        $base64Header = rtrim(strtr(base64_encode(json_encode($header)), '+/', '-_'), '=');
        $base64Payload = rtrim(strtr(base64_encode(json_encode($payload)), '+/', '-_'), '=');
        $signature = hash_hmac('sha256', "{$base64Header}.{$base64Payload}", $apiSecret, true);
        $base64Signature = rtrim(strtr(base64_encode($signature), '+/', '-_'), '=');

        return "{$base64Header}.{$base64Payload}.{$base64Signature}";
    }

    /**
     * Notify receiver via VoIP push notification.
     */
    private function notifyReceiverOfCall($call, $caller, $receiver)
    {
        try {
            $devices = UserDevice::where('user_id', $receiver->id)->where('is_active', true)->get();
            $callerName = $caller->fullname ?? ($caller->username ?? 'Someone');

            $notificationData = [
                'type' => 'incoming_video_call',
                'call_uuid' => $call->call_uuid,
                'room_id' => $call->room_id,
                'caller_id' => (string) $caller->id,
                'caller_name' => $callerName,
                'call_type' => $call->call_type,
            ];

            // Send push if device token is available on user or registered user_devices
            if (!empty($receiver->device_token)) {
                // Using existing notification channel
                GlobalFunction::sendPushNotificationToAllUsers(
                    "Incoming Avatar Call",
                    "{$callerName} is calling you with an avatar!"
                );
            }
        } catch (\Exception $e) {
            Log::warning('Call push notification failed: ' . $e->getMessage());
        }
    }
}

<?php

namespace App\Http\Controllers;

use App\Models\EncryptedMessageQueue;
use App\Models\GlobalFunction;
use App\Models\Users;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class BlindRelayController extends Controller
{
    public function sendEncryptedMessage(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'message_uid' => 'required|string',
            'sender_id' => 'required|integer',
            'recipient_id' => 'required|integer',
            'device_id' => 'nullable|integer',
            'message_type' => 'required|in:signal_prekey,signal_whisper,voice_blob,media_blob',
            'ciphertext_payload' => 'required|string',
            'iv' => 'required|string',
            'mac' => 'required|string',
            'media_url' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        $msg = EncryptedMessageQueue::updateOrCreate(
            ['message_uid' => $request->message_uid],
            [
                'sender_id' => (int) $request->sender_id,
                'recipient_id' => (int) $request->recipient_id,
                'device_id' => (int) ($request->device_id ?? 1),
                'message_type' => $request->message_type,
                'ciphertext_payload' => $request->ciphertext_payload,
                'iv' => $request->iv,
                'mac' => $request->mac,
                'media_url' => $request->media_url,
                'status' => 'queued',
            ]
        );

        // Attempt push notification trigger if recipient has device token
        $recipient = Users::find($request->recipient_id);
        if ($recipient && !empty($recipient->device_token)) {
            try {
                // WeChat-style blind notification: content is encrypted, alert says "New encrypted message received"
                GlobalFunction::sendPushNotificationToAllUsers(
                    'Hearty Secure',
                    'You received a new encrypted message'
                );
            } catch (\Exception $e) {
                // Non-fatal
            }
        }

        return response()->json([
            'status' => true,
            'message' => 'Encrypted envelope queued for delivery',
            'data' => [
                'message_uid' => $msg->message_uid,
                'status' => $msg->status,
            ],
        ]);
    }

    public function getPendingMessages(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'recipient_id' => 'required|integer',
            'device_id' => 'nullable|integer',
            'limit' => 'nullable|integer|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        $recipientId = (int) $request->recipient_id;
        $deviceId = (int) ($request->device_id ?? 1);
        $limit = (int) ($request->limit ?? 50);

        $messages = EncryptedMessageQueue::where('recipient_id', $recipientId)
            ->where('device_id', $deviceId)
            ->whereIn('status', ['queued', 'delivered'])
            ->orderBy('id', 'asc')
            ->limit($limit)
            ->get();

        // Mark as delivered
        if ($messages->isNotEmpty()) {
            EncryptedMessageQueue::whereIn('id', $messages->pluck('id'))->update(['status' => 'delivered']);
        }

        return response()->json([
            'status' => true,
            'message' => 'Pending encrypted messages retrieved',
            'count' => $messages->count(),
            'data' => $messages,
        ]);
    }

    public function acknowledgeMessage(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'message_uid' => 'required|string',
            'recipient_id' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        // Zero-knowledge retention: once acknowledged by recipient device, purge envelope permanently
        EncryptedMessageQueue::where('message_uid', $request->message_uid)
            ->where('recipient_id', (int) $request->recipient_id)
            ->delete();

        return response()->json([
            'status' => true,
            'message' => 'Message acknowledged and purged from blind relay',
            'message_uid' => $request->message_uid,
        ]);
    }

    public function uploadEncryptedBlob(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'blob' => 'required|file|max:51200', // max 50 MB
            'type' => 'nullable|string', // voice, image, video
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        $file = $request->file('blob');
        $fileName = 'e2ee_' . time() . '_' . bin2hex(random_bytes(8)) . '.enc';
        $path = $file->storeAs('uploads/encrypted', $fileName, 'public');

        return response()->json([
            'status' => true,
            'message' => 'Encrypted blob uploaded successfully',
            'media_url' => 'uploads/encrypted/' . $fileName,
        ]);
    }
}

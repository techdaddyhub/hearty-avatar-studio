<?php

namespace App\Http\Controllers;

use App\Models\OneTimePreKey;
use App\Models\UserPreKey;
use App\Models\Users;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class E2EEKeyController extends Controller
{
    public function publishPreKeys(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|integer',
            'identity_key' => 'required|string',
            'signed_prekey_id' => 'required|integer',
            'signed_prekey' => 'required|string',
            'signed_prekey_signature' => 'required|string',
            'registration_id' => 'required|integer',
            'one_time_prekeys' => 'nullable|array',
            'device_id' => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        $userId = (int) $request->user_id;
        $deviceId = (int) ($request->device_id ?? 1);

        DB::beginTransaction();
        try {
            UserPreKey::updateOrCreate(
                ['user_id' => $userId, 'device_id' => $deviceId],
                [
                    'identity_key' => $request->identity_key,
                    'signed_prekey_id' => $request->signed_prekey_id,
                    'signed_prekey' => $request->signed_prekey,
                    'signed_prekey_signature' => $request->signed_prekey_signature,
                    'registration_id' => $request->registration_id,
                ]
            );

            if ($request->has('one_time_prekeys') && is_array($request->one_time_prekeys)) {
                $otkInserts = [];
                foreach ($request->one_time_prekeys as $otk) {
                    if (isset($otk['key_id']) && isset($otk['public_key'])) {
                        $otkInserts[] = [
                            'user_id' => $userId,
                            'device_id' => $deviceId,
                            'key_id' => (int) $otk['key_id'],
                            'public_key' => $otk['public_key'],
                            'is_consumed' => 0,
                        ];
                    }
                }
                if (!empty($otkInserts)) {
                    OneTimePreKey::insert($otkInserts);
                }
            }

            DB::commit();

            return response()->json([
                'status' => true,
                'message' => 'Cryptographic pre-keys published successfully',
                'unconsumed_otk_count' => OneTimePreKey::where('user_id', $userId)->where('device_id', $deviceId)->where('is_consumed', 0)->count(),
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['status' => false, 'message' => 'Failed to publish keys: ' . $e->getMessage()]);
        }
    }

    public function getPreKeyBundle(Request $request, $userId)
    {
        $targetUserId = (int) $userId;
        $deviceId = (int) ($request->device_id ?? 1);

        $preKey = UserPreKey::where('user_id', $targetUserId)->where('device_id', $deviceId)->first();
        if (!$preKey) {
            return response()->json([
                'status' => false,
                'message' => 'User cryptographic identity not found or not yet initialized',
            ], 404);
        }

        // Atomically claim one unconsumed one-time pre-key
        $oneTimeKey = OneTimePreKey::where('user_id', $targetUserId)
            ->where('device_id', $deviceId)
            ->where('is_consumed', 0)
            ->lockForUpdate()
            ->first();

        if ($oneTimeKey) {
            $oneTimeKey->is_consumed = 1;
            $oneTimeKey->save();
        }

        return response()->json([
            'status' => true,
            'message' => 'PreKey bundle retrieved successfully',
            'data' => [
                'user_id' => $targetUserId,
                'device_id' => $deviceId,
                'registration_id' => $preKey->registration_id,
                'identity_key' => $preKey->identity_key,
                'signed_prekey_id' => $preKey->signed_prekey_id,
                'signed_prekey' => $preKey->signed_prekey,
                'signed_prekey_signature' => $preKey->signed_prekey_signature,
                'one_time_prekey' => $oneTimeKey ? [
                    'key_id' => $oneTimeKey->key_id,
                    'public_key' => $oneTimeKey->public_key,
                ] : null,
            ],
        ]);
    }
}


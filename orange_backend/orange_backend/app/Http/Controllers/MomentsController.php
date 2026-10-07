<?php

namespace App\Http\Controllers;

use App\Models\Contact;
use App\Models\Moment;
use App\Models\MomentKeyEnvelope;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class MomentsController extends Controller
{
    public function publishMoment(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|integer',
            'encrypted_content' => 'required|string',
            'content_iv' => 'required|string',
            'content_mac' => 'required|string',
            'encrypted_media_urls' => 'nullable|array',
            'visibility' => 'nullable|in:all_friends,group_only,private',
            'recipient_envelopes' => 'nullable|array', // array of {recipient_id, encrypted_symmetric_key}
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        $userId = (int) $request->user_id;

        DB::beginTransaction();
        try {
            $moment = Moment::create([
                'user_id' => $userId,
                'encrypted_content' => $request->encrypted_content,
                'content_iv' => $request->content_iv,
                'content_mac' => $request->content_mac,
                'encrypted_media_urls' => $request->encrypted_media_urls ?? [],
                'visibility' => $request->visibility ?? 'all_friends',
            ]);

            // Insert per-recipient symmetric key envelopes
            if ($request->has('recipient_envelopes') && is_array($request->recipient_envelopes)) {
                $envelopes = [];
                foreach ($request->recipient_envelopes as $env) {
                    if (isset($env['recipient_id']) && isset($env['encrypted_symmetric_key'])) {
                        $envelopes[] = [
                            'moment_id' => $moment->id,
                            'recipient_id' => (int) $env['recipient_id'],
                            'encrypted_symmetric_key' => $env['encrypted_symmetric_key'],
                        ];
                    }
                }
                if (!empty($envelopes)) {
                    MomentKeyEnvelope::insert($envelopes);
                }
            }

            DB::commit();

            return response()->json([
                'status' => true,
                'message' => 'Moment published with end-to-end encryption',
                'data' => [
                    'moment_id' => $moment->id,
                    'created_at' => $moment->created_at,
                ],
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['status' => false, 'message' => 'Error: ' . $e->getMessage()]);
        }
    }

    public function getFeed(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|integer',
            'limit' => 'nullable|integer|max:50',
            'offset' => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        $userId = (int) $request->user_id;
        $limit = (int) ($request->limit ?? 20);
        $offset = (int) ($request->offset ?? 0);

        // Fetch moments authored by user OR where user has a key envelope
        $moments = Moment::where(function ($q) use ($userId) {
                $q->where('user_id', $userId)
                  ->orWhereHas('keyEnvelopes', function ($sub) use ($userId) {
                      $sub->where('recipient_id', $userId);
                  });
            })
            ->with(['user', 'keyEnvelopes' => function ($q) use ($userId) {
                $q->where('recipient_id', $userId);
            }])
            ->orderBy('id', 'desc')
            ->offset($offset)
            ->limit($limit)
            ->get()
            ->map(function ($m) use ($userId) {
                $isAuthor = $m->user_id === $userId;
                $envelope = $m->keyEnvelopes->first();

                return [
                    'moment_id' => $m->id,
                    'author_id' => $m->user_id,
                    'author_name' => $m->user->fullname ?? $m->user->username ?? 'User',
                    'author_avatar' => $m->user->images->first()->image ?? 'uploads/user_tester.png',
                    'encrypted_content' => $m->encrypted_content,
                    'content_iv' => $m->content_iv,
                    'content_mac' => $m->content_mac,
                    'encrypted_media_urls' => $m->encrypted_media_urls,
                    'is_author' => $isAuthor,
                    // The symmetric key envelope for this user to decrypt the moment
                    'encrypted_symmetric_key' => $envelope ? $envelope->encrypted_symmetric_key : null,
                    'created_at' => $m->created_at,
                ];
            });

        return response()->json([
            'status' => true,
            'message' => 'Moments feed retrieved',
            'count' => $moments->count(),
            'data' => $moments,
        ]);
    }
}

<?php

namespace App\Http\Controllers;

use App\Models\GlobalFunction;
use App\Models\SocialAccount;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SocialAccountController extends Controller
{
    /**
     * Fetch connected social accounts for a user.
     * POST /api/v1/social-accounts/list
     */
    public function fetchAccounts(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $accounts = SocialAccount::where('user_id', $request->user_id)
            ->where('is_connected', true)
            ->get()
            ->makeHidden(['access_token_encrypted', 'refresh_token_encrypted']);

        // Return status summary for standard platforms
        $platforms = ['youtube', 'facebook', 'tiktok', 'instagram'];
        $connectedMap = [];

        foreach ($platforms as $plat) {
            $matched = $accounts->firstWhere('platform', $plat);
            $connectedMap[$plat] = [
                'platform' => $plat,
                'is_connected' => (bool) $matched,
                'account_name' => $matched ? $matched->account_name : null,
                'channel_title' => $matched ? $matched->channel_title : null,
                'account_id' => $matched ? $matched->account_id : null,
            ];
        }

        return response()->json([
            'status' => true,
            'message' => 'Social accounts fetched',
            'data' => [
                'accounts' => $accounts,
                'platform_status' => $connectedMap,
            ],
        ]);
    }

    /**
     * Connect or update a social account.
     * POST /api/v1/social-accounts/connect
     */
    public function connectAccount(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
            'platform' => 'required|in:youtube,facebook,tiktok,instagram',
            'account_name' => 'required|string',
            'account_id' => 'nullable|string',
            'channel_title' => 'nullable|string',
            'access_token' => 'nullable|string',
            'refresh_token' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $account = SocialAccount::firstOrNew([
            'user_id' => $request->user_id,
            'platform' => $request->platform,
        ]);

        $account->account_name = $request->account_name;
        $account->account_id = $request->account_id;
        $account->channel_title = $request->channel_title ?? $request->account_name;
        if ($request->has('access_token')) {
            $account->access_token = $request->access_token;
        }
        if ($request->has('refresh_token')) {
            $account->refresh_token = $request->refresh_token;
        }
        $account->is_connected = true;
        $account->save();

        return response()->json([
            'status' => true,
            'message' => 'Social account connected successfully',
            'data' => [
                'id' => $account->id,
                'platform' => $account->platform,
                'account_name' => $account->account_name,
                'channel_title' => $account->channel_title,
                'is_connected' => true,
            ],
        ]);
    }

    /**
     * Disconnect a social account.
     * POST /api/v1/social-accounts/disconnect
     */
    public function disconnectAccount(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
            'platform' => 'required|in:youtube,facebook,tiktok,instagram',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $account = SocialAccount::where('user_id', $request->user_id)
            ->where('platform', $request->platform)
            ->first();

        if ($account) {
            $account->is_connected = false;
            $account->access_token = null;
            $account->refresh_token = null;
            $account->save();
        }

        return GlobalFunction::sendSimpleResponse(true, 'Social account disconnected');
    }
}

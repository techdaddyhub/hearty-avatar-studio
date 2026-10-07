<?php

namespace App\Http\Controllers;

use App\Models\MiniProgram;
use Illuminate\Http\Request;

class MiniProgramController extends Controller
{
    public function getMiniPrograms(Request $request)
    {
        $programs = MiniProgram::where('is_active', 1)->get();

        // If none seeded, supply default built-in mini programs
        if ($programs->isEmpty()) {
            $defaultPrograms = [
                [
                    'app_id' => 'mp_hearty_planner',
                    'name' => 'Date & Event Planner',
                    'icon_url' => 'https://hearty.dmillers.org/public/asset/img/hearty_icon.png',
                    'entry_url' => 'https://hearty.dmillers.org/mini-programs/date-planner/index.html',
                    'package_hash' => 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                    'permissions' => ['getUserProfile', 'shareToChat', 'vibrateShort'],
                    'is_active' => 1,
                ],
                [
                    'app_id' => 'mp_hearty_games',
                    'name' => 'Icebreaker Games',
                    'icon_url' => 'https://hearty.dmillers.org/public/asset/img/hearty_heart_emblem.png',
                    'entry_url' => 'https://hearty.dmillers.org/mini-programs/icebreaker/index.html',
                    'package_hash' => 'd41d8cd98f00b204e9800998ecf8427e',
                    'permissions' => ['getUserProfile', 'shareToChat'],
                    'is_active' => 1,
                ],
            ];

            foreach ($defaultPrograms as $prog) {
                MiniProgram::create($prog);
            }

            $programs = MiniProgram::where('is_active', 1)->get();
        }

        return response()->json([
            'status' => true,
            'message' => 'Mini programs retrieved',
            'data' => $programs,
        ]);
    }

    public function getMiniProgramDetail(Request $request, $appId)
    {
        $program = MiniProgram::where('app_id', $appId)->first();
        if (!$program) {
            return response()->json(['status' => false, 'message' => 'Mini program not found'], 404);
        }

        return response()->json([
            'status' => true,
            'message' => 'Mini program details retrieved',
            'data' => $program,
        ]);
    }
}


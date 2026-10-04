<?php

namespace App\Http\Controllers;

use App\Models\Avatar;
use App\Models\AvatarAsset;
use App\Models\GlobalFunction;
use App\Models\Users;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\File;

class AvatarController extends Controller
{
    /**
     * Fetch all avatars created by or assigned to a user.
     */
    public function fetchUserAvatars(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $userId = $request->user_id;

        $userAvatars = Avatar::with('assets')
            ->where('user_id', $userId)
            ->where('is_active', true)
            ->orderBy('is_default', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();

        // Also return system presets
        $presets = $this->getSystemPresets();

        return response()->json([
            'status' => true,
            'message' => 'Avatars fetched successfully',
            'data' => [
                'user_avatars' => $userAvatars,
                'preset_avatars' => $presets,
            ],
        ]);
    }

    /**
     * Create or update an avatar.
     */
    public function saveAvatar(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
            'name' => 'required|string|max:255',
            'type' => 'required|in:2d,3d,ai_photo,vrm,preset',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $userId = $request->user_id;
        $avatarId = $request->avatar_id;

        $configData = $request->config_json;
        if (is_string($configData)) {
            $configData = json_decode($configData, true);
        }

        if ($avatarId) {
            $avatar = Avatar::where('id', $avatarId)->where('user_id', $userId)->first();
            if (!$avatar) {
                return GlobalFunction::sendSimpleResponse(false, 'Avatar not found');
            }
        } else {
            $avatar = new Avatar();
            $avatar->user_id = $userId;
        }

        $avatar->name = $request->name;
        $avatar->type = $request->type;
        if ($request->has('thumbnail_url')) {
            $avatar->thumbnail_url = $request->thumbnail_url;
        }
        if ($request->has('model_url')) {
            $avatar->model_url = $request->model_url;
        }
        if ($configData !== null) {
            $avatar->config_json = $configData;
        }

        if ($request->boolean('is_default')) {
            Avatar::where('user_id', $userId)->update(['is_default' => false]);
            $avatar->is_default = true;
        }

        $avatar->save();

        return response()->json([
            'status' => true,
            'message' => 'Avatar saved successfully',
            'data' => $avatar->load('assets'),
        ]);
    }

    /**
     * Upload an avatar model, texture, or photo asset.
     */
    public function uploadAvatarAsset(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
            'file' => 'required|file',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $file = $request->file('file');
        $storedPath = GlobalFunction::saveFileAndGivePath($file);
        $fullUrl = GlobalFunction::createMediaUrl($storedPath);
        $fileSize = $file->getSize();
        $mimeType = $file->getClientMimeType();

        $assetData = [
            'stored_path' => $storedPath,
            'url' => $fullUrl,
            'file_size' => $fileSize,
            'mime_type' => $mimeType,
        ];

        // If avatar_id is provided, attach directly as AvatarAsset
        if ($request->has('avatar_id') && !empty($request->avatar_id)) {
            $asset = AvatarAsset::create([
                'avatar_id' => $request->avatar_id,
                'asset_type' => $request->input('asset_type', 'mesh'),
                'file_path' => $storedPath,
                'file_size' => $fileSize,
                'mime_type' => $mimeType,
            ]);
            $assetData['asset_id'] = $asset->id;
        }

        return response()->json([
            'status' => true,
            'message' => 'Asset uploaded successfully',
            'data' => $assetData,
        ]);
    }

    /**
     * Set default active avatar.
     */
    public function setDefaultAvatar(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
            'avatar_id' => 'required',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        Avatar::where('user_id', $request->user_id)->update(['is_default' => false]);
        $avatar = Avatar::where('user_id', $request->user_id)->where('id', $request->avatar_id)->first();

        if (!$avatar) {
            return GlobalFunction::sendSimpleResponse(false, 'Avatar not found');
        }

        $avatar->is_default = true;
        $avatar->save();

        return response()->json([
            'status' => true,
            'message' => 'Default avatar updated',
            'data' => $avatar,
        ]);
    }

    /**
     * Delete an avatar.
     */
    public function deleteAvatar(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
            'avatar_id' => 'required',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $avatar = Avatar::where('user_id', $request->user_id)->where('id', $request->avatar_id)->first();
        if (!$avatar) {
            return GlobalFunction::sendSimpleResponse(false, 'Avatar not found');
        }

        // Clean up stored files if local
        if ($avatar->model_url) {
            GlobalFunction::deleteFile($avatar->model_url);
        }
        foreach ($avatar->assets as $asset) {
            GlobalFunction::deleteFile($asset->file_path);
            $asset->delete();
        }

        $avatar->delete();

        return GlobalFunction::sendSimpleResponse(true, 'Avatar deleted successfully');
    }

    /**
     * Preset system avatars available to all users.
     */
    private function getSystemPresets()
    {
        return [
            [
                'id' => 'preset_cyber_fox',
                'name' => 'Cyber Fox',
                'type' => '2d',
                'thumbnail_url' => url('public/assets/avatars/cyber_fox.png'),
                'model_url' => 'assets/avatars/cyber_fox.json',
                'description' => 'Futuristic neon cyber fox with expressive ears and eye tracking.',
                'config_json' => [
                    'rig' => '2.5d_quad',
                    'head_inertia' => 0.85,
                    'blink_rate_hz' => 0.25,
                    'viseme_amplification' => 1.2,
                    'blend_shapes' => [
                        'eye_blink_left' => 1.0,
                        'eye_blink_right' => 1.0,
                        'mouth_open' => 1.0,
                        'mouth_smile' => 0.8,
                        'ear_twitch' => 0.5,
                    ],
                ],
                'is_default' => true,
            ],
            [
                'id' => 'preset_anime_luna',
                'name' => 'Luna Star',
                'type' => '3d',
                'thumbnail_url' => url('public/assets/avatars/anime_luna.png'),
                'model_url' => 'assets/avatars/anime_luna.vrm',
                'description' => 'Cel-shaded anime VTuber model with complete VRM blend shapes.',
                'config_json' => [
                    'rig' => 'vrm_humanoid',
                    'spring_bones' => true,
                    'hair_physics' => 0.9,
                    'viseme_amplification' => 1.0,
                    'blend_shapes' => [
                        'A' => 1.0, 'I' => 1.0, 'U' => 1.0, 'E' => 1.0, 'O' => 1.0,
                        'Blink' => 1.0, 'Joy' => 0.9, 'Sorrow' => 0.7, 'Angry' => 0.8,
                    ],
                ],
                'is_default' => false,
            ],
            [
                'id' => 'preset_ai_executive',
                'name' => 'Nexus Executive',
                'type' => 'ai_photo',
                'thumbnail_url' => url('public/assets/avatars/nexus_exec.png'),
                'model_url' => 'assets/avatars/nexus_exec.png',
                'description' => 'Hyper-realistic AI photorealistic presenter with neural puppeteering.',
                'config_json' => [
                    'rig' => 'neural_mesh_68_points',
                    'head_dof' => 6,
                    'lip_sync_accuracy' => 'phoneme_realtime',
                    'micro_expressions' => true,
                    'blend_shapes' => [
                        'jaw_open' => 1.0,
                        'mouth_pucker' => 1.0,
                        'brow_inner_up' => 0.7,
                        'eye_blink' => 1.0,
                    ],
                ],
                'is_default' => false,
            ],
            [
                'id' => 'preset_pixel_cat',
                'name' => 'Pixel Neko',
                'type' => '2d',
                'thumbnail_url' => url('public/assets/avatars/pixel_cat.png'),
                'model_url' => 'assets/avatars/pixel_cat.json',
                'description' => 'Retro 16-bit arcade cat with bounce physics and reactive visemes.',
                'config_json' => [
                    'rig' => 'pixel_sprite_sheet',
                    'fps' => 30,
                    'viseme_amplification' => 1.4,
                ],
                'is_default' => false,
            ],
        ];
    }

    /**
     * Admin view for Avatar Studio Management.
     */
    public function adminIndex()
    {
        $totalAvatars = Avatar::count();
        $total3D = Avatar::where('type', '3d')->orWhere('type', 'vrm')->count();
        $total2D = Avatar::where('type', '2d')->count();
        $totalAI = Avatar::where('type', 'ai_photo')->count();

        return view('avatars', compact('totalAvatars', 'total3D', 'total2D', 'totalAI'));
    }

    /**
     * DataTables AJAX endpoint for admin avatars list.
     */
    public function fetchAvatarsAdmin(Request $request)
    {
        $columns = ['id', 'thumbnail_url', 'name', 'type', 'gender', 'style', 'is_default', 'is_active', 'created_at', 'action'];

        $totalData = Avatar::count();
        $totalFiltered = $totalData;

        $limit = $request->input('length', 10);
        $start = $request->input('start', 0);
        $orderIndex = $request->input('order.0.column', 0);
        $order = $columns[$orderIndex] ?? 'id';
        $dir = $request->input('order.0.dir', 'desc');

        $query = Avatar::with('user');

        if (!empty($request->input('search.value'))) {
            $search = $request->input('search.value');
            $query->where(function ($q) use ($search) {
                $q->where('name', 'LIKE', "%{$search}%")
                  ->orWhere('type', 'LIKE', "%{$search}%")
                  ->orWhere('style', 'LIKE', "%{$search}%");
            });
            $totalFiltered = $query->count();
        }

        $avatars = $query->offset($start)
            ->limit($limit)
            ->orderBy($order == 'action' ? 'id' : $order, $dir)
            ->get();

        $data = [];
        foreach ($avatars as $item) {
            $thumb = $item->thumbnail_url 
                ? (str_starts_with($item->thumbnail_url, 'http') ? $item->thumbnail_url : url('public/storage/' . $item->thumbnail_url))
                : url('asset/img/avatar/avatar-1.png');
            
            $imgHtml = '<img src="' . $thumb . '" class="rounded-circle mr-2" width="45" height="45" style="object-fit:cover; border: 2px solid #6777ef;">';
            $nameHtml = '<div><strong>' . htmlspecialchars($item->name) . '</strong><br><small class="text-muted">' . ($item->user->fullname ?? 'System Preset') . '</small></div>';
            
            $typeBadge = match($item->type) {
                '3d', 'vrm' => '<span class="badge badge-primary">3D Model</span>',
                'ai_photo' => '<span class="badge badge-warning">AI Neural</span>',
                '2d' => '<span class="badge badge-info">2D Sprite</span>',
                default => '<span class="badge badge-secondary">' . htmlspecialchars($item->type) . '</span>'
            };

            $statusBadge = $item->is_active
                ? '<button onclick="toggleAvatarStatus(' . $item->id . ')" class="btn btn-sm btn-outline-success"><i class="fas fa-check-circle"></i> Active</button>'
                : '<button onclick="toggleAvatarStatus(' . $item->id . ')" class="btn btn-sm btn-outline-danger"><i class="fas fa-ban"></i> Disabled</button>';

            $defaultBadge = $item->is_default
                ? '<span class="badge badge-success"><i class="fas fa-star"></i> Default</span>'
                : '<span class="text-muted">-</span>';

            $action = '<button onclick="deleteAvatar(' . $item->id . ')" class="btn btn-sm btn-danger text-white"><i class="fas fa-trash"></i> Delete</button>';

            $data[] = [
                $item->id,
                $imgHtml,
                $nameHtml,
                $typeBadge,
                ucfirst($item->gender ?? 'unspecified'),
                ucfirst($item->style ?? 'default'),
                $defaultBadge,
                $statusBadge,
                $item->created_at ? $item->created_at->format('Y-m-d') : '-',
                $action
            ];
        }

        return response()->json([
            "draw" => intval($request->input('draw')),
            "recordsTotal" => intval($totalData),
            "recordsFiltered" => intval($totalFiltered),
            "data" => $data
        ]);
    }

    /**
     * Admin toggle avatar active status.
     */
    public function adminToggleAvatarStatus(Request $request)
    {
        $avatar = Avatar::findOrFail($request->avatar_id);
        $avatar->is_active = !$avatar->is_active;
        $avatar->save();

        return response()->json([
            'status' => true,
            'message' => 'Avatar status toggled successfully',
            'is_active' => $avatar->is_active
        ]);
    }

    /**
     * Admin delete avatar.
     */
    public function adminDeleteAvatar(Request $request)
    {
        $avatar = Avatar::findOrFail($request->avatar_id);
        $avatar->delete();

        return response()->json([
            'status' => true,
            'message' => 'Avatar deleted successfully'
        ]);
    }

    /**
     * Admin add new system avatar.
     */
    public function adminAddAvatar(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'type' => 'required|in:2d,3d,ai_photo,vrm,preset',
            'gender' => 'nullable|string',
            'style' => 'nullable|string',
            'thumbnail' => 'nullable|image|max:10240',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        $avatar = new Avatar();
        $avatar->user_id = null; // System preset
        $avatar->name = $request->name;
        $avatar->type = $request->type;
        $avatar->gender = $request->gender ?? 'neutral';
        $avatar->style = $request->style ?? 'realistic';
        $avatar->is_default = $request->boolean('is_default', false);
        $avatar->is_active = true;

        if ($request->hasFile('thumbnail')) {
            $avatar->thumbnail_url = GlobalFunction::saveFileAndGivePath($request->file('thumbnail'));
        }

        $avatar->save();

        return response()->json(['status' => true, 'message' => 'Avatar added successfully']);
    }
}


<?php

namespace App\Http\Controllers;

use App\Models\GlobalFunction;
use App\Models\Stream;
use App\Models\StreamDestination;
use App\Models\Users;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class StreamController extends Controller
{
    /**
     * Create a new live stream broadcast session.
     * POST /api/v1/streams/create
     */
    public function createStream(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'avatar_id' => 'nullable',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $userId = $request->user_id;
        $streamUuid = (string) Str::uuid();
        $streamKey = 'live_' . substr(md5($streamUuid . microtime()), 0, 24);
        $ingressUrl = env('STREAM_INGRESS_URL', 'rtmp://stream.antigravity.internal/live');

        $stream = Stream::create([
            'stream_uuid' => $streamUuid,
            'user_id' => $userId,
            'title' => $request->title,
            'description' => $request->description,
            'avatar_id' => $request->avatar_id,
            'status' => 'idle',
            'ingress_url' => $ingressUrl,
            'stream_key' => $streamKey,
            'viewer_count' => 0,
            'peak_viewers' => 0,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Stream session created',
            'data' => $stream->load(['destinations', 'avatar']),
        ]);
    }

    /**
     * Fetch stream session details.
     * POST /api/v1/streams/details
     */
    public function getStreamDetails(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'stream_uuid' => 'required',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $stream = Stream::with(['destinations', 'avatar', 'user'])
            ->where('stream_uuid', $request->stream_uuid)
            ->first();

        if (!$stream) {
            return GlobalFunction::sendSimpleResponse(false, 'Stream session not found');
        }

        return response()->json([
            'status' => true,
            'message' => 'Stream details fetched',
            'data' => $stream,
        ]);
    }

    /**
     * Update stream status (idle, live, ended).
     * POST /api/v1/streams/update-status
     */
    public function updateStreamStatus(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'stream_uuid' => 'required',
            'status' => 'required|in:idle,live,ended',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $stream = Stream::where('stream_uuid', $request->stream_uuid)->first();
        if (!$stream) {
            return GlobalFunction::sendSimpleResponse(false, 'Stream session not found');
        }

        $stream->status = $request->status;
        if ($request->status === 'live' && !$stream->started_at) {
            $stream->started_at = now();
        } elseif ($request->status === 'ended') {
            $stream->ended_at = now();
        }
        $stream->save();

        return response()->json([
            'status' => true,
            'message' => 'Stream status updated',
            'data' => $stream,
        ]);
    }

    /**
     * Add an RTMP stream destination (YouTube, Facebook, TikTok, Custom RTMP).
     * POST /api/v1/streams/add-destination
     */
    public function addStreamDestination(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'stream_id' => 'required',
            'user_id' => 'required',
            'platform' => 'required|in:youtube,facebook,tiktok,custom_rtmp',
            'destination_name' => 'required|string|max:100',
            'rtmp_url' => 'required|string',
            'stream_key' => 'required|string',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $destination = new StreamDestination();
        $destination->stream_id = $request->stream_id;
        $destination->user_id = $request->user_id;
        $destination->platform = $request->platform;
        $destination->destination_name = $request->destination_name;
        $destination->rtmp_url = $request->rtmp_url;
        $destination->stream_key = $request->stream_key; // encrypted via mutator
        $destination->is_enabled = $request->boolean('is_enabled', true);
        $destination->status = 'idle';
        $destination->save();

        return response()->json([
            'status' => true,
            'message' => 'Destination added successfully',
            'data' => [
                'id' => $destination->id,
                'stream_id' => $destination->stream_id,
                'platform' => $destination->platform,
                'destination_name' => $destination->destination_name,
                'rtmp_url' => $destination->rtmp_url,
                'is_enabled' => $destination->is_enabled,
                'status' => $destination->status,
            ],
        ]);
    }

    /**
     * Toggle destination on or off.
     * POST /api/v1/streams/toggle-destination
     */
    public function toggleDestination(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'destination_id' => 'required',
            'is_enabled' => 'required|boolean',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $destination = StreamDestination::find($request->destination_id);
        if (!$destination) {
            return GlobalFunction::sendSimpleResponse(false, 'Destination not found');
        }

        $destination->is_enabled = $request->boolean('is_enabled');
        $destination->save();

        return GlobalFunction::sendSimpleResponse(true, 'Destination updated');
    }

    /**
     * Remove an RTMP stream destination.
     * POST /api/v1/streams/remove-destination
     */
    public function removeStreamDestination(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'destination_id' => 'required',
        ]);

        if ($validator->fails()) {
            return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
        }

        $destination = StreamDestination::find($request->destination_id);
        if ($destination) {
            $destination->delete();
        }

        return GlobalFunction::sendSimpleResponse(true, 'Destination removed');
    }

    /**
     * Admin view for Avatar Studio Broadcasts & Relays.
     */
    public function adminIndex()
    {
        $activeStreamsCount = Stream::where('status', 'live')->count();
        $totalStreamsCount = Stream::count();
        $destinationsCount = StreamDestination::count();

        return view('avatarStreams', compact('activeStreamsCount', 'totalStreamsCount', 'destinationsCount'));
    }

    /**
     * DataTables AJAX endpoint for admin stream list.
     */
    public function fetchStreamsAdmin(Request $request)
    {
        $columns = ['id', 'user_id', 'title', 'status', 'resolution', 'fps', 'bitrate_kbps', 'destinations', 'started_at', 'action'];

        $totalData = Stream::count();
        $totalFiltered = $totalData;

        $limit = $request->input('length', 10);
        $start = $request->input('start', 0);
        $orderIndex = $request->input('order.0.column', 0);
        $order = $columns[$orderIndex] ?? 'id';
        $dir = $request->input('order.0.dir', 'desc');

        $query = Stream::with(['user', 'destinations', 'avatar']);

        if (!empty($request->input('search.value'))) {
            $search = $request->input('search.value');
            $query->where(function ($q) use ($search) {
                $q->where('title', 'LIKE', "%{$search}%")
                  ->orWhere('stream_key', 'LIKE', "%{$search}%");
            });
            $totalFiltered = $query->count();
        }

        $streams = $query->offset($start)
            ->limit($limit)
            ->orderBy($order == 'action' || $order == 'destinations' ? 'id' : $order, $dir)
            ->get();

        $data = [];
        foreach ($streams as $item) {
            $hostName = $item->user->fullname ?? ($item->user->username ?? 'Host User');
            $hostHtml = '<strong>' . htmlspecialchars($hostName) . '</strong><br><small class="text-muted">UID: ' . $item->user_id . '</small>';

            $statusBadge = $item->status === 'live'
                ? '<span class="badge badge-danger"><i class="fas fa-circle blink"></i> LIVE</span>'
                : '<span class="badge badge-secondary">' . strtoupper($item->status) . '</span>';

            $destHtml = '';
            foreach ($item->destinations as $dest) {
                $destHtml .= match($dest->platform) {
                    'youtube' => '<span class="badge badge-danger mr-1"><i class="fab fa-youtube"></i> YT</span>',
                    'facebook' => '<span class="badge badge-primary mr-1"><i class="fab fa-facebook"></i> FB</span>',
                    'tiktok' => '<span class="badge badge-dark mr-1"><i class="fab fa-tiktok"></i> TT</span>',
                    default => '<span class="badge badge-info mr-1"><i class="fas fa-satellite-dish"></i> RTMP</span>'
                };
            }
            if (empty($destHtml)) $destHtml = '<span class="text-muted">Direct</span>';

            $qualityHtml = '<span class="badge badge-light">' . ($item->resolution ?? '1080p') . ' @ ' . ($item->fps ?? 60) . 'fps</span>';
            $bitrateHtml = '<span class="text-muted">' . ($item->bitrate_kbps ? $item->bitrate_kbps . ' kbps' : '4500 kbps') . '</span>';

            $action = $item->status === 'live'
                ? '<button onclick="endStreamAdmin(' . $item->id . ')" class="btn btn-sm btn-danger"><i class="fas fa-stop"></i> End Stream</button>'
                : '<span class="text-muted">Completed</span>';

            $data[] = [
                $item->id,
                $hostHtml,
                htmlspecialchars($item->title ?? 'Untitled Broadcast'),
                $statusBadge,
                $qualityHtml,
                $item->fps ?? 60,
                $bitrateHtml,
                $destHtml,
                $item->started_at ? $item->started_at->format('Y-m-d H:i') : '-',
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
     * Admin terminate live stream.
     */
    public function adminEndStream(Request $request)
    {
        $stream = Stream::findOrFail($request->stream_id);
        $stream->status = 'ended';
        $stream->ended_at = now();
        $stream->save();

        return response()->json([
            'status' => true,
            'message' => 'Stream ended successfully'
        ]);
    }
}


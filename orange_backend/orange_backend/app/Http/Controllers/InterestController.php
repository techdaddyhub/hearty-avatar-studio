<?php

namespace App\Http\Controllers;

use App\Models\Interest;
use App\Models\Myfunction;
use Illuminate\Http\Request;

class InterestController extends Controller
{
    public function fetchAllInterest(Request $request)
    {
        $columns = [
            0 => 'id',
            1 => 'title'
        ];

        $limit = $request->input('length');
        $start = $request->input('start');
        $orderColumnIndex = $request->input('order.0.column', 0);
        $orderColumn = $columns[$orderColumnIndex] ?? 'id';
        $orderDir = $request->input('order.0.dir', 'desc');
        $searchValue = $request->input('search.value');

        $query = Interest::where('is_deleted', 0);

        $totalData = $query->count();

        if (!empty($searchValue)) {
            $query->where(function ($q) use ($searchValue) {
                $q->where('title', 'LIKE', "%{$searchValue}%")
                    ->orWhere('id', 'LIKE', "%{$searchValue}%");
            });
        }

        $totalFiltered = $query->count();

        $categories = $query
            ->orderBy($orderColumn, $orderDir)
            ->offset($start)
            ->limit($limit)
            ->get();

        $data = [];
        foreach ($categories as $cat) {
            $editBtn = '<a href="" data-toggle="modal" id="' . $cat->id . '" rel="' . $cat->id . '" data-title="' . e($cat->title) . '" class="btn btn-success mr-2 edit">Edit</a>';
            $deleteBtn = '<a rel="' . $cat->id . '" class="btn btn-danger delete text-white">Delete</a>';
            $action = '<span class="float-end">' . $editBtn . $deleteBtn . '</span>';

            $data[] = [
                e($cat->title),
                $action
            ];
        }

        return response()->json([
            'draw'            => intval($request->input('draw')),
            'recordsTotal'    => $totalData,
            'recordsFiltered' => $totalFiltered,
            'data'            => $data
        ]);
    }

    public function addInterest(Request $req)
    {
        $req->validate([
            'title' => 'required|string|max:255',
        ]);

        $cleanTitle = Myfunction::customReplace($req->title);

        $deletedInterest = Interest::where('title', $cleanTitle)
            ->where('is_deleted', 1)
            ->first();

        if ($deletedInterest) {
            $deletedInterest->is_deleted = 0;
            $deletedInterest->save();

            return response()->json([
                'status' => true,
                'message' => 'Interest restored successfully!',
                'data' => $deletedInterest
            ]);
        }

        $existingInterest = Interest::where('title', $cleanTitle)
            ->where('is_deleted', 0)
            ->first();

        if ($existingInterest) {
            return response()->json([
                'status' => false,
                'message' => 'This interest already exists.',
            ]);
        }

        $interest = new Interest();
        $interest->title = $cleanTitle;
        $interest->is_deleted = 0; // default status
        $interest->save();

        return response()->json([
            'status' => true,
            'message' => 'Interest added successfully!',
            'data' => $interest
        ]);
    }

    public function updateInterest(Request $request)
    {
        $request->validate([
            'interest_id' => 'required|integer|exists:interests,id',
            'title' => 'required|string|max:255',
        ]);

        $interest = Interest::where('id', $request->interest_id)->where('is_deleted', 0)->first();

        if (!$interest) {
            return response()->json([
                'status' => false,
                'message' => 'Interest not found or has been deleted.',
            ], 404);
        }

        $existing = Interest::where('title', $request->title)
            ->where('id', '!=', $request->interest_id)
            ->where('is_deleted', 0)
            ->first();

        if ($existing) {
            return response()->json([
                'status' => false,
                'message' => 'An interest with this title already exists.',
            ]);
        }

        $interest->title = $request->title;
        $interest->save();

        return response()->json([
            'status' => true,
            'message' => 'Interest updated successfully.',
            'data' => $interest,
        ]);
    }

    public function deleteInterest(Request $request)
    {
        $request->validate([
            'interest_id' => 'required|integer|exists:interests,id',
        ]);

        $interest = Interest::where('id', $request->interest_id)->first();

        if (!$interest) {
            return response()->json([
                'status' => false,
                'message' => 'Interest not found.',
            ]);
        }

        $interest->is_deleted = 1;
        $interest->save();

        return response()->json([
            'status' => true,
            'message' => 'Interest deleted successfully.',
        ]);
    }
}

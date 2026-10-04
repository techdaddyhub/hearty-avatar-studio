<?php

namespace App\Http\Controllers;

use App\Models\GlobalFunction;
use App\Models\RelationshipGoal;
use Illuminate\Http\Request;

class RelationshipGoalController extends Controller
{
    public function relationshipGoalList(Request $request)
    {
        $query = RelationshipGoal::where('is_deleted', 0);
        $totalData = $query->count();

        $columns = 'id';
        $orderDir = 'desc';
        $limit = $request->input('length');
        $start = $request->input('start');
        $orderColumn = $columns;
        $searchValue = $request->input('search.value');

        if (!empty($searchValue)) {
            $query->where(function ($q) use ($searchValue) {
                $q->where('title', 'LIKE', "%{$searchValue}%")
                    ->orWhere('description', 'LIKE', "%{$searchValue}%");
            });
        }

        $totalFiltered = $query->count();

        $result = $query->orderBy($orderColumn, $orderDir)
            ->offset($start)
            ->limit($limit)
            ->get();

        $data = $result->map(function ($item) {

            $info = "<div class='text-body m-0 d-inline-block align-middle font-16'>
                        <span class='text-dark mt-0 fs-6'>{$item->title}</span>
                        <p class='mb-0 fs-6 text-muted fw-normal'>{$item->description}</p>
                    </div>";

            $action = '<a rel="' . $item->id . '" 
                     data-title="' . $item->title . '"
                     data-description="' . $item->description . '"
                    class="btn btn-success edit text-white mr-2">
                    Edit
                    </a>
                    <a rel="' . $item->id . '"
                    class="btn btn-danger delete text-white">
                    Delete
                    </a>';

            return [
                $info,
                $action
            ];
        });

        $json_data = [
            "draw" => intval($request->input('draw')),
            "recordsTotal" => intval($totalData),
            "recordsFiltered" => intval($totalFiltered),
            "data" => $data,
        ];

        return response()->json($json_data);
    }

    public function addRelationshipGoal(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
        ]);

        $relationshipGoal = RelationshipGoal::where('title', $request->title)->where('is_deleted', 1)->first();

        if ($relationshipGoal) {
            $relationshipGoal->is_deleted = 0;
            $relationshipGoal->description = $request->description;
            $relationshipGoal->save();

            return GlobalFunction::sendDataResponse(true, 'Relationship Goal restored and updated successfully!', $relationshipGoal);
        }

        $existingGoal = RelationshipGoal::where('title', $request->title)->where('is_deleted', 0)->first();

        if ($existingGoal) {
            return GlobalFunction::sendSimpleResponse(false, 'Relationship goal with this title already exists. Please choose a different title.');
        }

        $relationshipGoal = RelationshipGoal::create([
            'title' => $request->title,
            'description' => $request->description,
        ]);

        return GlobalFunction::sendDataResponse(true, 'Relationship Goal added successfully!', $relationshipGoal);
    }

    public function updateRelationshipGoal(Request $request)
    {
        $request->validate([
            'relationship_goal_id' => 'required|integer|exists:relationship_goals,id',
            'title' => 'nullable|string|max:255',
            'description' => 'nullable|string',
        ]);

        $relationshipGoal = RelationshipGoal::find($request->relationship_goal_id);

        if (!$relationshipGoal) {
            return GlobalFunction::sendSimpleResponse(false, 'Relationship Goal not found.');
        }

        if ($request->has('title')) {
            $existingGoal = RelationshipGoal::where('title', $request->title)
                ->where('id', '!=', $request->relationship_goal_id) // exclude current record
                ->where('is_deleted', 0)
                ->first();

            if ($existingGoal) {
                return GlobalFunction::sendSimpleResponse(false, 'Another Relationship Goal with this title already exists.');
            }

            $softDeletedGoal = RelationshipGoal::where('title', $request->title)
                ->where('id', '!=', $request->relationship_goal_id)
                ->where('is_deleted', 1)
                ->first();

            if ($softDeletedGoal) {
                return GlobalFunction::sendSimpleResponse(false, 'This title exists in a soft-deleted record. Please choose a different title.');
            }

            $relationshipGoal->title = $request->title;
        }

        if ($request->has('description')) {
            $relationshipGoal->description = $request->description;
        }

        $relationshipGoal->save();

        return GlobalFunction::sendDataResponse(true, 'Relationship Goal Updated Successfully!', $relationshipGoal);
    }

    public function deleteRelationshipGoal(Request $request)
    {
        $relationshipGoal = RelationshipGoal::find($request->relationship_goal_id);
        $relationshipGoal->is_deleted = 1;
        $relationshipGoal->save();

        return GlobalFunction::sendSimpleResponse(true, 'Relationship Goal Deleted Successfully.');
    }
}

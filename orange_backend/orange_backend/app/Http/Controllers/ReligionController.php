<?php

namespace App\Http\Controllers;

use App\Models\GlobalFunction;
use App\Models\Religion;
use Illuminate\Http\Request;

class ReligionController extends Controller
{
    public function religionList(Request $request)
    {
        $query = Religion::where('is_deleted', 0);
        $totalData = $query->count();

        $columns = 'id';
        $orderDir = 'desc';
        $limit = $request->input('length');
        $start = $request->input('start');
        $orderColumn = $columns;
        $searchValue = $request->input('search.value');

        if (!empty($searchValue)) {
            $query->where(function ($q) use ($searchValue) {
                $q->where('title', 'LIKE', "%{$searchValue}%");
            });
        }

        $totalFiltered = $query->count();

        $result = $query->orderBy($orderColumn, $orderDir)
            ->offset($start)
            ->limit($limit)
            ->get();

        $data = $result->map(function ($item) {

            $title = "<div class='text-body m-0 d-inline-block align-middle font-16'>
                        <span class='text-dark mt-0 fs-6'>{$item->title}</span>
                    </div>";

            $action = '<a rel="' . $item->id . '" 
                     data-title="' . $item->title . '"
                    class="btn btn-success edit text-white mr-2">
                    Edit
                    </a>
                    <a rel="' . $item->id . '"
                    class="btn btn-danger delete text-white">
                    Delete
                    </a>';

            return [
                $title,
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

    public function addReligion(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
        ]);

        $religion = Religion::where('title', $request->title)->where('is_deleted', 1)->first();

        if ($religion) {
            $religion->is_deleted = 0;
            $religion->save();

            return GlobalFunction::sendDataResponse(true, 'Religion restored and updated successfully!', $religion);
        }

        $existingReligion = Religion::where('title', $request->title)->where('is_deleted', 0)->first();

        if ($existingReligion) {
            return GlobalFunction::sendSimpleResponse(false, 'Religion with this title already exists. Please choose a different title.');
        }

        $religion = Religion::create([
            'title' => $request->title,
        ]);

        return GlobalFunction::sendDataResponse(true, 'Religion added successfully!', $religion);
    }

    public function updateReligion(Request $request)
    {
        $request->validate([
            'religion_id' => 'required|integer|exists:religions,id',
            'title' => 'nullable|string|max:255',
        ]);

        $religion = Religion::find($request->religion_id);

        if (!$religion) {
            return GlobalFunction::sendSimpleResponse(false, 'Religion not found.');
        }

        if ($request->has('title')) {
            $existingReligion = Religion::where('title', $request->title)
                ->where('id', '!=', $request->religion_id) // exclude current record
                ->where('is_deleted', 0)
                ->first();

            if ($existingReligion) {
                return GlobalFunction::sendSimpleResponse(false, 'Another Religion with this title already exists.');
            }

            $softDeletedReligion = Religion::where('title', $request->title)
                ->where('id', '!=', $request->religion_id)
                ->where('is_deleted', 1)
                ->first();

            if ($softDeletedReligion) {
                return GlobalFunction::sendSimpleResponse(false, 'This title exists in a soft-deleted record. Please choose a different title.');
            }

            $religion->title = $request->title;
        }

        $religion->save();

        return GlobalFunction::sendDataResponse(true, 'Religion Updated Successfully!', $religion);
    }

    public function deleteReligion(Request $request)
    {
        $religion = Religion::find($request->religion_id);
        $religion->is_deleted = 1;
        $religion->save();

        return GlobalFunction::sendSimpleResponse(true, 'Religion Deleted Successfully.');
    }
}

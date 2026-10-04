<?php

namespace App\Http\Controllers;

use App\Models\GlobalFunction;
use App\Models\Language;
use Illuminate\Http\Request;

class LanguageController extends Controller
{
    public function languageList(Request $request)
    {
        $query = Language::where('is_deleted', 0);
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

            $title = "<span class='text-dark mt-0 fs-6'>{$item->title}</span>";

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

    public function addLanguage(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
        ]);

        $language = Language::where('title', $request->title)->where('is_deleted', 1)->first();

        if ($language) {
            $language->is_deleted = 0;
            $language->save();

            return GlobalFunction::sendDataResponse(true, 'Language restored and updated successfully!', $language);
        }

        $existingLanguage = Language::where('title', $request->title)->where('is_deleted', 0)->first();

        if ($existingLanguage) {
            return GlobalFunction::sendSimpleResponse(false, 'Language with this title already exists. Please choose a different title.');
        }

        $language = Language::create([
            'title' => $request->title,
        ]);

        return GlobalFunction::sendDataResponse(true, 'Language added successfully!', $language);
    }

    public function updateLanguage(Request $request)
    {
        $request->validate([
            'language_id' => 'required|integer|exists:languages,id',
            'title' => 'nullable|string|max:255',
        ]);

        $language = Language::find($request->language_id);

        if (!$language) {
            return GlobalFunction::sendSimpleResponse(false, 'Language not found.');
        }

        if ($request->has('title')) {
            $existingLanguage = Language::where('title', $request->title)
                ->where('id', '!=', $request->language_id) // exclude current record
                ->where('is_deleted', 0)
                ->first();

            if ($existingLanguage) {
                return GlobalFunction::sendSimpleResponse(false, 'Another Language with this title already exists.');
            }

            $softDeletedLanguage = Language::where('title', $request->title)
                ->where('id', '!=', $request->religion_id)
                ->where('is_deleted', 1)
                ->first();

            if ($softDeletedLanguage) {
                return GlobalFunction::sendSimpleResponse(false, 'This title exists in a soft-deleted record. Please choose a different title.');
            }

            $language->title = $request->title;
        }

        $language->save();

        return GlobalFunction::sendDataResponse(true, 'Language Updated Successfully!', $language);
    }

    public function deleteLanguage(Request $request)
    {
        $language = Language::find($request->language_id);
        $language->is_deleted = 1;
        $language->save();

        return GlobalFunction::sendSimpleResponse(true, 'Language Deleted Successfully.');
    }
}

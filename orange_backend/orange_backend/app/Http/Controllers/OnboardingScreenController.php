<?php

namespace App\Http\Controllers;

use App\Models\GlobalFunction;
use App\Models\OnboardingScreen;
use Illuminate\Http\Request;

class OnboardingScreenController extends Controller
{
    public function onboardingList(Request $request)
    {
        $query = OnboardingScreen::orderBy('position');
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

            $sortable = "<div data-id='{$item->id}' class='sort-handler grabbable action-btn d-flex align-items-center justify-content-center border rounded-2 text-info p-2 '>
               <i class='fas fa-sort'></i>
            </div>";

            $onboardingImageUrl = $item->image ? env('image') . $item->image : asset('assets/img/placeholder.png');

            $image = "<img src='{$onboardingImageUrl}' class='rounded me-1 object-fit-cover bg-info-lighten border' data-fancybox height='80' width='80' />
                    <div class='text-body m-0 d-inline-block align-middle font-16'>
                        <span class='text-dark mt-0 fs-6'>{$item->title}</span>
                        <p class='mb-0 fs-6 text-muted fw-normal'>{$item->description}</p>
                    </div>";

            $action = '<a data-img="' . $onboardingImageUrl . '" 
                     rel="' . $item->id . '" 
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
                $sortable,
                $item->position,
                $image,
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

    function addOnboarding(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'image' => 'nullable|image|mimes:jpg,jpeg,png,svg',
        ]);

        $onboardingScreenCount = OnboardingScreen::count();

        $onboardingScreen = OnboardingScreen::create([
            'title' => $request->title,
            'description' => $request->description,
            'position' => $onboardingScreenCount + 1,
            'image' => $request->hasFile('image') ? GlobalFunction::saveFileAndGivePath($request->file('image')) : null,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Onboarding added successfully!',
            'data' => $onboardingScreen
        ]);
    }

    public function updateOnboardingScreen(Request $request)
    {
        $onboardingScreen = OnboardingScreen::find($request->onboarding_id);
        if ($request->has('title')) {
            $onboardingScreen->title = $request->title;
        }
        if ($request->has('description')) {
            $onboardingScreen->description = $request->description;
        }
        if ($request->hasFile('image')) {
            GlobalFunction::deleteFile($onboardingScreen->image);
            $onboardingScreen->image = GlobalFunction::saveFileAndGivePath($request->file('image'));
        }
        $onboardingScreen->save();

        return response()->json([
            'status' => true,
            'message' => 'Onboarding Screen Updated Successfully!',
            'data' => $onboardingScreen
        ]);
    }

    public function deleteOnboardingScreen(Request $request)
    {
        $onboardingScreen = OnboardingScreen::find($request->onboarding_id);

        GlobalFunction::deleteFile($onboardingScreen->image);

        $deletedPosition = $onboardingScreen->position;
 
        $onboardingScreen->delete();

        OnboardingScreen::where('position', '>', $deletedPosition)
            ->orderBy('position', 'asc')
            ->decrement('position');

        return GlobalFunction::sendSimpleResponse(true, 'Onboarding Screen Deleted Successfully.');
    }

    public function updateOnboardingOrder(Request $request)
    {
        $order = $request->order;
        foreach ($order as $index => $id) {
            OnboardingScreen::where('id', $id)->update(['position' => $index + 1]);
        }
        return GlobalFunction::sendSimpleResponse(true, 'Onboarding order updated successfully.');
    }
}

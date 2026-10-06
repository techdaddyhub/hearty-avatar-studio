<?php

namespace App\Http\Controllers;

use App\Models\AppData;
use App\Models\Comment;
use App\Models\Constants;
use App\Models\FollowingList;
use App\Models\GlobalFunction;
use App\Models\Images;
use App\Models\Interest;
use App\Models\Language;
use App\Models\Like;
use App\Models\LikedProfile;
use App\Models\LiveApplications;
use App\Models\LiveHistory;
use App\Models\Myfunction;
use App\Models\Post;
use App\Models\PostContent;
use App\Models\RedeemRequest;
use App\Models\RelationshipGoal;
use App\Models\Religion;
use App\Models\Report;
use App\Models\Story;
use App\Models\User;
use App\Models\UserNotification;
use App\Models\Users;
use App\Models\VerifyRequest;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class UsersController extends Controller
{
    function addCoinsToUserWalletFromAdmin(Request $request)
    {
        $result = Users::where('id', $request->id)->increment('wallet', $request->coins);
        if ($result) {
            $response['success'] = 1;
        } else {
            $response['success'] = 0;
        }
        echo json_encode($response);
    }

    function logOutUser(Request $request)
    {
        $rules = [
            'user_id' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();

        if ($user == null) {
            return json_encode([
                'status' => false,
                'message' => 'user not found!',
            ]);
        }

        $user->device_token = null;
        $user->save();

        return response()->json(['status' => true, 'message' => 'User logged out successfully !']);
    }

    function fetchUsersByCordinates(Request $request)
    {
        $rules = [
            'lat' => 'required',
            'long' => 'required',
            'km' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $users = Users::with('images')->where('is_block', 0)->where('is_fake', 0)->where('show_on_map', 1)->where('anonymous', 0)->get();

        $usersData = [];
        foreach ($users as $user) {

            $distance = Myfunction::point2point_distance($request->lat, $request->long, $user->lattitude, $user->longitude, "K", $request->km);
            if ($distance) {
                array_push($usersData, $user);
            }
        }
        return response()->json(['status' => true, 'message' => 'Data fetched successfully !', 'data' => $usersData]);
    }

    function addUserImage(Request $req)
    {
        $img = new Images();
        $file = $req->file('image');
        $path = GlobalFunction::saveFileAndGivePath($file);
        $img->image = $path;
        $img->user_id = $req->id;
        $img->save();

        return json_encode([
            'status' => true,
            'message' => 'Image Added successfully!',
        ]);
    }

    function deleteUserImage($imgId)
    {
        $img = Images::find($imgId);

        $imgCount = Images::where('user_id', $img->user_id)->count();
        if ($imgCount == 1) {
            return json_encode([
                'status' => false,
                'message' => 'Minimum one image is required !',
            ]);
        }

        unlink(storage_path('app/public/' . $img->image));
        $img->delete();
        return json_encode([
            'status' => true,
            'message' => 'Image Deleted successfully!',
        ]);
    }

    function updateUser(Request $req)
    {
        $result = Users::where('id', $req->id)->update([
            "fullname" => $req->fullname,
            "password" => $req->password,
            "bio" => $req->bio,
            "about" => $req->about,
            "instagram" => $req->instagram,
            "youtube" => $req->youtube,
            "facebook" => $req->facebook,
            "country" => $req->country,
            "state" => $req->state,
            "city" => $req->city,
        ]);

        return json_encode([
            'status' => true,
            'message' => 'data updates successfully!',
        ]);
    }

    function addFakeUserFromAdmin(Request $request)
    {
        $user = new Users();
        $user->identity = Myfunction::generateFakeUserIdentity();
        $user->fullname = $request->fullname;
        $user->youtube = $request->youtube;
        $user->facebook = $request->facebook;
        $user->instagram = $request->instagram;
        $user->country = $request->country;
        $user->state = $request->state;
        $user->city = $request->city;
        $user->about = $request->about;
        $user->bio = $request->bio;
        $user->dob = \Carbon\Carbon::now()->subYears(rand(20, 40))->format('Y-m-d');
        $user->password = $request->password;
        $user->gender = $request->gender;
        $user->is_verified = 2;
        $user->can_go_live = 2;
        $user->is_fake = 1;

        // Interests
        $interestIds = Interest::inRandomOrder()->limit(4)->pluck('id')->toArray();
        $user->interests = implode(',', $interestIds);

        // gender_preferred: random 1,2,3
        $user->gender_preferred = rand(1, 3);

        // relationship_goal_id: random existing id
        $user->relationship_goal_id = RelationshipGoal::inRandomOrder()->value('id');

        // religion_key: random existing key
        $user->religion_key = Religion::inRandomOrder()->value('title');

        // language_keys: random 2–4 existing keys
        $randomLangs = Language::inRandomOrder()->limit(rand(2, 4))->pluck('title')->toArray();
        $user->language_keys = implode(',', $randomLangs);

        $user->save();

        if ($request->hasFile('image')) {
            $files = $request->file('image');
            for ($i = 0; $i < count($files); $i++) {
                $image = new Images();
                $image->user_id = $user->id;
                $path = GlobalFunction::saveFileAndGivePath($files[$i]);
                $image->image = $path;
                $image->save();
            }
        }

        return response()->json(['status' => true, 'message' => "Fake user added successfully !"]);
    }

    public function getExplorePageProfileList(Request $request)
    {
        $rules = [
            'user_id' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();
        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'User not found!',
            ]);
        }

        $genderPreference = $user->gender_preferred;
        $ageMin = $user->age_preferred_min;
        $ageMax = $user->age_preferred_max;
        $blockedUsers = array_merge(explode(',', $user->blocked_users), [$user->id]);
        $hiddenUsers = array_merge(explode(',', $user->hidden_user_ids), [$user->id]);
        $likedUsers = LikedProfile::where('my_user_id', $request->user_id)->pluck('user_id')->toArray();

        $profilesQuery = Users::with('images')
            ->has('images')
            ->whereNotIn('id', $blockedUsers)
            ->whereNotIn('id', $hiddenUsers)
            ->where('is_block', 0)
            ->when($genderPreference != 3, function ($query) use ($genderPreference) {
                $query->where('gender', $genderPreference == 1 ? 1 : 2);
            })
            ->whereRaw("TIMESTAMPDIFF(YEAR, dob, CURDATE()) BETWEEN ? AND ?", [$ageMin, $ageMax])
            ->inRandomOrder()
            ->limit(15);

        $profiles = $profilesQuery->get()->each(function ($profile) use ($likedUsers) {
            $profile->is_like = in_array($profile->id, $likedUsers);
        });

        return response()->json([
            'status' => true,
            'message' => 'Data found successfully!',
            'data' => $profiles,
        ]);
    }

    function getRandomProfile(Request $request)
    {
        $rules = [
            'user_id' => 'required',
            'gender' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();
        if ($user == null) {
            return response()->json([
                'status' => false,
                'message' => 'User not found!',
            ]);
        }

        $blocked_users = explode(',', $user->blocked_users);
        array_push($blocked_users, $user->id);

        $hiddenUserArray = explode(',', $user->hidden_user_ids);
        array_push($hiddenUserArray, $user->id);

        if ($request->gender == 3) {
            $randomUser = Users::with('images')->has('images')->whereNotIn('id', $blocked_users)->whereNotIn('id', $hiddenUserArray)->where('is_block', 0)->inRandomOrder()->first();
        } else {
            $randomUser = Users::with('images')->has('images')->whereNotIn('id', $blocked_users)->whereNotIn('id', $hiddenUserArray)->where('is_block', 0)->where('gender', $request->gender)->inRandomOrder()->first();
        }

        if ($randomUser == null) {
            return response()->json([
                'status' => false,
                'message' => 'User not found!',
            ]);
        }

        return response()->json([
            'status' => true,
            'message' => 'data found successfully!',
            'data' => $randomUser,
        ]);
    }

    function updateUserBlockList(Request $request)
    {
        $rules = [
            'user_id' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();
        if ($user == null) {
            return response()->json(['status' => false, 'message' => "User doesn't exists !"]);
        }

        $user->blocked_users = $request->blocked_users;
        $user->save();

        $data = Users::with('images')->where('id', $request->user_id)->first();

        return response()->json(['status' => true, 'message' => "Blocklist updated successfully !", 'data' => $data]);
    }

    function deleteMyAccount(Request $request)
    {
        $rules = [
            'user_id' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();
        if ($user == null) {
            return json_encode([
                'status' => false,
                'message' => 'user not found!',
            ]);
        }

        $images = Images::where('user_id', $user->id)->get();
        foreach ($images as $image) {
            GlobalFunction::deleteFile($image->image);
            $image->delete();
        }

        $likes = Like::where('user_id', $user->id)->get();
        foreach ($likes as $like) {
            $postLikeCount = Post::where('id', $like->post_id)->first();
            $postLikeCount->likes_count -= 1;
            $postLikeCount->save();
            $like->delete();
        }
        $comments = Comment::where('user_id', $user->id)->get();
        foreach ($comments as $comment) {
            $postCommentCount = Post::where('id', $comment->post_id)->first();
            $postCommentCount->comments_count -= 1;
            $postCommentCount->save();
            $comment->delete();
        }

        $followerList = FollowingList::where('my_user_id', $user->id)->get();
        foreach ($followerList as $follower) {
            $followerUser = User::where('id', $follower->user_id)->first();
            $followerUser->followers -= 1;
            $followerUser->save();

            $follower->delete();
        }

        $followingList = FollowingList::where('user_id', $user->id)->get();
        foreach ($followingList as $following) {
            $followingUser = User::where('id', $following->user_id)->first();
            $followingUser->following -= 1;
            $followingUser->save();

            $following->delete();
        }

        LikedProfile::where('my_user_id', $user->id)->delete();
        LikedProfile::where('user_id', $user->id)->delete();

        $liveApplication = LiveApplications::where('user_id', $user->id)->first();
        if ($liveApplication) {
            GlobalFunction::deleteFile($liveApplication->intro_video);
            $liveApplication->delete();
        }

        LiveHistory::where('user_id', $user->id)->delete();

        $posts = Post::where('user_id', $user->id)->get();
        foreach ($posts as $post) {
            $postContents = PostContent::where('post_id', $post->id)->get();
            foreach ($postContents as $postContent) {
                GlobalFunction::deleteFile($postContent->content);
                GlobalFunction::deleteFile($postContent->thumbnail);
                $postContent->delete();
            }

            Comment::where('post_id', $post->id)->delete();
            Like::where('post_id', $post->id)->delete();
            Report::where('post_id', $post->id)->delete();
            UserNotification::where('item_id', $post->id)->where('type', Constants::notificationTypeLike)->delete();

            $post->delete();
        }

        RedeemRequest::where('user_id', $user->id)->delete();
        Report::where('user_id', $user->id)->delete();

        $stories = Story::where('user_id', $user->id)->get();
        foreach ($stories as $story) {
            GlobalFunction::deleteFile($story->content);
        }

        UserNotification::where('user_id', $user->id)->delete();
        UserNotification::where('my_user_id', $user->id)->delete();

        $verificationRequest = VerifyRequest::where('user_id', $user->id)->first();
        if ($verificationRequest) {
            GlobalFunction::deleteFile($verificationRequest->document);
            GlobalFunction::deleteFile($verificationRequest->selfie);
            $verificationRequest->delete();
        }

        $user->delete();

        return response()->json(['status' => true, 'message' => "Account Deleted Successfully!"]);
    }

    function rejectVerificationRequest(Request $request)
    {
        $verifyRequest = VerifyRequest::where('id', $request->verification_id)->first();
        $verifyRequest->user->is_verified = 0;
        $verifyRequest->user->save();

        GlobalFunction::deleteFile($verifyRequest->document);
        GlobalFunction::deleteFile($verifyRequest->selfie);

        $verifyRequest->delete();

        return response()->json([
            'status' => true,
            'message' => 'Reject Verification Request',
        ]);
    }

    function approveVerificationRequest(Request $request)
    {
        $verifyRequest = VerifyRequest::where('id', $request->verification_id)->first();
        $verifyRequest->user->is_verified = 2;
        $verifyRequest->user->save();

        GlobalFunction::deleteFile($verifyRequest->document);
        GlobalFunction::deleteFile($verifyRequest->selfie);

        $verifyRequest->delete();

        return response()->json([
            'status' => true,
            'message' => 'Approve Verification Request',
        ]);
    }

    public function fetchverificationRequests(Request $request)
    {
        $totalData = VerifyRequest::count();
        $rows = VerifyRequest::orderBy('id', 'DESC')->get();

        $result = $rows;

        $columns = array(
            0 => 'id'
        );

        $limit = $request->input('length');
        $start = $request->input('start');
        $order = $columns[$request->input('order.0.column')];
        $dir = $request->input('order.0.dir');
        $totalData = VerifyRequest::count();
        $totalFiltered = $totalData;
        if (empty($request->input('search.value'))) {
            $result = VerifyRequest::offset($start)
                ->limit($limit)
                ->orderBy($order, $dir)
                ->get();
        } else {
            $search = $request->input('search.value');
            $result =  VerifyRequest::with('user')
                ->whereHas('user', function ($query) use ($search) {
                    $query->Where('fullname', 'LIKE', "%{$search}%")
                        ->orWhere('identity', 'LIKE', "%{$search}%");
                })
                ->offset($start)
                ->limit($limit)
                ->orderBy($order, $dir)
                ->get();
            $totalFiltered = VerifyRequest::with('user')
                ->whereHas('user', function ($query) use ($search) {
                    $query->Where('fullname', 'LIKE', "%{$search}%")
                        ->orWhere('identity', 'LIKE', "%{$search}%");
                })
                ->count();
        }
        $data = array();
        foreach ($result as $item) {

            $imgUrl = "http://placehold.jp/150x150.png"; // Default placeholder image URL

            if ($item->user->images->isNotEmpty() && $item->user->images[0]->image != null) {
                $imgUrl = asset('storage/' . $item->user->images[0]->image);
            }

            $image = '<img src="' . $imgUrl . '" width="50" height="50">';

            $selfieUrl = "public/storage/" . $item->selfie;
            $selfie = '<img style="cursor: pointer;" class="img-preview" rel="' . $selfieUrl . '" src="' . $selfieUrl . '" width="50" height="50">';

            $docUrl = "public/storage/" . ($item->document);
            $document = '<img style="cursor: pointer;" class="img-preview" rel="' . $docUrl . '" src="' . $docUrl . '" width="50" height="50">';

            $approve = '<a href=""class=" btn btn-success text-white approve ml-2" rel=' . $item->id . ' >' . __("Approve") . '</a>';
            $reject = '<a href=""class=" btn btn-danger text-white reject ml-2" rel=' . $item->id . ' >' . __("Reject") . '</a>';

            $action = '<span class="float-end d-flex">' . $approve . $reject . ' </span>';

            $data[] = array(
                $image,
                $selfie,
                $document,
                $item->document_type,
                $item->fullname,
                $item->user->identity,
                $action
            );
        }
        $json_data = array(
            "draw"            => intval($request->input('draw')),
            "recordsTotal"    => intval($totalData),
            "recordsFiltered" => $totalFiltered,
            "data"            => $data
        );
        echo json_encode($json_data);
        exit();
    }

    function verificationrequests()
    {
        return view('verificationrequests');
    }

    function applyForVerification(Request $request)
    {
        $rules = [
            'user_id' => 'required',
            'document' => 'required',
            'document_type' => 'required',
            'selfie' => 'required',
            'fullname' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();
        if ($user == null) {
            return json_encode([
                'status' => false,
                'message' => 'user not found!',
            ]);
        }

        if ($user->is_verified == 1) {
            return response()->json([
                'status' => false,
                'message' => 'The request has been submitted already!',
            ]);
        }
        if ($user->is_verified == 2) {
            return response()->json([
                'status' => false,
                'message' => 'This user is already verified !',
            ]);
        }

        $verifyReq = new VerifyRequest();
        $verifyReq->user_id = $request->user_id;
        $verifyReq->document_type = $request->document_type;
        $verifyReq->fullname = $request->fullname;
        $verifyReq->status = 0;

        $verifyReq->document = GlobalFunction::saveFileAndGivePath($request->document);
        $verifyReq->selfie = GlobalFunction::saveFileAndGivePath($request->selfie);

        $verifyReq->save();

        $user->is_verified = 1;
        $user->save();

        $user['images'] = Images::where('user_id', $request->user_id)->get();

        return response()->json([
            'status' => true,
            'message' => "Verification request submitted successfully !",
            'data' => $user
        ]);
    }

    public function likedProfile(Request $request)
    {
        $rules = [
            'my_user_id' => 'required',
            'user_id' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        $user = Users::where('id', $request->user_id)->first();
        $my_user = Users::where('id', $request->my_user_id)->first();

        if (!$user || !$my_user) {
            return response()->json([
                'status' => false,
                'message' => !$user ? 'User not found!' : 'Data user not found!',
            ]);
        }

        $fetchLikedProfile = LikedProfile::where('my_user_id', $request->my_user_id)
            ->where('user_id', $request->user_id)
            ->first();

        if (!$fetchLikedProfile) {
            $likedProfile = new LikedProfile();
            $likedProfile->my_user_id = (int) $request->my_user_id;
            $likedProfile->user_id = (int) $request->user_id;
            $likedProfile->save();

            $notificationExists = UserNotification::where('user_id', $request->user_id)
                ->where('my_user_id', $request->my_user_id)
                ->where('type', Constants::notificationTypeLikeProfile)
                ->first();

            if (!$notificationExists) {
                $userNotification = new UserNotification();
                $userNotification->user_id = (int) $user->id;
                $userNotification->my_user_id = (int) $my_user->id;
                $userNotification->type = Constants::notificationTypeLikeProfile;
                $userNotification->item_id = (int) $user->id;
                $userNotification->save();
            }

            return response()->json([
                'status' => true,
                'message' => 'Liked Profile Successfully!'
            ]);
        }

        return response()->json([
            'status' => false,
            'message' => 'Already Liked Profile!'
        ]);
    }

    public function dislikedProfile(Request $request)
    {
        $rules = [
            'my_user_id' => 'required',
            'user_id' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            return response()->json(['status' => false, 'message' => $validator->errors()->first()]);
        }

        $user = Users::where('id', $request->user_id)->first();
        $my_user = Users::where('id', $request->my_user_id)->first();

        if (!$user || !$my_user) {
            return response()->json([
                'status' => false,
                'message' => !$user ? 'User not found!' : 'Data user not found!',
            ]);
        }

        $fetchLikedProfile = LikedProfile::where('my_user_id', $request->my_user_id)
            ->where('user_id', $request->user_id)
            ->first();

        $notificationExists = UserNotification::where('user_id', $request->user_id)
            ->where('my_user_id', $request->my_user_id)
            ->where('type', Constants::notificationTypeLikeProfile)
            ->first();

        if (!$fetchLikedProfile) {
            return response()->json([
                'status' => false,
                'message' => 'Already Disliked Profile!'
            ]);
        }

        $fetchLikedProfile->delete();
        if ($notificationExists) {
            $notificationExists->delete();
        }
        return response()->json([
            'status' => true,
            'message' => 'Disliked Profile Successfully!'
        ]);
    }

    function fetchBlockedProfiles(Request $request)
    {
        $rules = [
            'user_id' => 'required'
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();

        if ($user == null) {
            return json_encode([
                'status' => false,
                'message' => 'user not found!',
            ]);
        }

        $array = explode(',', $user->blocked_users);
        $data = Users::whereIn('id', $array)->where('is_block', 0)->with('images')->has('images')->get();
        $data = $data->reverse()->values();

        return json_encode([
            'status' => true,
            'message' => 'blocked profiles fetched successfully!',
            'data' => $data
        ]);
    }

    function fetchLikedProfiles(Request $request)
    {
        $rules = [
            'user_id' => 'required'
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();
        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'user not found!',
            ]);
        }

        $likedProfiles = LikedProfile::where('my_user_id', $request->user_id)
            ->with('user')
            ->whereRelation('user', 'is_block', 0)
            ->has('user.images')
            ->with('user.images')
            ->orderBy('id', 'DESC')
            ->get()
            ->pluck('user');

        foreach ($likedProfiles as $likedProfile) {
            $likedProfile->is_like = true;
        }

        return response()->json([
            'status' => true,
            'message' => 'profiles fetched successfully!',
            'data' => $likedProfiles
        ]);
    }

    function fetchSavedProfiles(Request $request)
    {
        $rules = [
            'user_id' => 'required'
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();
        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'user not found!',
            ]);
        }

        $array = explode(',', $user->savedprofile);
        $blocked_users = explode(',', $user->blocked_users);
        $hidden_user_ids = explode(',', $user->hidden_user_ids);
        $data = Users::whereIn('id', $array)->whereNotIn('id', $blocked_users)->whereNotIn('id', $hidden_user_ids)->where('is_block', 0)->has('images')->with('images')->get();
        $data = $data->reverse()->values();

        return response()->json([
            'status' => true,
            'message' => 'Fetched Saved Profiles Successfully!',
            'data' => $data
        ]);
    }

    function allowLiveToUser(Request $request)
    {
        $user = Users::where('id', $request->user_id)->first();

        if ($user) {
            $user->can_go_live = 2;
            $user->save();

            return response()->json([
                'status' => true,
                'message' => "This user is allowed to go live.",
                'data' => $user,
            ]);
        } else {
            return response()->json([
                'status' => false,
                'message' => 'User not found',
            ]);
        }
    }

    function restrictLiveToUser(Request $request)
    {
        $user = Users::where('id', $request->user_id)->first();

        if ($user) {
            $user->can_go_live = 0;
            $user->save();

            return response()->json([
                'status' => true,
                'message' => "Restrict Live Access to User.",
                'data' => $user,
            ]);
        } else {
            return response()->json([
                'status' => false,
                'message' => 'User not found',
            ]);
        }
    }

    function increaseStreamCountOfUser(Request $request)
    {
        $rules = [
            'user_id' => 'required'
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();

        if ($user == null) {
            return json_encode([
                'status' => false,
                'message' => 'user not found!',
            ]);
        }

        $user->total_streams += 1;
        $result = $user->save();

        if ($result) {
            return json_encode([
                'status' => true,
                'message' => 'Stream count increased successfully',
                'total_streams' => $user->total_streams
            ]);
        } else {
            return json_encode([
                'status' => false,
                'message' => 'something went wrong!',

            ]);
        }
    }

    function minusCoinsFromWallet(Request $request)
    {
        $rules = [
            'user_id' => 'required',
            'amount' => 'required'
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();

        if ($user == null) {
            return json_encode([
                'status' => false,
                'message' => 'user not found!',
            ]);
        }

        if ($user->wallet < $request->amount) {
            return json_encode([
                'status' => false,
                'message' => 'No enough coins in the wallet!',
                'wallet' => $user->wallet,
            ]);
        }

        $user->wallet -= $request->amount;
        $result = $user->save();

        if ($result) {
            return json_encode([
                'status' => true,
                'message' => 'coins deducted from wallet successfully',
                'wallet' => $user->wallet,
                'total_collected' => $user->total_collected,
            ]);
        } else {
            return json_encode([
                'status' => false,
                'message' => 'something went wrong!',

            ]);
        }
    }

    function addCoinsToWallet(Request $request)
    {
        $rules = [
            'user_id' => 'required',
            'amount' => 'required'
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();

        if ($user == null) {
            return json_encode([
                'status' => false,
                'message' => 'user not found!',
            ]);
        }

        $user->wallet  += $request->amount;
        $user->total_collected += $request->amount;
        $result = $user->save();

        if ($result) {
            return json_encode([
                'status' => true,
                'message' => 'coins added to wallet successfully',
                'wallet' => $user->wallet,
                'total_collected' => $user->total_collected,
            ]);
        } else {
            return json_encode([
                'status' => false,
                'message' => 'something went wrong!',

            ]);
        }
    }

    function updateLiveStatus(Request $request)
    {
        $rules = [
            'user_id' => 'required',
            'state' => 'required'
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();
        $user->is_live_now = $request->state;
        $user->save();

        $data = Users::with('images')->has('images')->where('id', $request->user_id)->first();

        return json_encode([
            'status' => true,
            'message' => 'is_live_now state updated successfully',
            'data' => $data
        ]);
    }

    function onOffVideoCalls(Request $request)
    {
        $rules = [
            'user_id' => 'required',
            'state' => 'required'
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();
        $user->is_video_call = $request->state;
        $user->save();

        $data = Users::with('images')->has('images')->where('id', $request->user_id)->first();

        return json_encode([
            'status' => true,
            'message' => 'is_video_call state updated successfully',
            'data' => $data
        ]);
    }

    function onOffAnonymous(Request $request)
    {
        $rules = [
            'user_id' => 'required',
            'state' => 'required'
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();
        $user->anonymous = $request->state;
        $user->save();

        $data = Users::with('images')->has('images')->where('id', $request->user_id)->first();

        return json_encode([
            'status' => true,
            'message' => 'anonymous state updated successfully',
            'data' => $data
        ]);
    }

    function onOffShowMeOnMap(Request $request)
    {
        $rules = [
            'user_id' => 'required',
            'state' => 'required'
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();
        $user->show_on_map = $request->state;
        $user->save();

        $data = Users::with('images')->has('images')->where('id', $request->user_id)->first();

        return json_encode([
            'status' => true,
            'message' => 'show_on_map state updated successfully',
            'data' => $data
        ]);
    }

    function onOffNotification(Request $request)
    {
        $rules = [
            'user_id' => 'required',
            'state' => 'required'
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();
        $user->is_notification = $request->state;
        $user->save();

        $data = Users::with('images')->has('images')->where('id', $request->user_id)->first();

        return json_encode([
            'status' => true,
            'message' => 'notification state updated successfully',
            'data' => $data
        ]);
    }

    function fetchAllUsers(Request $request)
    {
        $columns = [
            0 => 'id',
            1 => 'fullname'
        ];

        $limit = $request->input('length');
        $start = $request->input('start');
        $orderIndex = $request->input('order.0.column');
        $order = $columns[$orderIndex] ?? 'id';
        $dir = $request->input('order.0.dir', 'DESC');

        $search = $request->input('search.value');

        $query = Users::query();

        if (!empty($search)) {
            $query->where(function ($q) use ($search) {
                $q->where('fullname', 'LIKE', "%{$search}%")
                    ->orWhere('identity', 'LIKE', "%{$search}%");
            });
        }

        $totalData = Users::count();              // total without filter
        $totalFiltered = $query->count();         // total with filter

        // Fetch paginated data
        $result = $query->offset($start)
            ->limit($limit)
            ->orderBy($order, $dir)
            ->get();

        $data = [];
        foreach ($result as $item) {
            $block = $item->is_block == 0
                ? '<a class="btn btn-danger text-white block" rel=' . $item->id . '>' . __('app.Block') . '</a>'
                : '<a class="btn btn-success text-white unblock" rel=' . $item->id . '>' . __('app.Unblock') . '</a>';

            $gender = $item->gender == 1
                ? '<span class="badge bg-dark text-white">' . __('app.Male') . '</span>'
                : '<span class="badge bg-dark text-white">' . __('app.Female') . '</span>';

            $image = (count($item->images) > 0)
                ? '<img src="public/storage/' . $item->images[0]->image . '" width="50" height="50">'
                : '<img src="http://placehold.jp/150x150.png" width="50" height="50">';

            $liveEligible = $item->can_go_live == 2
                ? '<span class="badge bg-success text-white">Yes</span>'
                : '<span class="badge bg-danger text-white">No</span>';

            $age = $item->dob ? Carbon::parse($item->dob)->age : '';

            $action = '<a href="' . route('viewUserDetails', $item->id) . '" class="btn btn-primary text-white" rel=' . $item->id . '><i class="fas fa-eye"></i></a>';

            $addCoin = '<a href="" data-id="' . $item->id . '" class="addCoins"><i class="i-cl-3 fas fa-plus-circle primary font-20 pointer p-l-5 p-r-5 me-2"></i></a>';

            $data[] = [
                $image,
                $item->identity,
                $item->fullname,
                $addCoin . $item->wallet,
                $liveEligible,
                $age,
                $gender,
                $block,
                $action,
            ];
        }

        return response()->json([
            "draw" => intval($request->input('draw')),
            "recordsTotal" => intval($totalData),
            "recordsFiltered" => intval($totalFiltered),
            "data" => $data
        ]);
    }

    function fetchStreamerUsers(Request $request)
    {
        $columns = [
            0 => 'id',
            1 => 'fullname'
        ];

        $limit = $request->input('length');
        $start = $request->input('start');
        $orderIndex = $request->input('order.0.column');
        $order = $columns[$orderIndex] ?? 'id';  // fallback if index missing
        $dir = $request->input('order.0.dir', 'DESC');

        $search = $request->input('search.value');

        // ✅ Start base query: only streamers (can_go_live = 2)
        $query = Users::where('can_go_live', 2);

        // Apply search filter if present
        if (!empty($search)) {
            $query->where(function ($q) use ($search) {
                $q->where('fullname', 'LIKE', "%{$search}%")
                    ->orWhere('identity', 'LIKE', "%{$search}%");
            });
        }

        // Count total data without filter
        $totalData = Users::where('can_go_live', 2)->count();

        // Count after filters
        $totalFiltered = $query->count();

        // Get paginated & ordered result
        $result = $query->offset($start)
            ->limit($limit)
            ->orderBy($order, $dir)
            ->get();

        // Build data array
        $data = [];
        foreach ($result as $item) {
            $block = ($item->is_block == 0)
                ? '<a class="btn btn-danger text-white block" rel=' . $item->id . '>' . __('app.Block') . '</a>'
                : '<a class="btn btn-success text-white unblock" rel=' . $item->id . '>' . __('app.Unblock') . '</a>';

            $age = $item->dob ? Carbon::parse($item->dob)->age : '';

            $gender = ($item->gender == 1)
                ? '<span class="badge bg-dark text-white">' . __('app.Male') . '</span>'
                : '<span class="badge bg-dark text-white">' . __('app.Female') . '</span>';

            $image = (count($item->images) > 0)
                ? '<img src="public/storage/' . $item->images[0]->image . '" width="50" height="50">'
                : '<img src="http://placehold.jp/150x150.png" width="50" height="50">';

            $liveEligible = '<span class="badge bg-success text-white">Yes</span>';

            $action = '<a href="' . route('viewUserDetails', $item->id) . '" class="btn btn-primary text-white" rel=' . $item->id . '><i class="fas fa-eye"></i></a>';

            $data[] = [
                $image,
                $item->identity,
                $item->fullname,
                $liveEligible,
                $age,
                $gender,
                $block,
                $action,
            ];
        }

        return response()->json([
            "draw" => intval($request->input('draw')),
            "recordsTotal" => intval($totalData),
            "recordsFiltered" => intval($totalFiltered),
            "data" => $data
        ]);
    }

    function fetchFakeUsers(Request $request)
    {
        $columns = [
            0 => 'id',
            1 => 'fullname'
        ];

        $limit = $request->input('length');
        $start = $request->input('start');
        $orderIndex = $request->input('order.0.column');
        $order = $columns[$orderIndex] ?? 'id';
        $dir = $request->input('order.0.dir', 'DESC');

        $search = $request->input('search.value');

        $query = Users::where('is_fake', 1);

        if (!empty($search)) {
            $query->where(function ($q) use ($search) {
                $q->where('fullname', 'LIKE', "%{$search}%")
                    ->orWhere('identity', 'LIKE', "%{$search}%");
            });
        }

        $totalData = Users::where('is_fake', 1)->count();
        $totalFiltered = $query->count();
        $result = $query->offset($start)
            ->limit($limit)
            ->orderBy($order, $dir)
            ->get();

        $data = [];
        foreach ($result as $item) {
            $block = ($item->is_block == 0)
                ? '<a class="btn btn-danger text-white block" rel=' . $item->id . '>' . __('app.Block') . '</a>'
                : '<a class="btn btn-success text-white unblock" rel=' . $item->id . '>' . __('app.Unblock') . '</a>';

            $age = $item->dob ? Carbon::parse($item->dob)->age : '';

            $gender = ($item->gender == 1)
                ? '<span class="badge bg-dark text-white">' . __('app.Male') . '</span>'
                : '<span class="badge bg-dark text-white">' . __('app.Female') . '</span>';

            $image = (count($item->images) > 0)
                ? '<img src="public/storage/' . $item->images[0]->image . '" width="50" height="50">'
                : '<img src="http://placehold.jp/150x150.png" width="50" height="50">';

            $action = '<a href="' . route('viewUserDetails', $item->id) . '" class="btn btn-primary text-white" rel=' . $item->id . '><i class="fas fa-eye"></i></a>';

            $data[] = [
                $image,
                $item->fullname,
                $item->identity,
                $item->password,
                $age,
                $gender,
                $block,
                $action,
            ];
        }

        return response()->json([
            "draw" => intval($request->input('draw')),
            "recordsTotal" => intval($totalData),
            "recordsFiltered" => intval($totalFiltered),
            "data" => $data
        ]);
    }

    function generateUniqueUsername()
    {
        $characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
        $username = '';
        $length = 8;

        do {
            for ($i = 0; $i < $length; $i++) {
                $username .= $characters[rand(0, strlen($characters) - 1)];
            }

            $existingUser = Users::where('username', $username)->first();
        } while ($existingUser);

        return $username;
    }

    function addUserDetails(Request $req)
    {
        if ($req->has('password')) {
            $data = Users::where('identity', $req->identity)->where('password', $req->password)->first();
            if ($data == null) {
                return json_encode(['status' => false, 'message' => "Incorrect Identity and Password combination"]);
            }
        }

        $appData = AppData::first();
        $data = Users::where('identity', $req->identity)->first();

        if ($data == null) {
            $user = new Users;
            $user->fullname = Myfunction::customReplace($req->fullname);
            $user->identity = $req->identity;
            $user->device_token = $req->device_token;
            $user->device_type = $req->device_type;
            $user->login_type = $req->login_type;
            $user->wallet = $appData->new_user_free_coins;
            $user->total_collected = $appData->new_user_free_coins;
            $user->username = $this->generateUniqueUsername();

            $user->save();

            $data = Users::with('images')->where('id', $user->id)->first();

            return response()->json([
                'status' => true,
                'message' => __('app.UserAddSuccessful'),
                'data' => $data
            ]);
        } else {
            Users::where('identity', $req->identity)->update([
                'device_token' => $req->device_token,
                'device_type' => $req->device_type,
                'login_type' => $req->login_type,
            ]);

            $data = Users::with('images')->where('id', $data['id'])->first();

            return response()->json(['status' => true, 'message' => __('app.UserAllReadyExists'), 'data' => $data]);
        }
    }

    public function searchUsersForInterest(Request $req)
    {
        $rules = [
            'start' => 'required|integer|min:0',
            'count' => 'required|integer|min:1',
            'interest_id' => 'required|integer|min:1',
            'user_id' => 'required|integer|min:1'
        ];

        $validator = Validator::make($req->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::find($req->user_id);
        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'User not found!',
            ]);
        }

        // Clean up blocked and hidden IDs
        $blocked_users = array_filter(array_map('intval', explode(',', $user->blocked_users ?? '')), fn($id) => $id > 0);
        $hidden_user_ids = array_filter(array_map('intval', explode(',', $user->hidden_user_ids ?? '')), fn($id) => $id > 0);

        $keyword = $req->keyword ?? '';
        $interestID = (int) $req->interest_id;
        $start = (int) $req->start;
        $count = (int) $req->count;

        $query = Users::with('images')
            ->where(function ($q) use ($keyword) {
                $q->where('fullname', 'LIKE', "%$keyword%")
                    ->orWhere('username', 'LIKE', "%$keyword%");
            })
            ->whereNotIn('id', $blocked_users)
            ->whereNotIn('id', $hidden_user_ids)
            ->where('id', '!=', $user->id)
            ->whereRaw("FIND_IN_SET(?, interests)", [$interestID])
            ->has('images')
            ->where('is_block', 0)
            ->where('anonymous', 0);

        $total = $query->count();

        $result = $query
            ->offset($start)
            ->limit($count)
            ->get();

        if ($result->isEmpty()) {
            return response()->json([
                'status' => true,
                'message' => 'No data found',
                'total' => 0,
                'data' => []
            ]);
        }

        return response()->json([
            'status' => true,
            'message' => 'Data retrieved successfully',
            'total' => $total,
            'data' => $result
        ]);
    }

    public function searchUsers(Request $req)
    {
        $rules = [
            'user_id' => 'required|integer',
            'start' => 'required|integer|min:0',
            'count' => 'required|integer|min:1',
        ];

        $validator = Validator::make($req->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::find($req->user_id);
        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'User not found!',
            ]);
        }

        $blocked_users = array_filter(array_map('intval', explode(',', $user->blocked_users ?? '')), fn($id) => $id > 0);
        $hidden_user_ids = array_filter(array_map('intval', explode(',', $user->hidden_user_ids ?? '')), fn($id) => $id > 0);

        $keyword = $req->keyword ?? '';

        $result = Users::with('images')
            ->where(function ($q) use ($keyword) {
                $q->where('fullname', 'LIKE', "%$keyword%")
                    ->orWhere('username', 'LIKE', "%$keyword%");
            })
            ->whereNotIn('id', $blocked_users)
            ->whereNotIn('id', $hidden_user_ids)
            ->where('id', '!=', $user->id)
            ->has('images')
            ->where('is_block', 0)
            ->where('anonymous', 0)
            ->offset((int)$req->start)
            ->limit((int)$req->count)
            ->get();

        if ($result->isEmpty()) {
            return response()->json([
                'status' => true,
                'message' => 'No data found',
                'data' => []
            ]);
        }

        return response()->json([
            'status' => true,
            'message' => 'Data retrieved successfully',
            'data' => $result
        ]);
    }

    function updateProfile(Request $req)
    {
        $user = Users::where('id', $req->user_id)->first();

        if (!$user) {
            return json_encode(['status' => false, 'message' => __('app.UserNotFound')]);
        }

        if ($req->deleteimagestitle != null) {
            foreach ($req->deleteimagestitle as $oneImageData) {
                unlink(storage_path('app/public/' . $oneImageData));
            }
        }

        if ($req->has("deleteimageids")) {
            Images::whereIn('id', $req->deleteimageids)->delete();
        }

        if ($req->has("fullname")) {
            $user->fullname = Myfunction::customReplace($req->fullname);
        }
        if ($req->has("username")) {
            $existingUser = Users::where('username', $req->username)
                ->where('id', '!=', $req->user_id)
                ->first();
            if ($existingUser !== null) {
                return response()->json([
                    'status' => false,
                    'message' => 'Username is already taken',
                ]);
            }
            $user->username = Myfunction::customReplace($req->username);
        }
        if ($req->has("is_verified")) {
            $user->is_verified = $req->is_verified;
        }
        if ($req->has("gender")) {
            $user->gender = $req->gender;
        }
        if ($req->has('youtube')) {
            $user->youtube = $req->youtube;
        }
        if ($req->has("instagram")) {
            $user->instagram = $req->instagram;
        }
        if ($req->has("facebook")) {
            $user->facebook = $req->facebook;
        }
        if ($req->has("country")) {
            $user->country = $req->country;
        }
        if ($req->has("state")) {
            $user->state = $req->state;
        }
        if ($req->has("city")) {
            $user->city = $req->city;
        }
        if ($req->has("bio")) {
            $user->bio = Myfunction::customReplace($req->bio);
        }
        if ($req->has("about")) {
            $user->about = Myfunction::customReplace($req->about);
        }
        if ($req->has("lattitude")) {
            $user->lattitude = $req->lattitude;
        }
        if ($req->has("longitude")) {
            $user->longitude = $req->longitude;
        }
        if ($req->has("dob")) {
            $user->dob = $req->dob;
        }
        if ($req->has("interests")) {
            $user->interests = $req->interests;
        }
        if ($req->has("gender_preferred")) {
            $user->gender_preferred = $req->gender_preferred;
        }
        if ($req->has("age_preferred_min")) {
            $user->age_preferred_min = $req->age_preferred_min;
        }
        if ($req->has("age_preferred_max")) {
            $user->age_preferred_max = $req->age_preferred_max;
        }
        if ($req->has("distance_preference")) {
            $user->distance_preference = $req->distance_preference;
        }
        if ($req->has("relationship_goal_id")) {
            $user->relationship_goal_id = $req->relationship_goal_id;
        }
        if ($req->has("religion_key")) {
            $user->religion_key = $req->religion_key;
        }
        if ($req->has("language_keys")) {
            $user->language_keys = $req->language_keys;
        }
        if ($req->has("app_language")) {
            $user->app_language = $req->app_language;
        }
        if ($req->has("hidden_user_ids")) {
            $user->hidden_user_ids = $req->hidden_user_ids;
        }
        $user->save();

        if ($req->hasFile('image')) {
            $files = $req->file('image');
            for ($i = 0; $i < count($files); $i++) {
                $image = new Images();
                $image->user_id = $user->id;
                $path = GlobalFunction::saveFileAndGivePath($files[$i]);
                $image->image = $path;
                $image->save();
            }
        }

        $updatedUser = Users::where('id', $user->id)->with('images')->first();

        return response()->json(['status' => true, 'message' => __('app.Updatesuccessful'), 'data' => $updatedUser]);
    }

    function blockUser(Request $request)
    {
        $user = Users::where('id', $request->user_id)->first();

        if ($user) {
            $user->is_block = Constants::blocked;
            $user->save();

            Report::where('user_id', $request->user_id)->delete();

            return response()->json([
                'status' => true,
                'message' => 'This user has been blocked',
                'data' => $user,
            ]);
        } else {
            return response()->json([
                'status' => false,
                'message' => 'User not found',
            ]);
        }
    }

    function unblockUser(Request $request)
    {
        $user = Users::where('id', $request->user_id)->first();

        if ($user) {
            $user->is_block = Constants::unblocked;
            $user->save();

            return response()->json([
                'status' => true,
                'message' => 'This user has been blocked',
                'data' => $user,
            ]);
        } else {
            return response()->json([
                'status' => false,
                'message' => 'User not found',
            ]);
        }
    }

    function viewUserDetails($id)
    {
        $data = Users::where('id', $id)->with('images')->first();
        $interestIds = explode(',', $data->interests);
        // $interests = Interest::get();
        $interestTitles = Interest::orderByDesc('id')->whereIn('id', $interestIds)->get()->pluck('title');

        $data->interestTitles = $interestTitles;

        $matchedRelationshipGoal = RelationshipGoal::where('id', $data->relationship_goal_id)->first();

        return view('viewuser', [
            'data' => $data,
            'interestTitles' => $interestTitles,
            'matchedRelationshipGoal' => $matchedRelationshipGoal,
        ]);
    }

    function getProfile(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'my_user_id' => 'required',
            'user_id' => 'required',
        ]);

        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::with(['images', 'stories'])->has('images')->where('id', $request->user_id)->first();
        $myUser = Users::with('images')->has('images')->where('id', $request->my_user_id)->first();
        if ($user == null || $myUser == null) {
            return response()->json([
                'status' => false,
                'message' =>  'User Not Found!',
            ]);
        }

        $followingStatus = FollowingList::whereRelation('user', 'is_block', 0)->where('user_id', $request->my_user_id)->where('my_user_id', $request->user_id)->first();
        $followingStatus2 = FollowingList::whereRelation('user', 'is_block', 0)->where('my_user_id', $request->my_user_id)->where('user_id', $request->user_id)->first();

        // koi ek bija ne follow nathi kartu to 0
        if ($followingStatus == null && $followingStatus2 == null) {
            $user->followingStatus = 0;
        }
        // same valo mane follow kar che to 1
        if ($followingStatus != null) {
            $user->followingStatus = 1;
        }
        // hu same vala ne follow karu chu to 2
        if ($followingStatus2) {
            $user->followingStatus = 2;
        }
        // banne ek bija ne follow kare to 3
        if ($followingStatus && $followingStatus2) {
            $user->followingStatus = 3;
        }

        $fetchUserisLiked = UserNotification::where('my_user_id', $request->my_user_id)
            ->where('user_id', $request->user_id)
            ->where('type', Constants::notificationTypeLikeProfile)
            ->first();

        if ($fetchUserisLiked) {
            $user->is_like = true;
        } else {
            $user->is_like = false;
        }

        return response()->json([
            'status' => true,
            'message' =>  __('app.fetchSuccessful'),
            'data' => $user,
        ]);
    }

    function fetchMyUserProfile(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
        ]);

        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $myUser = Users::with('images')->where('id', $request->user_id)->first();
        if ($myUser == null) {
            return response()->json([
                'status' => false,
                'message' =>  'User Not Found!',
            ]);
        }

        return response()->json([
            'status' => true,
            'message' =>  __('app.fetchSuccessful'),
            'data' => $myUser,
        ]);
    }

    public function updateSavedProfile(Request $req)
    {
        $user = Users::with('images')->where('id', $req->user_id)->first();
        $user->savedprofile = $req->profiles;
        $user->save();

        return response()->json(['status' => true, 'message' => __('app.Updatesuccessful'), 'data' => $user]);
    }

    function getUserDetails(Request $request)
    {
        $data =  Users::where('identity', $request->email)->first();

        if ($data != null) {
            $data['image']  = Images::where('user_id', $data['id'])->first();
        } else {
            return response()->json(['status' => false, 'message' => __('app.UserNotFound')]);
        }
        $data['password'] = '';
        return response()->json(['status' => true, 'message' => __('app.fetchSuccessful'), 'data' => $data]);
    }

    public function followUser(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'my_user_id' => 'required',
            'user_id' => 'required',
        ]);

        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $fromUserQuery = Users::query();
        $toUserQuery = Users::query();

        $fromUser = $fromUserQuery->where('id', $request->my_user_id)->first();
        $toUser = $toUserQuery->where('id', $request->user_id)->first();

        if ($fromUser && $toUser) {
            if ($fromUser == $toUser) {
                return response()->json([
                    'status' => false,
                    'message' => 'Lol you did not follow yourself',
                ]);
            } else {
                $followingList = FollowingList::where('my_user_id', $request->my_user_id)->where('user_id', $request->user_id)->first();
                if ($followingList) {
                    return response()->json([
                        'status' => false,
                        'message' => 'User is Already in following list',
                    ]);
                }

                $blockUserIds = explode(',', $fromUser->blocked_users);

                foreach ($blockUserIds as $blockUserId) {
                    if ($blockUserId == $request->user_id) {
                        return response()->json([
                            'status' => false,
                            'message' => 'You blocked this User',
                        ]);
                    }
                }

                $following = new FollowingList();
                $following->my_user_id = (int) $request->my_user_id;
                $following->user_id = (int) $request->user_id;
                $following->save();

                $followingCount = $fromUserQuery->where('id', $request->my_user_id)->first();
                $followingCount->following += 1;
                $followingCount->save();

                $followersCount = $toUserQuery->where('id', $request->user_id)->first();
                $followersCount->followers += 1;
                $followersCount->save();

                $updatedUser = Users::where('id', $request->user_id)->first();

                $updatedUser->images;

                $following->user = $updatedUser;

                $type = Constants::notificationTypeFollow;

                $userNotification = new UserNotification();
                $userNotification->my_user_id = (int) $request->my_user_id;
                $userNotification->user_id = (int) $request->user_id;
                $userNotification->item_id = (int) $request->user_id;
                $userNotification->type = $type;
                $userNotification->save();

                return response()->json([
                    'status' => true,
                    'message' => 'User Added in Following List',
                    'data' => $following,
                ]);
            }
        } else {
            return response()->json([
                'status' => false,
                'message' => 'User Not Found',
            ]);
        }
    }

    public function fetchFollowingList(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
            'start' => 'required',
            'limit' => 'required',
        ]);

        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();
        if (!$user) {
            return response()->json(['status' => false, 'message' => 'User not found']);
        }

        $blockUserIds = [];
        if (!empty($user->blocked_users)) {
            $blockUserIds = explode(',', $user->blocked_users);
        }
        $hiddenUserIds = [];
        if (!empty($user->hidden_user_ids)) {
            $hiddenUserIds = explode(',', $user->hidden_user_ids);
        }

        $fetchFollowingList = FollowingList::whereRelation('user', 'is_block', 0)
            ->whereNotIn('user_id', $blockUserIds)
            ->whereNotIn('user_id', $hiddenUserIds)
            ->where('my_user_id', $request->user_id)
            ->with([
                'user' => function ($query) {
                    $query->whereHas('images');
                },
                'user.images'
            ])
            ->offset($request->start)
            ->limit($request->limit)
            ->get()
            ->pluck('user');

        return response()->json([
            'status' => true,
            'message' => 'Fetch Following List',
            'data' => $fetchFollowingList,
        ]);
    }

    public function fetchFollowersList(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
            'start' => 'required',
            'limit' => 'required',
        ]);

        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();
        if (!$user) {
            return response()->json(['status' => false, 'message' => 'User not found']);
        }

        $blockUserIds = [];
        if (!empty($user->blocked_users)) {
            $blockUserIds = explode(',', $user->blocked_users);
        }
        $hiddenUserIds = [];
        if (!empty($user->hidden_user_ids)) {
            $hiddenUserIds = explode(',', $user->hidden_user_ids);
        }

        $fetchFollowersList = FollowingList::where('user_id', $request->user_id)
            ->whereNotIn('my_user_id', $blockUserIds)
            ->whereNotIn('my_user_id', $hiddenUserIds)
            // ->whereNotIn('my_user_id', function ($query) use ($request) {
            //     $query->select('id')
            //         ->from('users')
            //         ->whereRaw("FIND_IN_SET(?, blocked_users)", [$request->user_id]);
            // })
            ->with('followerUser', 'followerUser.images')
            ->offset($request->start)
            ->limit($request->limit)
            ->get()
            ->pluck('followerUser');

        return response()->json([
            'status' => true,
            'message' => 'Fetch Followers List',
            'data' => $fetchFollowersList,
        ]);
    }

    public function unfollowUser(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'my_user_id' => 'required',
            'user_id' => 'required',
        ]);

        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }


        $fromUserQuery = Users::query();
        $toUserQuery = Users::query();

        $fromUser = $fromUserQuery->where('id', $request->my_user_id)->first();
        $toUser = $toUserQuery->where('id', $request->user_id)->first();

        if ($fromUser && $toUser) {
            if ($fromUser == $toUser) {
                return response()->json([
                    'status' => false,
                    'message' => 'Lol You did not Remove yourself, Bcz You dont follow yourself',
                ]);
            } else {
                $followingList = FollowingList::where('my_user_id', $request->my_user_id)->where('user_id', $request->user_id)->first();
                if ($followingList) {
                    $followingCount = $fromUserQuery->where('id', $request->my_user_id)->first();
                    $followingCount->following = max(0, $followingCount->following - 1);
                    $followingCount->save();

                    $followersCount = $toUserQuery->where('id', $request->user_id)->first();
                    $followersCount->followers = max(0, $followersCount->followers - 1);;
                    $followersCount->save();

                    $userNotification = UserNotification::where('my_user_id', $request->my_user_id)
                        ->where('user_id', $request->user_id)
                        ->where('type', Constants::notificationTypeFollow)
                        ->get();
                    $userNotification->each->delete();

                    $followingList->delete();

                    return response()->json([
                        'status' => true,
                        'message' => 'Unfollow user',
                        'data' => $followingList,
                    ]);
                } else {
                    return response()->json([
                        'status' => false,
                        'message' => 'User Not Found',
                    ]);
                }
            }
        } else {
            return response()->json([
                'status' => false,
                'message' => 'User Not Found',
            ]);
        }
    }

    public function fetchHomePageData(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'my_user_id' => 'required',
        ]);

        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->my_user_id)->first();

        if ($user) {

            $blockUserIds = explode(',', $user->block_user_ids);
            $hiddenUserIds = explode(',', $user->hidden_user_ids);

            $followingUsers = FollowingList::where('my_user_id', $request->my_user_id)
                ->whereRelation('story', 'created_at', '>=', now()->subDay()->toDateTimeString())
                ->with('user', 'user.images')
                ->whereRelation('user', 'is_block', 0)
                ->get()
                ->pluck('user');

            foreach ($followingUsers as $followingUser) {
                $stories = Story::where('user_id', $followingUser->id)
                    ->where('created_at', '>=', now()->subDay()->toDateTimeString())
                    ->get();

                foreach ($stories as $story) {
                    $story->storyView = $story->view_by_user_ids ? in_array($request->my_user_id, explode(',', $story->view_by_user_ids)) : false;
                }
                $followingUser->stories = $stories;
            }

            $fetchPosts = Post::with('content')
                ->inRandomOrder()
                ->with(['user', 'user.stories', 'user.images'])
                ->whereRelation('user', 'is_block', 0)
                ->whereNotIn('user_id', array_merge($blockUserIds))
                ->whereNotIn('user_id', array_merge($hiddenUserIds))
                ->limit(50)
                ->get();


            if (!$fetchPosts->isEmpty()) {
                foreach ($fetchPosts as $fetchPost) {
                    $isPostLike = Like::where('user_id', $request->my_user_id)->where('post_id', $fetchPost->id)->first();
                    if ($isPostLike) {
                        $fetchPost->is_like = 1;
                    } else {
                        $fetchPost->is_like = 0;
                    }
                }

                return response()->json([
                    'status' => true,
                    'message' => 'Fetch posts',
                    'data' =>  [
                        'users_stories' => $followingUsers,
                        'posts' => $fetchPosts,
                    ]
                ]);
            } else {
                return response()->json([
                    'status' => false,
                    'message' => 'Posts not Available',
                ]);
            }

            return response()->json([
                'status' => true,
                'message' => 'Fetch Home Page Data Successfully',
                'data' =>  [
                    'users_stories' => $followingUser,
                    'posts' => $fetchPosts,
                ]
            ]);
        } else {
            return response()->json([
                'status' => false,
                'message' => 'User Not Found',
            ]);
        }
    }

    public function deleteUserFromAdmin(Request $request)
    {
        $rules = [
            'user_id' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('id', $request->user_id)->first();
        if (!$user) {
            return json_encode([
                'status' => false,
                'message' => 'user not found!',
            ]);
        }

        $images = Images::where('user_id', $user->id)->get();
        foreach ($images as $image) {
            GlobalFunction::deleteFile($image->image);
            $image->delete();
        }
        $likes = Like::where('user_id', $user->id)->get();
        foreach ($likes as $like) {
            $postLikeCount = Post::where('id', $like->post_id)->first();
            $postLikeCount->likes_count -= 1;
            $postLikeCount->save();
            $like->delete();
        }
        $comments = Comment::where('user_id', $user->id)->get();
        foreach ($comments as $comment) {
            $postCommentCount = Post::where('id', $comment->post_id)->first();
            $postCommentCount->comments_count -= 1;
            $postCommentCount->save();
            $comment->delete();
        }

        $followerList = FollowingList::where('my_user_id', $user->id)->get();
        foreach ($followerList as $follower) {
            $followerUser = User::where('id', $follower->user_id)->first();
            $followerUser->followers -= 1;
            $followerUser->save();

            $follower->delete();
        }

        $followingList = FollowingList::where('user_id', $user->id)->get();
        foreach ($followingList as $following) {
            $followingUser = User::where('id', $following->user_id)->first();
            $followingUser->following -= 1;
            $followingUser->save();

            $following->delete();
        }

        LikedProfile::where('my_user_id', $user->id)->delete();
        LikedProfile::where('user_id', $user->id)->delete();

        $liveApplication = LiveApplications::where('user_id', $user->id)->first();
        if ($liveApplication) {
            GlobalFunction::deleteFile($liveApplication->intro_video);
            $liveApplication->delete();
        }

        LiveHistory::where('user_id', $user->id)->delete();

        $posts = Post::where('user_id', $user->id)->get();
        foreach ($posts as $post) {
            $postContents = PostContent::where('post_id', $post->id)->get();
            foreach ($postContents as $postContent) {
                GlobalFunction::deleteFile($postContent->content);
                GlobalFunction::deleteFile($postContent->thumbnail);
                $postContent->delete();
            }

            Comment::where('post_id', $post->id)->delete();
            Like::where('post_id', $post->id)->delete();
            Report::where('post_id', $post->id)->delete();
            UserNotification::where('post_id', $post->id)->delete();

            $post->delete();
        }

        RedeemRequest::where('user_id', $user->id)->delete();
        Report::where('user_id', $user->id)->delete();

        $stories = Story::where('user_id', $user->id)->get();
        foreach ($stories as $story) {
            GlobalFunction::deleteFile($story->content);
        }

        UserNotification::where('user_id', $user->id)->delete();
        UserNotification::where('my_user_id', $user->id)->delete();

        $verificationRequest = VerifyRequest::where('user_id', $user->id)->first();
        if ($verificationRequest) {
            GlobalFunction::deleteFile($verificationRequest->document);
            GlobalFunction::deleteFile($verificationRequest->selfie);
            $verificationRequest->delete();
        }

        $user->delete();

        return response()->json(['status' => true, 'message' => "Account Deleted Successfully !"]);
    }

    public function filteredProfiles(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'my_user_id' => 'required',
        ]);

        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::find($request->my_user_id);
        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'User not found',
            ]);
        }

        $setting = AppData::first();

        $userInterests = is_array($user->interests) ? $user->interests : explode(',', $user->interests ?? '');
        $userLanguages = is_array($user->language_keys) ? $user->language_keys : explode(',', $user->language_keys ?? '');

        $array = explode(',', $user->hidden_user_ids);

        $query = Users::where('is_block', 0)
            ->where('id', '!=', $user->id)
            ->whereNotIn('id', $array)
            ->with('images')
            ->has('images');

        if ($request->has('gender')) {
            $query->where('gender', $request->gender);
        }

        //	0 = Fake user Not Include | 1 = Fake User Include	
        if ($setting->include_fake_user_in_matching == 0) {
            $query->where('is_fake', 0);
        }

        if ($request->has('age_preferred_min') && $request->has('age_preferred_max')) {
            $query->whereRaw("TIMESTAMPDIFF(YEAR, dob, CURDATE()) BETWEEN ? AND ?", [
                $request->age_preferred_min,
                $request->age_preferred_max
            ]);
        }

        $profiles = $query->get();

        $distanceFiltered = $profiles->filter(function ($candidate) use ($user, $request) {
            if (!$user->lattitude || !$user->longitude || !$candidate->lattitude || !$candidate->longitude) {
                return true;
            }
            $radius = $request->distance_preference ?? 100;
            return Myfunction::point2point_distance(
                $user->lattitude,
                $user->longitude,
                $candidate->lattitude,
                $candidate->longitude,
                'K',
                $radius
            );
        });

        $matchedProfiles = $distanceFiltered->map(function ($candidate) use ($user, $userInterests, $userLanguages) {
            $candidateInterests = is_array($candidate->interests) ? $candidate->interests : explode(',', $candidate->interests ?? '');
            $candidateLanguages = is_array($candidate->language_keys) ? $candidate->language_keys : explode(',', $candidate->language_keys ?? '');

            $matchedInterests = array_values(array_intersect(array_map('trim', $userInterests), array_map('trim', $candidateInterests)));
            $matchedLanguages = array_values(array_intersect(array_map('trim', $userLanguages), array_map('trim', $candidateLanguages)));

            $matchedRelationshipGoal = ($user->relationship_goal_id && $candidate->relationship_goal_id == $user->relationship_goal_id)
                ? $user->relationship_goal_id
                : null;

            $matchedReligion = ($user->religion_key && $candidate->religion_key == $user->religion_key)
                ? $user->religion_key
                : null;

            $score = (count($matchedInterests) * 2) + (count($matchedLanguages) * 2);
            if ($matchedRelationshipGoal) $score += 3;
            if ($matchedReligion) $score += 3;

            $candidate->matched_interests = implode(',', $matchedInterests);
            $candidate->matched_languages = implode(',', $matchedLanguages);
            $candidate->matched_relationship_goal_id = $matchedRelationshipGoal;
            $candidate->matched_religion = $matchedReligion;
            $candidate->match_score = $score;

            return $candidate;
        })
            ->filter(function ($candidate) {
                return $candidate->match_score > 0;
            })
            ->sortByDesc('match_score')
            ->values();

        $start = (int)($request->start ?? 0);
        $limit = (int)($request->limit ?? 10);
        $paginated = $matchedProfiles->slice($start, $limit)->values();

        return response()->json([
            'status' => true,
            'message' => 'Matched profiles retrieved successfully',
            'total' => $matchedProfiles->count(),
            // 'start' => $start,
            // 'limit' => $limit,
            // 'count' => $paginated->count(),
            'data' => $paginated
        ]);
    }

    public function fetchMyHiddenProfiles(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'my_user_id' => 'required',
            'start' => 'required',
            'limit' => 'required',
        ]);

        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::find($request->my_user_id);
        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'User not found',
            ]);
        }

        $hiddenUserArray = explode(',', $user->hidden_user_ids);

        $query = Users::where('is_block', 0)
            ->where('id', '!=', $user->id)
            ->whereIn('id', $hiddenUserArray)
            ->with('images')
            ->has('images');

        $start = (int) $request->start;
        $limit = (int) $request->limit;

        $profiles = $query
            ->offset($start)
            ->limit($limit)
            ->get();

        return response()->json([
            'status' => true,
            'message' => 'Fetch My Hidden Profiles successfully',
            'data' => $profiles
        ]);
    }

    function fakeUserLogin(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'identity' => 'required',
            'password' => 'required',
            'device_token' => 'nullable|string',
            'device_type'   => 'nullable|string',
        ]);

        if ($validator->fails()) {
            $messages = $validator->errors()->all();
            $msg = $messages[0];
            return response()->json(['status' => false, 'message' => $msg]);
        }

        $user = Users::where('identity', $request->identity)->first();
        if ($user == null) {
            return response()->json([
                'status' => false,
                'message' => 'user not found!',
                'data' => $user
            ]);
        }

        if ($request->identity !== $user->identity || $request->password !== $user->password) {
            return response()->json([
                'status' => false,
                'message' => 'Invalid credentials'
            ]);
        }

        if ($request->filled('device_token')) {
            $user->device_token = $request->device_token;
            if ($request->filled('device_type')) {
                $user->device_type = (int) $request->device_type;
            }
            $user->save();
        }

        return response()->json([
            'status' => true,
            'message' => 'Login successful',
            'data' => $user
        ]);
    }
}

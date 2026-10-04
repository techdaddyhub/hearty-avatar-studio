<?php

namespace App\Http\Controllers;

use App\Models\Admin;
use App\Models\AppData;
use App\Models\DiamondPacks;
use App\Models\Gifts;
use App\Models\GlobalFunction;
use App\Models\Interest;
use App\Models\LiveApplications;
use App\Models\Post;
use App\Models\RedeemRequest;
use App\Models\Report;
use App\Models\Users;
use App\Models\VerifyRequest;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Session;

class LoginController extends Controller
{
    function index()
    {
        $totalUsers = Users::count();
        $liveStreamUsers = Users::where('can_go_live', 2)->count();
        $blockedUsers = Users::where('is_block', 1)->count();
        $liveApplications = LiveApplications::count();
        $pendingRedeems = RedeemRequest::where('status', 0)->count();
        $completedRedeems = RedeemRequest::where('status', 1)->count();
        $diamondPacks = DiamondPacks::count();
        $gifts = Gifts::count();
        $verifyRequests = VerifyRequest::count();
        $reports = Report::count();
        $interests = Interest::count();
        $totalPosts = Post::count();
        return view('index')->with([
            'totalUsers' => $totalUsers,
            'liveStreamUsers' => $liveStreamUsers,
            'blockedUsers' => $blockedUsers,
            'liveApplications' => $liveApplications,
            'pendingRedeems' => $pendingRedeems,
            'completedRedeems' => $completedRedeems,
            'gifts' => $gifts,
            'diamondPacks' => $diamondPacks,
            'verifyRequests' => $verifyRequests,
            'reports' => $reports,
            'interests' => $interests,
            'totalPosts' => $totalPosts,
        ]);
    }
    function login()
    {
        Artisan::call('storage:link');

        if (Session::get('user_name')) {
            return redirect('index');
        }

        return  view('login.login');
    }

    // function checklogin(Request $req)
    // {
    //     $setting = AppData::first();
    //     if ($setting) {
    //         Session::put('app_name', $setting->app_name);
    //     }

    //     $data = Admin::where('user_name', $req->user_name)->first();

    //     Artisan::call('storage:link');

    //     if ($req->user_name == $data['user_name'] && $req->user_password == $data['user_password']) {
    //         $req->session()->put('user_name', $data['user_name']);
    //         $req->session()->put('user_password', $data['user_password']);
    //         $req->session()->put('user_type', $data['user_type']);
    //         return response()->json([
    //             'status' => true,
    //             'message' => 'login successfully.',
    //         ]);
    //     } else {
    //         return response()->json([
    //             'status' => false,
    //             'message' => 'Something went wrong.',
    //         ]);
    //     }
    // }

    public function checkLogin(Request $request)
    {
        $data = Admin::where('user_name', $request->user_name)->first();

        if ($data && Crypt::decrypt($data->user_password) === $request->user_password) {
            $request->session()->put('user_name', $data['user_name']);
            $request->session()->put('user_type', $data['user_type']);

            return response()->json([
                'status' => true,
                'message' => 'Login successful'
            ]);
        }

        return response()->json([
            'status' => false,
            'message' => 'Invalid credentials'
        ]);
    }

    public function forgotPasswordForm(Request $request)
    {
        $databaseUsername = env('DB_USERNAME');
        $databasePassword = env('DB_PASSWORD');

        if ($request->database_username == $databaseUsername && $request->database_password == $databasePassword) {

            $encryptedPassword = Crypt::encrypt($request->new_password);

            $admin = Admin::where('user_name', 'admin')->first();

            if (!$admin) {
                return GlobalFunction::sendSimpleResponse(false, 'Admin user not found.');
            }

            $admin->user_password = $encryptedPassword;
            $admin->save();

            return GlobalFunction::sendSimpleResponse(true, 'Password updated successfully.');
        } else {
            return GlobalFunction::sendSimpleResponse(false, 'Wrong credentials.');
        }
    }

    function logout()
    {
        session()->pull('user_name');
        session()->pull('user_password');
        session()->pull('user_type');
        return  redirect(url('/'));
    }

    function profile()
    {
        $data = Admin::first();
        return view('setting.profile', ['data' => $data]);
    }

    function updateProflie(Request $req)
    {

        $item = Admin::where('user_id', 1)->update([
            'user_password' => $req->user_password,
            'user_name' => $req->user_name
        ]);


        return  json_encode(['status' => true, "message" => "Update susseccfull"]);
    }
}

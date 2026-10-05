<?php

namespace App\Http\Controllers;

use App\Classes\AgoraDynamicKey\RtcTokenBuilder;
use App\Models\Admin;
use App\Models\AppData;
use App\Models\Gifts;
use App\Models\GlobalFunction;
use App\Models\Interest;
use App\Models\Language;
use App\Models\OnboardingScreen;
use App\Models\Post;
use App\Models\RelationshipGoal;
use App\Models\Religion;
use App\Models\Users;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Validator;

include "./app/Class/AgoraDynamicKey/RtcTokenBuilder.php";

class SettingController extends Controller
{

   function generateAgoraToken(Request $request)
   {
      $rules = [
         'channelName' => 'required'
      ];
      $validator = Validator::make($request->all(), $rules);
      if ($validator->fails()) {
         $messages = $validator->errors()->all();
         $msg = $messages[0];
         return response()->json(['status' => false, 'message' => $msg]);
      }
      $appID = env('AGORA_APP_ID');
      $appCertificate = env('AGORA_APP_CERT');
      $channelName = $request->channelName;
      $role = RtcTokenBuilder::RolePublisher;
      $expireTimeInSeconds = 7200;
      $currentTimestamp = now()->getTimestamp();
      $privilegeExpiredTs = $currentTimestamp + $expireTimeInSeconds;
      $token = RtcTokenBuilder::buildTokenWithUid($appID, $appCertificate, $channelName, 0, $role, $privilegeExpiredTs);

      return json_encode(['status' => true, 'message' => "generated successfully", 'token' => $token]);
   }

   function changeFromDatingAppToLivestreamApp($value)
   {
      DB::table('appdata')->where('id', 1)->update([
         'is_dating' => $value,
      ]);

      return json_encode(['status' => true, 'message' => __('app.Updatesuccessful')]);
   }

   function changeFromSocialMedia($value)
   {
      DB::table('appdata')->where('id', 1)->update([
         'is_social_media' => $value,
      ]);

      return json_encode(['status' => true, 'message' => __('app.Updatesuccessful')]);
   }

   function includeFakeUserInMatching($value)
   {
      DB::table('appdata')->where('id', 1)->update([
         'include_fake_user_in_matching' => $value,
      ]);

      return json_encode(['status' => true, 'message' => __('app.Updatesuccessful')]);
   }

   function updateGift(Request $request)
   {
      $gift = Gifts::where('id', $request->id)->first();
      $gift->coin_price = $request->coin_price;
      if ($request->has('image')) {
         GlobalFunction::deleteFile($gift->image);

         $gift->image = GlobalFunction::saveFileAndGivePath($request->image);
      }
      $gift->save();

      return response()->json([
         'status' => true,
         'message' => 'Gift Update Successfully',
      ]);
   }

   function addGift(Request $request)
   {
      $gift = new Gifts();
      $gift->image = GlobalFunction::saveFileAndGivePath($request->image);
      $gift->coin_price = $request->coin_price;
      $gift->save();

      return response()->json([
         'status' => true,
         'message' => "Gift Added Successfully.",
         'data' => $gift,
      ]);
   }

   function deleteGift(Request $request)
   {
      $gift = Gifts::where('id', $request->gift_id)->first();
      GlobalFunction::deleteFile($gift->image);
      $gift->delete();

      return response()->json([
         'status' => true,
         'message' => 'Gift Delete Successfully.',
      ]);
   }

   function fetchAllGifts(Request $request)
   {
      $totalData =  Gifts::count();
      $rows = Gifts::orderBy('id', 'DESC')->get();

      $result = $rows;

      $columns = array(
         0 => 'id',
         1 => 'coin_price'
      );

      $limit = $request->input('length');
      $start = $request->input('start');
      $order = $columns[$request->input('order.0.column')];
      $dir = $request->input('order.0.dir');
      $totalData = Gifts::count();
      $totalFiltered = $totalData;
      if (empty($request->input('search.value'))) {
         $result = Gifts::offset($start)
            ->limit($limit)
            ->orderBy($order, $dir)
            ->get();
      } else {
         $search = $request->input('search.value');
         $result =  Gifts::Where('coin_price', 'LIKE', "%{$search}%")
            ->offset($start)
            ->limit($limit)
            ->orderBy($order, $dir)
            ->get();
         $totalFiltered = Gifts::where('coin_price', 'LIKE', "%{$search}%")
            ->count();
      }
      $data = array();
      foreach ($result as $item) {

         $image = '<img src="public/storage/' . $item->image . '" width="50" height="50">';
         $imgUrl = env('image') . $item->image;

         $action = '<a data-img="' . $imgUrl . '" 
                     data-price="' . $item->coin_price . '"
                     rel="' . $item->id . '" 
                     class="btn btn-success edit text-white mr-2">
                     Edit
                     </a>
                     <a rel="' . $item->id . '"
                     class="btn btn-danger delete text-white">
                     Delete
                     </a>';

         $data[] = array(
            $image,
            $item->coin_price,
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

   function gifts()
   {
      return view('gifts');
   }

   function setting()
   {
      $appdata = AppData::first();

      $packageName = '';
      $sha256 = '';
      $iosAppId = '';
      $iosPackageName = '';
      $iosTeamId = '';

      // --------------------
      // Android assetlinks.json
      // --------------------
      $assetFilePath = public_path('asset/assetlinks.json');
      if (File::exists($assetFilePath)) {
         $jsonContent = File::get($assetFilePath);
         $data = json_decode($jsonContent, true);

         if (!empty($data) && isset($data[0]['target'])) {
            $packageName = $data[0]['target']['package_name'] ?? '';
            $sha256 = isset($data[0]['target']['sha256_cert_fingerprints'])
               ? implode(',', $data[0]['target']['sha256_cert_fingerprints'])
               : '';
         }
      }

      // --------------------
      // iOS apple-app-site-association
      // --------------------
      $aasaFilePath = public_path('asset/apple-app-site-association');
      if (File::exists($aasaFilePath)) {
         $jsonContent = File::get($aasaFilePath);
         $data = json_decode($jsonContent, true);

         if (!empty($data) && isset($data['applinks']['details'][0]['appIDs'][0])) {
            $appId = $data['applinks']['details'][0]['appIDs'][0];
            $iosAppId = $appId;

            $parts = explode('.', $appId, 2);
            if (count($parts) === 2) {
               $iosTeamId = $parts[0];
               $iosPackageName = $parts[1];
            }
         }
      }

      return view('setting', compact(
         'appdata',
         'packageName',
         'sha256',
         'iosAppId',
         'iosPackageName',
         'iosTeamId'
      ));
   }

   function updateAppdata(Request $request)
   {
      $setting = AppData::first();

      if ($setting == null) {
         return response()->json([
            'status' => false,
            'message' => 'Setting Not Found',
         ]);
      }

      if ($request->has('app_name')) {
         $setting->app_name = $request->app_name;
         $request->session()->put('app_name', $setting['app_name']);
      }
      if ($request->has('currency')) {
         $setting->currency = $request->currency;
      }
      if ($request->has('min_threshold')) {
         $setting->min_threshold = $request->min_threshold;
      }
      if ($request->has('min_user_live')) {
         $setting->min_user_live = $request->min_user_live;
      }
      if ($request->has('max_minute_live')) {
         $setting->max_minute_live = $request->max_minute_live;
      }
      if ($request->has('message_price')) {
         $setting->message_price = $request->message_price;
      }
      if ($request->has('new_user_free_coins')) {
         $setting->new_user_free_coins = $request->new_user_free_coins;
      }
      if ($request->has('reverse_swipe_price')) {
         $setting->reverse_swipe_price = $request->reverse_swipe_price;
      }
      if ($request->has('coin_rate')) {
         $setting->coin_rate = $request->coin_rate;
      }
      if ($request->has('admob_int_ios')) {
         $setting->admob_int_ios = $request->admob_int_ios;
      }
      if ($request->has('admob_banner_ios')) {
         $setting->admob_banner_ios = $request->admob_banner_ios;
      }
      if ($request->has('admob_int')) {
         $setting->admob_int = $request->admob_int;
      }
      if ($request->has('admob_banner')) {
         $setting->admob_banner = $request->admob_banner;
      }
      if ($request->has('live_watching_price')) {
         $setting->live_watching_price = $request->live_watching_price;
      }
      if ($request->has('post_description_limit')) {
         $setting->post_description_limit = $request->post_description_limit;
      }
      if ($request->has('post_upload_image_limit')) {
         $setting->post_upload_image_limit = $request->post_upload_image_limit;
      }
      if ($request->has('stream_and_gift_commission')) {
         $setting->stream_and_gift_commission = $request->stream_and_gift_commission;
      }
      if ($request->has('app_store_download_link')) {
         $setting->app_store_download_link = $request->app_store_download_link;
      }
      if ($request->has('play_store_download_link')) {
         $setting->play_store_download_link = $request->play_store_download_link;
      }
      if ($request->has('uri_scheme')) {
         $setting->uri_scheme = $request->uri_scheme;
      }
      $setting->save();

      return response()->json([
         'status' => true,
         'message' => __('app.Updatesuccessful'),
      ]);
   }

   public function androidDeepLinking(Request $request)
   {
      $request->validate([
         'sha_256' => 'required|array',
         'sha_256.*' => 'string', // each element must be a string
         'package_name' => 'required|string',
      ]);

      $filePath = public_path('asset/assetlinks.json');

      // Convert all values to uppercase
      $shaArray = array_map(function ($val) {
         return strtoupper(trim($val));
      }, $request->sha_256);

      // Build new JSON structure (overwrite everything)
      $data = [
         [
            "relation" => ["delegate_permission/common.handle_all_urls"],
            "target" => [
               "namespace" => "android_app",
               "package_name" => $request->package_name,
               "sha256_cert_fingerprints" => $shaArray,
            ]
         ]
      ];

      // Save file (pretty JSON)
      File::put($filePath, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));

      return response()->json([
         'status' => true,
         'message' => 'assetlinks.json file replaced successfully',
         'data' => $data,
      ]);
   }

   public function iOSDeepLinking(Request $request)
   {
       $validator = Validator::make($request->all(), [
           'team_id' => 'required|string',
           'package_name' => 'required|string',
       ]);

       if ($validator->fails()) {
           return response()->json([
               'status' => false,
               'message' => $validator->errors()->first(),
           ]);
       }

       $teamId = strtoupper(trim($request->team_id)); // Ensure uppercase
       $packageName = trim($request->package_name);

       // Build AppID
       $appId = $teamId . '.' . $packageName;

       // Construct AASA structure
       $aasaData = [
           "applinks" => [
               "apps" => [],
               "details" => [
                   [
                       "appIDs" => [$appId],
                       "components" => [
                           [
                               "/" => "*",
                               "?" => ["\$web_only" => "true"],
                               "exclude" => true,
                               "comment" => "Exclude web_only links"
                           ],
                           [
                               "/" => "*",
                               "?" => ["%24web_only" => "true"],
                               "exclude" => true,
                               "comment" => "Exclude encoded web_only links"
                           ],
                           [
                               "/" => "/e/*",
                               "exclude" => true,
                               "comment" => "Exclude /e/* paths"
                           ],
                           [
                               "/" => "*",
                               "comment" => "Allow all other paths"
                           ],
                           [
                               "/" => "/",
                               "comment" => "Allow root path"
                           ]
                       ]
                   ]
               ]
           ],
           "webcredentials" => [
               "apps" => [$appId]
           ]
       ];

       // Save to root public folder (no extension for iOS)
       $filePath = public_path('asset/apple-app-site-association');
       File::put($filePath, json_encode($aasaData, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));

       return response()->json([
           'status' => true,
           'message' => 'iOS Deep Linking settings saved successfully.',
       ]);
   }

   function getSettingData(Request $req)
   {
      $data['appdata'] = DB::table('appdata')->first();
      $data['gifts'] = Gifts::all();
      $data['interests'] = Interest::orderByDesc('id')->get();
      $data['relationship_goals'] = RelationshipGoal::orderByDesc('id')->get();
      $data['religions'] = Religion::orderByDesc('id')->get();
      $data['language'] = Language::where('is_deleted', 0)->orderBy('title', 'asc')->get();
      $data['onboarding_screen'] = OnboardingScreen::get();

      return response()->json([
         'status' => true,
         'message' => __('app.fetchSuccessful'),
         'data' => $data
      ]);
   }

   public function storeFileGivePath(Request $request)
   {
      $path = GlobalFunction::saveFileAndGivePath($request->file);
      return response()->json([
         'status' => true,
         'message' => __('app.Updatesuccessful'),
         'path' => $path,
      ]);
   }

   // fetchChartData
   function fetchChartData(Request $request)
   {
      $month = $request->month;
      $year = $request->year;

      $startDate = Carbon::create($year, $month, 1);
      $endDate = Carbon::create($year, $month, 1)->endOfMonth();
      $dates = collect();

      $datesWithCount = [];
      for ($date = $startDate; $date->lte($endDate); $date->addDay()) {
         $formattedDate = $date->format('Y-m-d');
         $dates->push($formattedDate);

         $usersCount = Users::whereDate('created_at', $date)->count();
         $postsCount = Post::whereDate('created_at', $date)->count();

         $datesWithCount[] = [
            'date' => $formattedDate,
            'usersCount' => $usersCount,
            'postsCount' => $postsCount,
         ];
      }
      return GlobalFunction::sendDataResponse(true, 'Users fetched successfully.', $datesWithCount);
   }

   public function changePassword(Request $request)
   {
      $validator = Validator::make($request->all(), [
         'user_password' => 'required|string',
         'new_password' => 'required|string', // requires new_password_confirmation
      ]);

      if ($validator->fails()) {
         return GlobalFunction::sendSimpleResponse(false, $validator->errors()->first());
      }

      $admin = Admin::where('user_type', 1)->first();
      if (!$admin) {
         return GlobalFunction::sendSimpleResponse(false, 'Admin not found.');
      }

      try {
         $decryptedPassword = Crypt::decrypt($admin->user_password);

         if ($request->user_password !== $decryptedPassword) {
            return GlobalFunction::sendSimpleResponse(false, 'Old password does not match.');
         }

         // Encrypt and save new password
         $admin->user_password = Crypt::encrypt($request->new_password);
         $admin->save();

         return GlobalFunction::sendSimpleResponse(true, 'Password changed successfully.');
      } catch (\Exception $e) {
         return GlobalFunction::sendSimpleResponse(false, 'Password decryption failed.');
      }
   }
}

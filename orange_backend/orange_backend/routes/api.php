<?php

use App\Http\Controllers\AvatarController;
use App\Http\Controllers\CallController;
use App\Http\Controllers\DiamondPackController;
use App\Http\Controllers\InterestController;
use App\Http\Controllers\LiveApplicationController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\ObsController;
use App\Http\Controllers\PackageController;
use App\Http\Controllers\PostController;
use App\Http\Controllers\RedeemRequestsController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\SettingController;
use App\Http\Controllers\SocialAccountController;
use App\Http\Controllers\TelemetryController;
use App\Http\Controllers\StreamController;
use App\Http\Controllers\UsersController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/


/*|--------------------------------------------------------------------------|
  | Users Route                                                              |
  |--------------------------------------------------------------------------|*/

Route::post('register', [UsersController::class, 'addUserDetails'])->middleware('checkHeader');
Route::post('updateProfile', [UsersController::class, 'updateProfile'])->middleware('checkHeader');
Route::post('fetchUsersByCordinates', [UsersController::class, 'fetchUsersByCordinates'])->middleware('checkHeader');
Route::post('updateUserBlockList', [UsersController::class, 'updateUserBlockList'])->middleware('checkHeader');
Route::post('deleteMyAccount', [UsersController::class, 'deleteMyAccount'])->middleware('checkHeader');
Route::post('fetchMyUserProfile', [UsersController::class, 'fetchMyUserProfile'])->middleware('checkHeader');

Route::post('getProfile', [UsersController::class, 'getProfile'])->middleware('checkHeader');
Route::post('getUserDetails', [UsersController::class, 'getUserDetails'])->middleware('checkHeader');
Route::post('getRandomProfile', [UsersController::class, 'getRandomProfile'])->middleware('checkHeader');
Route::post('getExplorePageProfileList', [UsersController::class, 'getExplorePageProfileList'])->middleware('checkHeader');
Route::post('filteredProfiles', [UsersController::class, 'filteredProfiles'])->middleware('checkHeader');
Route::post('yourMatchings', [UsersController::class, 'yourMatchings'])->middleware('checkHeader');

Route::post('updateSavedProfile', [UsersController::class, 'updateSavedProfile'])->middleware('checkHeader');
// Route::post('updateLikedProfile', [UsersController::class, 'updateLikedProfile'])->middleware('checkHeader');
Route::post('likedProfile', [UsersController::class, 'likedProfile'])->middleware('checkHeader');
Route::post('dislikedProfile', [UsersController::class, 'dislikedProfile'])->middleware('checkHeader');

Route::post('fetchSavedProfiles', [UsersController::class, 'fetchSavedProfiles'])->middleware('checkHeader');
Route::post('fetchLikedProfiles', [UsersController::class, 'fetchLikedProfiles'])->middleware('checkHeader');

Route::post('getPackage', [PackageController::class, 'getPackage'])->middleware('checkHeader');
Route::post('addUserReport', [ReportController::class, 'addUserReport'])->middleware('checkHeader');
Route::post('getSettingData', [SettingController::class, 'getSettingData'])->middleware('checkHeader');

Route::post('searchUsers', [UsersController::class, 'searchUsers'])->middleware('checkHeader');
Route::post('searchUsersForInterest', [UsersController::class, 'searchUsersForInterest'])->middleware('checkHeader');

Route::post('getUserNotifications', [NotificationController::class, 'getUserNotifications'])->middleware('checkHeader');
Route::post('getAdminNotifications', [NotificationController::class, 'getAdminNotifications'])->middleware('checkHeader');

Route::post('getDiamondPacks', [DiamondPackController::class, 'getDiamondPacks'])->middleware('checkHeader');

Route::post('onOffNotification', [UsersController::class, 'onOffNotification'])->middleware('checkHeader');
Route::post('updateLiveStatus', [UsersController::class, 'updateLiveStatus'])->middleware('checkHeader');
Route::post('onOffShowMeOnMap', [UsersController::class, 'onOffShowMeOnMap'])->middleware('checkHeader');
Route::post('onOffAnonymous', [UsersController::class, 'onOffAnonymous'])->middleware('checkHeader');
Route::post('onOffVideoCalls', [UsersController::class, 'onOffVideoCalls'])->middleware('checkHeader');

Route::post('fetchBlockedProfiles', [UsersController::class, 'fetchBlockedProfiles'])->middleware('checkHeader');

Route::post('applyForLive', [LiveApplicationController::class, 'applyForLive'])->middleware('checkHeader');
Route::post('applyForVerification', [UsersController::class, 'applyForVerification'])->middleware('checkHeader');

Route::post('addCoinsToWallet', [UsersController::class, 'addCoinsToWallet'])->middleware('checkHeader');
Route::post('minusCoinsFromWallet', [UsersController::class, 'minusCoinsFromWallet'])->middleware('checkHeader');
Route::post('increaseStreamCountOfUser', [UsersController::class, 'increaseStreamCountOfUser'])->middleware('checkHeader');

Route::post('addLiveStreamHistory', [LiveApplicationController::class, 'addLiveStreamHistory'])->middleware('checkHeader');
Route::post('logOutUser', [UsersController::class, 'logOutUser'])->middleware('checkHeader');
Route::post('fetchAllLiveStreamHistory', [LiveApplicationController::class, 'fetchAllLiveStreamHistory'])->middleware('checkHeader');

Route::post('placeRedeemRequest', [RedeemRequestsController::class, 'placeRedeemRequest'])->middleware('checkHeader');
Route::post('fetchMyRedeemRequests', [RedeemRequestsController::class, 'fetchMyRedeemRequests'])->middleware('checkHeader');
Route::post('pushNotificationToSingleUser', [NotificationController::class, 'pushNotificationToSingleUser'])->middleware('checkHeader');

Route::post('followUser', [UsersController::class, 'followUser'])->middleware('checkHeader');
Route::post('fetchFollowingList', [UsersController::class, 'fetchFollowingList'])->middleware('checkHeader');
Route::post('fetchFollowersList', [UsersController::class, 'fetchFollowersList'])->middleware('checkHeader');
Route::post('unfollowUser', [UsersController::class, 'unfollowUser'])->middleware('checkHeader');
Route::post('fetchMyHiddenProfiles', [UsersController::class, 'fetchMyHiddenProfiles'])->middleware('checkHeader');

Route::post('fetchHomePageData', [UsersController::class, 'fetchHomePageData'])->middleware('checkHeader');

Route::post('createStory', [PostController::class, 'createStory'])->middleware('checkHeader');
Route::post('viewStory', [PostController::class, 'viewStory'])->middleware('checkHeader');
Route::post('fetchStories', [PostController::class, 'fetchStories'])->middleware('checkHeader');
Route::post('deleteStory', [PostController::class, 'deleteStory'])->middleware('checkHeader');

Route::post('reportPost', [PostController::class, 'reportPost'])->middleware('checkHeader');

Route::post('addPost', [PostController::class, 'addPost'])->middleware('checkHeader');
// Route::post('fetchPosts', [PostController::class, 'fetchPosts'])->middleware('checkHeader');
Route::post('addComment', [PostController::class, 'addComment'])->middleware('checkHeader');
Route::post('fetchComments', [PostController::class, 'fetchComments'])->middleware('checkHeader');
Route::post('deleteComment', [PostController::class, 'deleteComment'])->middleware('checkHeader');
Route::post('likePost', [PostController::class, 'likePost'])->middleware('checkHeader');
Route::post('dislikePost', [PostController::class, 'dislikePost'])->middleware('checkHeader');
Route::post('deleteMyPost', [PostController::class, 'deleteMyPost'])->middleware('checkHeader');
Route::post('fetchPostByUser', [PostController::class, 'fetchPostByUser'])->middleware('checkHeader');
Route::post('fetchPostsByHashtag', [PostController::class, 'fetchPostsByHashtag'])->middleware('checkHeader');
Route::post('fetchPostByPostId', [PostController::class, 'fetchPostByPostId'])->middleware('checkHeader');
Route::post('increasePostViewCount', [PostController::class, 'increasePostViewCount'])->middleware('checkHeader');

Route::get('deleteStoryFromWeb', [PostController::class, 'deleteStoryFromWeb'])->name('deleteStoryFromWeb');
Route::post('storeFileGivePath', [SettingController::class, 'storeFileGivePath'])->middleware('checkHeader');
Route::post('generateAgoraToken', [SettingController::class, 'generateAgoraToken'])->middleware('checkHeader');

Route::post('fakeUserLogin', [UsersController::class, 'fakeUserLogin'])->middleware('checkHeader');

/*|--------------------------------------------------------------------------|
  | Avatar Studio & Social Streaming v1 Routes                              |
  |--------------------------------------------------------------------------|*/

Route::prefix('v1')->middleware('checkHeader')->group(function () {
    // Avatar Management
    Route::post('avatars/list', [AvatarController::class, 'fetchUserAvatars']);
    Route::post('avatars/save', [AvatarController::class, 'saveAvatar']);
    Route::post('avatars/upload-asset', [AvatarController::class, 'uploadAvatarAsset']);
    Route::post('avatars/set-default', [AvatarController::class, 'setDefaultAvatar']);
    Route::post('avatars/delete', [AvatarController::class, 'deleteAvatar']);

    // Video Calls (LiveKit / WebRTC)
    Route::post('calls', [CallController::class, 'initiateCall']);
    Route::post('calls/accept', [CallController::class, 'acceptCall']);
    Route::post('calls/reject', [CallController::class, 'rejectCall']);
    Route::post('calls/end', [CallController::class, 'endCall']);
    Route::post('calls/status', [CallController::class, 'getCallStatus']);
    Route::post('calls/update-avatar', [CallController::class, 'updateCallAvatar']);

    // Live Streaming & Multi-destination RTMP
    Route::post('streams/create', [StreamController::class, 'createStream']);
    Route::post('streams/details', [StreamController::class, 'getStreamDetails']);
    Route::post('streams/update-status', [StreamController::class, 'updateStreamStatus']);
    Route::post('streams/add-destination', [StreamController::class, 'addStreamDestination']);
    Route::post('streams/toggle-destination', [StreamController::class, 'toggleDestination']);
    Route::post('streams/remove-destination', [StreamController::class, 'removeStreamDestination']);

    // Social Media Accounts (OAuth2 & Streaming integration)
    Route::post('social-accounts/list', [SocialAccountController::class, 'fetchAccounts']);
    Route::post('social-accounts/connect', [SocialAccountController::class, 'connectAccount']);
    Route::post('social-accounts/disconnect', [SocialAccountController::class, 'disconnectAccount']);

    // OBS Studio & Virtual Camera
    Route::post('obs/config', [ObsController::class, 'getObsConfig']);
    Route::post('obs/vcam-status', [ObsController::class, 'getVirtualCameraStatus']);

    // Cross-Platform Devices & Telemetry
    Route::post('devices/register', [TelemetryController::class, 'registerDevice']);
    Route::post('telemetry/metrics', [TelemetryController::class, 'recordMetrics']);
});

@extends('include.app')
@section('header')
<script src="{{ asset('asset/script/setting.js') }}"></script>
@endsection

@section('content')


<form autocomplete="off" class="appdataForm mb-3" action="" method="post">
    @csrf

    <div class="row">
        <div class="col-lg-2 mb-2 mb-sm-0">
            <div class="card">
                <div class="card-body p-2">
                    <div class="nav flex-column nav-pills" id="v-pills-tab" role="tablist" aria-orientation="vertical">
                        <a class="main-nav-link fw-normal nav-link active" id="v-pills-general-settings-tab" data-bs-toggle="pill" href="#v-pills-general-settings" role="tab" aria-controls="v-pills-general-settings" aria-selected="true">
                            {{ __('General Settings')}}
                        </a>
                        <a class="main-nav-link fw-normal nav-link" id="v-pills-live-streaming-tab" data-bs-toggle="pill" href="#v-pills-live-streaming" role="tab" aria-controls="v-pills-live-streaming" aria-selected="true">
                            {{ __('Live Streaming')}}
                        </a>
                        <a class="main-nav-link fw-normal nav-link" id="v-pills-pricing-tab" data-bs-toggle="pill" href="#v-pills-pricing" role="tab" aria-controls="v-pills-pricing" aria-selected="true">
                            {{ __('Pricing')}}
                        </a>
                        <a class="main-nav-link fw-normal nav-link" id="v-pills-feature-toggles-tab" data-bs-toggle="pill" href="#v-pills-feature-toggles" role="tab" aria-controls="v-pills-feature-toggles" aria-selected="true">
                            {{ __('Feature Toggles')}}
                        </a>
                        <a class="main-nav-link fw-normal nav-link" id="v-pills-commission-tab" data-bs-toggle="pill" href="#v-pills-commission" role="tab" aria-controls="v-pills-commission" aria-selected="true">
                            {{ __('Commission')}}
                        </a>
                        <a class="main-nav-link fw-normal nav-link" id="v-pills-post-setting-tab" data-bs-toggle="pill" href="#v-pills-post-setting" role="tab" aria-controls="v-pills-post-setting" aria-selected="true">
                            {{ __('Post Setting')}}
                        </a>
                        <a class="main-nav-link fw-normal nav-link" id="v-pills-admob-tab" data-bs-toggle="pill" href="#v-pills-admob" role="tab" aria-controls="v-pills-admob" aria-selected="true">
                            {{ __('Admob')}}
                        </a>
                        <a class="main-nav-link fw-normal nav-link" id="v-pills-deep-link-tab" data-bs-toggle="pill" href="#v-pills-deep-link" role="tab" aria-controls="v-pills-deep-link" aria-selected="true">
                            {{ __('Deep Linking')}}
                        </a>
                        <a class="main-nav-link fw-normal nav-link" id="v-pills-change-password-tab" data-bs-toggle="pill" href="#v-pills-change-password" role="tab" aria-controls="v-pills-change-password" aria-selected="true">
                            {{ __('Change Password')}}
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-10">
            <div class="tab-content" id="v-pills-tabContent">
                <div class="tab-pane fade active show" id="v-pills-general-settings" role="tabpanel" aria-labelledby="v-pills-general-settings-tab">
                    <!-- General Settings -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0">General Settings</h5>
                        </div>
                        <div class="card-body">
                            <div class="form-row">
                                <div class="form-group col-md-3 m-0">
                                    <label>{{ __('app.App_name') }}</label>
                                    <input type="text" class="form-control" name="app_name" id="app_name" value="{{ $appdata->app_name }}" required>
                                </div>
                                <div class="form-group col-md-3 m-0">
                                    <label>{{ __('app.Currency') }}</label>
                                    <input type="text" class="form-control" name="currency" value="{{ $appdata->currency }}" required>
                                </div>
                                <div class="form-group col-md-3 m-0">
                                    <label>{{ __('app.Minimum_Threshold') }}</label>
                                    <input type="text" class="form-control" name="min_threshold" value="{{ $appdata->min_threshold }}" required>
                                </div>
                                <div class="form-group col-md-3 m-0">
                                    <label>{{ __('app.Coin_Rate') }}</label>
                                    <input type="number" step="0.000001" class="form-control" name="coin_rate" value="{{ $appdata->coin_rate }}" required>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Save Button -->
                    <div class="text-left">
                        <button class="btn btn-primary" type="submit">{{ __('app.Save') }}</button>
                    </div>
                </div>
                <div class="tab-pane fade" id="v-pills-live-streaming" role="tabpanel" aria-labelledby="v-pills-live-streaming-tab">
                    <!-- Live Streaming Settings -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0">Live Streaming Settings</h5>
                        </div>
                        <div class="card-body">
                            <div class="form-row">
                                <div class="form-group col-md-6 m-0">
                                    <label>{{ __('app.Minimum_users_needed') }}</label>
                                    <input type="text" class="form-control" name="min_user_live" value="{{ $appdata->min_user_live }}" required>
                                </div>
                                <div class="form-group col-md-6 m-0">
                                    <label>{{ __('app.Maximum_minutes_for_live') }}</label>
                                    <input type="text" class="form-control" name="max_minute_live" value="{{ $appdata->max_minute_live }}" required>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Save Button -->
                    <div class="text-left">
                        <button class="btn btn-primary" type="submit">{{ __('app.Save') }}</button>
                    </div>
                </div>
                <div class="tab-pane fade" id="v-pills-pricing" role="tabpanel" aria-labelledby="v-pills-pricing-tab">
                    <!-- Pricing Settings -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0">Pricing Settings</h5>
                        </div>
                        <div class="card-body">
                            <div class="form-row">
                                <div class="form-group col-md-4">
                                    <label>{{ __('app.Message_price') }}</label>
                                    <input type="number" class="form-control" name="message_price" value="{{ $appdata->message_price }}" required>
                                </div>
                                <div class="form-group col-md-4">
                                    <label>{{ __('app.Reverse_swipe_price') }}</label>
                                    <input type="number" class="form-control" name="reverse_swipe_price" value="{{ $appdata->reverse_swipe_price }}" required>
                                </div>
                                <div class="form-group col-md-4">
                                    <label>{{ __('app.Live_watching_price') }}</label>
                                    <input type="number" class="form-control" name="live_watching_price" value="{{ $appdata->live_watching_price }}" required>
                                </div>
                                <div class="form-group col-md-4">
                                    <label>{{ __('app.new_user_free_coins') }}</label>
                                    <input type="number" class="form-control" name="new_user_free_coins" value="{{ $appdata->new_user_free_coins }}" required>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Save Button -->
                    <div class="text-left">
                        <button class="btn btn-primary" type="submit">{{ __('app.Save') }}</button>
                    </div>
                </div>
                <div class="tab-pane fade" id="v-pills-feature-toggles" role="tabpanel" aria-labelledby="v-pills-feature-toggles-tab">
                    <!-- Feature Toggles -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0">Feature Toggles</h5>
                        </div>
                        <div class="card-body">
                            <div class="form-row">
                                <div class="form-group col-md-4 m-0">
                                    <label class="d-block">{{ __('app.Dating_or_livestream') }}</label>
                                    <label class="switch ml-1">
                                        <input type="checkbox" name="is_dating" id="is_dating" {{ $appdata->is_dating == 1 ? 'checked' : '' }}>
                                        <span class="slider round"></span>
                                    </label>
                                </div>
                                <div class="form-group col-md-4 m-0">
                                    <label class="d-block">{{ __('app.socialMedia') }}</label>
                                    <label class="switch ml-1">
                                        <input type="checkbox" name="is_social_media" id="is_social_media" {{ $appdata->is_social_media == 1 ? 'checked' : '' }}>
                                        <span class="slider round"></span>
                                    </label>
                                </div>
                                <div class="form-group col-md-4 m-0">
                                    <label class="d-block">{{ __('app.includeFakeUserInMatching') }}</label>
                                    <label class="switch ml-1">
                                        <input type="checkbox" name="include_fake_user_in_matching" id="include_fake_user_in_matching" {{ $appdata->include_fake_user_in_matching == 1 ? 'checked' : '' }}>
                                        <span class="slider round"></span>
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Save Button -->
                    <div class="text-left">
                        <button class="btn btn-primary" type="submit">{{ __('app.Save') }}</button>
                    </div>
                </div>
                <div class="tab-pane fade" id="v-pills-commission" role="tabpanel" aria-labelledby="v-pills-commission-tab">
                    <!-- Commission Settings -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0">Commission Settings</h5>
                        </div>
                        <div class="card-body">
                            <div class="form-group">
                                <label class="m-0">{{ __('app.streamAndGiftCommission') }} (%)</label>
                                <p class="small text-muted m-0">
                                    The % of commission will be deducted from total collection while livestreaming by streamer, before crediting to their account.
                                </p>
                                <p class="small text-muted m-0">
                                    Eg. If commission is 10%, then 10% of total collection will be deducted from streamer's
                                    account and remaining 90% will be credited to their account.
                                </p>
                                <input type="number" class="form-control w-auto" name="stream_and_gift_commission" value="{{ $appdata->stream_and_gift_commission }}" required>
                            </div>
                        </div>
                    </div>
                    <!-- Save Button -->
                    <div class="text-left">
                        <button class="btn btn-primary" type="submit">{{ __('app.Save') }}</button>
                    </div>
                </div>
                <div class="tab-pane fade" id="v-pills-post-setting" role="tabpanel" aria-labelledby="v-pills-post-setting-tab">
                    <!-- Post Settings -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0">Post Settings</h5>
                        </div>
                        <div class="card-body">
                            <div class="form-row">
                                <div class="form-group col-md-3">
                                    <label>{{ __('app.postDescriptionLimit') }}</label>
                                    <input type="text" class="form-control" name="post_description_limit" value="{{ $appdata->post_description_limit }}">
                                </div>
                                <div class="form-group col-md-3">
                                    <label>{{ __('app.postUploadImageLimit') }}</label>
                                    <input type="text" class="form-control" name="post_upload_image_limit" value="{{ $appdata->post_upload_image_limit }}">
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Save Button -->
                    <div class="text-left">
                        <button class="btn btn-primary" type="submit">{{ __('app.Save') }}</button>
                    </div>
                </div>
                <div class="tab-pane fade" id="v-pills-admob" role="tabpanel" aria-labelledby="v-pills-admob-tab">
                    <!-- Admob Settings -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0">Admob Ad Units</h5>
                        </div>
                        <div class="card-body">
                            <div class="form-row">
                                <div class="form-group col-md-4">
                                    <label>Admob Banner Ad Unit : Android</label>
                                    <input type="text" class="form-control" name="admob_banner" value="{{ $appdata->admob_banner }}">
                                </div>
                                <div class="form-group col-md-4">
                                    <label>Admob Interstitial Ad Unit : Android</label>
                                    <input type="text" class="form-control" name="admob_int" value="{{ $appdata->admob_int }}">
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="form-group col-md-4">
                                    <label>Admob Banner Ad Unit : iOS</label>
                                    <input type="text" class="form-control" name="admob_banner_ios" value="{{ $appdata->admob_banner_ios }}">
                                </div>
                                <div class="form-group col-md-4">
                                    <label>Admob Interstitial Ad Unit : iOS</label>
                                    <input type="text" class="form-control" name="admob_int_ios" value="{{ $appdata->admob_int_ios }}">
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Save Button -->
                    <div class="text-left">
                        <button class="btn btn-primary" type="submit">{{ __('app.Save') }}</button>
                    </div>
                </div>
                <div class="tab-pane fade" id="v-pills-deep-link" role="tabpanel" aria-labelledby="v-pills-deep-link-tab">
                    <!-- Deep Linking Settings -->
                    <div class="card">
                        <div class="card-header">
                            <h5 class="m-0">{{ __('Deep Linking')}}</h5>
                        </div>
                        <div class="card-body px-4">
                            <form id="deepLinkingForm" method="post" enctype="multipart/form-data" class="form-border" autocomplete="off">
                                @csrf
                                <div class="row">
                                    <div class="col-md-4">
                                        <div class="mb-3">
                                            <label for="uri_scheme" class="form-label">{{ __('URI Scheme')}}
                                                <button type="button" class="btn btn-secondary text-dark p-0 tooltip-icon" data-bs-trigger="focus" data-bs-toggle="popover" data-bs-title="How to make a Scheme" data-bs-content="Use your app name in lowercase with no spaces or special characters (e.g., shortzz, cinereel, myapp2025).">
                                                    ?
                                                </button>
                                            </label>
                                            <input type="text" class="form-control" id="uri_scheme" name="uri_scheme" value="{{ $appdata->uri_scheme }}">
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="mb-3">
                                            <label for="play_store_download_link" class="form-label">{{ __('Play Store Download Link')}}</label>
                                            <input type="text" class="form-control" id="play_store_download_link" name="play_store_download_link" value="{{$appdata->play_store_download_link}}">
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="mb-3">
                                            <label for="app_store_download_link" class="form-label">{{ __('App Store Download Link')}}</label>
                                            <input type="text" class="form-control" id="app_store_download_link" name="app_store_download_link" value="{{$appdata->app_store_download_link}}">
                                        </div>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-primary">
                                    {{ __('Save')}}
                                </button>
                            </form>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="m-0">{{ __('Android')}}</h5>
                                </div>
                                <div class="card-body px-4">
                                    <form id="androidDeepLinkingForm" method="POST">
                                        <div class="row">
                                            <div class="mb-3">
                                                <label for="package_name" class="form-label">
                                                    {{ __('Package Name')}}
                                                    <a href="https://docs.retrytech.com/find_package_name_android" target="_blank" type="button" class="btn btn-secondary text-dark p-0 tooltip-icon">
                                                        ?
                                                    </a>
                                                </label>
                                                <input type="text" class="form-control" id="package_name" name="package_name" value="{{ $packageName }}">
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">{{ __('SHA 256 Keys') }}
                                                    <a href="https://docs.retrytech.com/how_to_get_sha1_key" target="_blank" type="button" class="btn btn-secondary text-dark p-0 tooltip-icon">
                                                        ?
                                                    </a>
                                                </label>
                                                <div id="shaContainer">
                                                    @if(!empty($sha256))
                                                    @foreach(explode(',', $sha256) as $sha)
                                                    <div class="input-group mb-2 sha-field">
                                                        <input type="text" class="form-control sha-input" name="sha_256[]" value="{{ trim($sha) }}">
                                                        <button type="button" class="btn btn-danger remove-sha">-</button>
                                                    </div>
                                                    @endforeach
                                                    @else
                                                    <div class="input-group mb-2 sha-field">
                                                        <input type="text" class="form-control sha-input" name="sha_256[]" placeholder="Enter SHA 256">
                                                        <button type="button" class="btn btn-danger remove-sha">-</button>
                                                    </div>
                                                    @endif
                                                </div>
                                                <button type="button" class="btn btn-sm btn-success mt-1" id="addSha">+ Add SHA</button>
                                            </div>
                                        </div>
                                        <hr>
                                        <button type="submit" class="btn btn-primary">
                                            {{ __('Save')}}
                                        </button>
                                        <button type="button" id="checkValidationOfAndroid" class="btn btn-success">
                                            {{ __('Check Validation') }}
                                        </button>

                                    </form>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="m-0">{{ __('iOS')}}</h5>
                                </div>
                                <div class="card-body px-4">
                                    <form id="iOSDeepLinkingForm" method="POST">
                                        <div class="row">
                                            <div class="mb-3">
                                                <label for="package_name_ios" class="form-label">{{ __('Bundle Id / Package Name')}}
                                                    <a href="https://docs.retrytech.com/find_bundle_id_ios" target="_blank" type="button" class="btn btn-secondary text-dark p-0 tooltip-icon">
                                                        ?
                                                    </a>
                                                </label>
                                                <input type="text" class="form-control" id="package_name_ios" name="package_name" value="{{ $iosPackageName }}" required>
                                            </div>
                                            <div class="mb-3">
                                                <label for="team_id" class="form-label">{{ __('Team Id')}}
                                                    <a href="https://docs.retrytech.com/find_team_id" target="_blank" type="button" class="btn btn-secondary text-dark p-0 tooltip-icon">
                                                        ?
                                                    </a>
                                                </label>
                                                <input type="text" class="form-control" id="team_id" name="team_id" value="{{ $iosTeamId }}" required>
                                            </div>
                                        </div>
                                        <hr>
                                        <button type="submit" class="btn btn-primary">
                                            {{ __('Save')}}
                                        </button>
                                        <button type="button" id="checkValidationOfApple" class="btn btn-success">
                                            {{ __('Check Validation') }}
                                        </button>
                                        <hr>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="tab-pane fade" id="v-pills-change-password" role="tabpanel" aria-labelledby="v-pills-change-password-tab">
                    <!-- Change Password Settings -->
                    <div class="card">
                        <div class="card-header">
                            <div class="page-title w-100">
                                <div class="d-flex align-items-center justify-content-between">
                                    <h4 class="mb-0 fw-semibold">{{ __('Change Password') }}</h4>
                                </div>
                            </div>
                        </div>
                        <div class="card-body px-4">
                            <form id="changePasswordForm" method="post" enctype="multipart/form-data" autocomplete="off">
                                <div class="row">
                                    <div class="col-lg-6 col-md-6 col-sm-12">
                                        <div class="form-group">
                                            <label for="appName" class="form-label">{{ __('Old Password') }}</label>
                                            <div class="position-relative">
                                                <input type="password" class="form-control" name="user_password" id="userPassword" required="">
                                                <div class="password-icon">
                                                    <i data-feather="eye"></i>
                                                    <i data-feather="eye-off"></i>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-sm-12 position-relative">
                                        <div class="form-group">
                                            <label for="appName" class="form-label">{{ __('New Password') }}</label>
                                            <div class="position-relative">
                                                <input type="password" class="form-control" name="new_password" id="newPassword" required="">
                                                <div class="password-icon">
                                                    <i data-feather="eye" class="eye1"></i>
                                                    <i data-feather="eye-off" class="eye-off1"></i>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-primary">
                                    {{ __('Change Password')}}
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>

</form>

<script>
    // Add new SHA field
    $("#addSha").on("click", function() {
        let field = `
            <div class="input-group mb-2 sha-field">
                <input type="text" class="form-control sha-input" name="sha_256[]" placeholder="Enter SHA 256">
                <button type="button" class="btn btn-danger remove-sha">-</button>
            </div>`;
        $("#shaContainer").append(field);
    });

    // Remove SHA field
    $(document).on("click", ".remove-sha", function() {
        $(this).closest(".sha-field").remove();
    });

    $(document).ready(function() {
        $("#checkValidationOfApple").on("click", function() {
            let baseUrl = "https://app-site-association.cdn-apple.com/a/v1/baseUrl";

            let appUrl = "{{ config('app.url') }}"; // Example: https://cinereel.retrytech.site/
            // Remove trailing slash
            let domainOnly = appUrl.replace(/^https?:\/\//, '').replace(/\/$/, '');

            let newUrl = baseUrl.replace("baseUrl", domainOnly);

            window.open(newUrl, "_blank");
        });

        $("#checkValidationOfAndroid").on("click", function() {
            let baseUrl = "https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=baseUrl&relation=delegate_permission/common.handle_all_urls";

            let appUrl = "{{ config('app.url') }}"; // Example: https://cinereel.retrytech.site/
            // Remove trailing slash
            let cleanUrl = appUrl.replace(/\/$/, '');

            let newUrl = baseUrl.replace("baseUrl", cleanUrl);

            window.open(newUrl, "_blank");
        });
    });
</script>
@endsection
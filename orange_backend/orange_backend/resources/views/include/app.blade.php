<!DOCTYPE html>
<html lang="en">


<head>
    <meta charset="UTF-8">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <title>{{ Session::get('app_name', 'Hearty') }} - Admin</title>
    {{-- Jquery --}}
    <!-- <script src="https://code.jquery.com/jquery-3.6.0.min.js" integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4=" crossorigin="anonymous"></script> -->
    <script src="{{ asset('asset/js/jquery-3.7.1.min.js') }}"></script>
    @yield('header')
    <link rel="icon" type="image/png" href="{{ asset('asset/img/hearty_heart_emblem.png') }}?v={{ time() }}">
    <link rel="shortcut icon" type="image/x-icon" href="{{ asset('asset/img/favicon.ico') }}?v={{ time() }}">
    <link rel="stylesheet" href="{{ asset('asset/css/app.min.css') }}">
    <link rel="stylesheet" href="{{ asset('asset/css/components.css') }}">
    <link rel="stylesheet" href="{{ asset('asset/css/custom.css') }}">
    <link rel="stylesheet" href="{{ asset('asset/bundles/codemirror/lib/codemirror.css') }}">
    <link rel="stylesheet" href="{{ asset('asset/bundles/codemirror/theme/duotone-dark.css') }} ">
    <link rel="stylesheet" href="{{ asset('asset/bundles/jquery-selectric/selectric.css') }}">
    <link rel="stylesheet" href="{{ asset('asset/css/bootstrap.min.css') }}">
    <link rel="stylesheet" href="{{ asset('asset/cdncss/iziToast.css') }}" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@9/swiper-bundle.min.css" />
    <link rel="stylesheet" href="{{ asset('asset/style/app.css') }}">
    <link rel="stylesheet" href="{{ asset('asset/css/style.css') }}">

</head>

<body>
    <div class="loader"></div>
    <div id="app">
        <div class="main-wrapper main-wrapper-1">
            <div class="navbar-bg"></div>
            <nav class="navbar navbar-expand-lg main-navbar sticky">
                <div class="form-inline mr-auto">
                    <ul class="navbar-nav mr-3">
                        <li>
                            <a href="#" data-toggle="sidebar" class="nav-link nav-link-lg collapse-btn">
                                <i data-feather="align-justify"></i>
                            </a>
                        </li>
                    </ul>
                </div>
                <ul class="navbar-nav navbar-right">
                    <li class="dropdown">
                        <a href="#" data-toggle="dropdown" class="nav-link dropdown-toggle nav-link-lg nav-link-user">
                            <span class="d-sm-none d-lg-inline-block btn btn-light"> {{ __('app.Logout') }} </span>
                        </a>
                        <div class="dropdown-menu dropdown-menu-right pullDown">
                            <a href="{{ route('logout') }}" class="dropdown-item has-icon text-danger">
                                <i class="fas fa-sign-out-alt"></i>
                                {{ __('app.Logout') }}
                            </a>
                        </div>
                    </li>
                </ul>
            </nav>
            <div class="main-sidebar sidebar-style-2">
                <aside id="sidebar-wrapper">
                    <div class="sidebar-brand">
                        <a href="{{ route('index') }}" class="d-flex align-items-center justify-content-center" style="height: 100%; text-decoration: none;">
                            <img alt="Hearty" src="{{ asset('asset/img/hearty_heart_emblem.png') }}?v={{ time() }}" class="header-logo" style="height: 38px; width: 38px; object-fit: contain; margin-right: 8px;" />
                            <span class="logo-name" style="font-weight: 700; font-size: 1.3rem; color: #16101D;"> {!! Session::get('app_name', 'Hearty') !!} </span>
                        </a>
                    </div>
                    <div class="sidebar-brand sidebar-brand-sm">
                        <a href="{{ route('index') }}" class="d-flex align-items-center justify-content-center" style="height: 100%;">
                            <img alt="Hearty" src="{{ asset('asset/img/hearty_heart_emblem.png') }}?v={{ time() }}" class="header-logo" style="height: 32px; width: 32px; object-fit: contain;" />
                        </a>
                    </div>
                    <ul class="sidebar-menu">
                        <li class="sideBarli indexSideA">
                            <a href="{{ route('index') }}" class="nav-link">
                                <i class="fas fa-tachometer-alt pt-1"></i>
                                <span> {{ __('app.Dashboard') }}</span>
                            </a>
                        </li>
                        <li class="sideBarli usersSideA">
                            <a href="{{ route('users') }}" class="nav-link">
                                <i class="fas fa-users"></i>
                                <span>{{ __('app.Users') }}</span>
                            </a>
                        </li>
                        <li class="sideBarli postSideA">
                            <a href="{{ route('posts') }}" class="nav-link">
                                <i class="fas fa-image"></i>
                                <span> {{ __('app.Posts') }} </span>
                            </a>
                        </li>
                        <li class="sideBarli storySideA">
                            <a href="{{ route('viewStories') }}" class="nav-link">
                                <i class="fas fa-compact-disc"></i>
                                <span> {{ __('stories') }} </span>
                            </a>
                        </li>
                        <hr>
                        <li class="sideBarli onboardingSideA">
                            <a href="{{ route('onboarding') }}" class="nav-link">
                                <i class="fas fa-handshake"></i>
                                <span>{{ __('app.Onboarding') }}</span>
                            </a>
                        </li>
                        <li class="sideBarli interestsSideA">
                            <a href="{{ route('interest') }}" class="nav-link">
                                <i class="fas fa-heart"></i>
                                <span>{{ __('app.Interests') }}</span>
                            </a>
                        </li>
                        <li class="sideBarli relationshipGoalSideA">
                            <a href="{{ route('relationshipGoals') }}" class="nav-link">
                                <i class="fas fa-bullseye"></i>
                                <span>{{ __('app.RelationshipGoals') }}</span>
                            </a>
                        </li>
                        <li class="sideBarli religionSideA">
                            <a href="{{ route('religions') }}" class="nav-link">
                                <i class="fas fa-cross"></i>
                                <span>{{ __('app.Religions') }}</span>
                            </a>
                        </li>
                        <li class="sideBarli languageSideA">
                            <a href="{{ route('languages') }}" class="nav-link">
                                <i class="fas fa-language"></i>
                                <span>{{ __('app.Languages') }}</span>
                            </a>
                        </li>
                        <hr>
                        <li class="sideBarli liveapplicationSideA">
                            <a href="{{ route('liveapplication') }}" class="nav-link">
                                <i class="fas fa-rss"></i>
                                <span>{{ __('app.Live_applications') }}</span>
                            </a>
                        </li>
                        <li class="sideBarli livehistorySideA">
                            <a href="{{ route('livehistory') }}" class="nav-link">
                            <i class="fas fa-life-ring"></i>
                                <span>{{ __('app.Live_History') }}</span>
                            </a>
                        </li>
                        <li class="sideBarli redeemrequestsSideA">
                            <a href="{{ route('redeemrequests') }}" class="nav-link"><i class="fas fa-university"></i><span>{{ __('app.Redeem_Requests') }}</span></a>
                        </li>
                        {{-- <li class="sideBarli packageSideA">
                            <a href="{{ route('package') }}" class="nav-link">
                        <i class="fas fa-box"></i>
                        <span>{{ __('app.Subscriptions') }}</span>
                        </a>
                        </li> --}}
                        <li class="sideBarli diamondpackSideA">
                            <a href="{{ route('diamondpacks') }}" class="nav-link">
                                <i class="fas fa-box"></i>
                                <span>{{ __('app.Diamond_packs') }}</span>
                            </a>
                        </li>
                        <li class="sideBarli giftSideA">
                            <a href="{{ route('gifts') }}" class="nav-link">
                                <i class="fas fa-gift"></i>
                                <span>{{ __('app.Gifts') }}</span>
                            </a>
                        </li>
                        <li class="sideBarli verificationRequestSideA">
                            <a href="{{ route('verificationrequests') }}" class="nav-link">
                                <i class="fas fa-check-circle"></i>
                                <span>{{ __('app.Verification') }}</span>
                            </a>
                        </li>
                        <li class="sideBarli reportSideA">
                            <a href="{{ route('report') }}" class="nav-link">
                                <i class="fas fa-question"></i>
                                <span>{{ __('app.Report') }}</span>
                            </a>
                        </li>
                        <li class="sideBarli notificationSideA">
                            <a href="{{ route('notifications') }}" class="nav-link">
                                <i class="fas fa-bell"></i>
                                <span>{{ __('app.Notifications') }}</span>
                            </a>
                        </li>

                        <hr>
                        <li class="menu-header">{{ __('Avatar Studio') }}</li>
                        <li class="sideBarli avatarsSideA">
                            <a href="{{ route('adminAvatars') }}" class="nav-link">
                                <i class="fas fa-user-astronaut"></i>
                                <span>{{ __('Avatars') }}</span>
                            </a>
                        </li>
                        <li class="sideBarli avatarStreamsSideA">
                            <a href="{{ route('adminStreams') }}" class="nav-link">
                                <i class="fas fa-broadcast-tower"></i>
                                <span>{{ __('Live Broadcasts') }}</span>
                            </a>
                        </li>
                        <hr>

                        <li class="sideBarli otherSideA">
                            <a href="{{ route('setting') }}">
                                <i class="fas fa-cog pt-1"></i>
                                <span>{{ __('app.Setting') }}</span>
                            </a>
                        </li>
                        <li class="menu-header">{{ __('Pages') }}</li>
                        <li class="sideBarli  privacySideA">
                            <a href="{{ route('viewPrivacy') }}" class="nav-link">
                                <i class="fas fa-info"></i>
                                <span>{{ __('Privacy Policy') }}</span>
                            </a>
                        </li>
                        <li class="sideBarli  termsSideA">
                            <a href="{{ route('viewTerms') }}" class="nav-link">
                                <i class="fas fa-info"></i>
                                <span>{{ __('Terms Of Use') }}</span>
                            </a>
                        </li>
                    </ul>
                </aside>
            </div>
            <!-- Main Content -->
            <div class="main-content">
                @yield('content')
                <form action="">
                    <input type="hidden" id="user_type" value="{{ session('user_type') }}">
                </form>
            </div>
        </div>
    </div>


    <input type="hidden" value="{{ env('APP_URL')}}" id="appUrl">

    <script src="{{ asset('asset/cdnjs/iziToast.min.js') }}"></script>
    <script src="{{ asset('asset/cdnjs/sweetalert.min.js') }}"></script>
    <script src="{{ asset('asset/script/env.js') }}"></script>
    <script src="{{ asset('asset/js/app.min.js ') }}"></script>
    <script src="{{ asset('asset/bundles/datatables/datatables.min.js ') }}"></script>
    <script src="{{ asset('asset/bundles/datatables/DataTables-1.10.16/js/dataTables.bootstrap4.min.js') }}"></script>
    <script src="{{ asset('asset/bundles/jquery-ui/jquery-ui.min.js ') }}"></script>
    <script src="{{ asset('asset/js/bootstrap.min.js') }}"></script>
    <script src="https://cdn.jsdelivr.net/npm/swiper@9/swiper-bundle.min.js"></script>
    <script src="{{ asset('asset/js/page/datatables.js') }}"></script>
    <script src="{{ asset('asset/js/scripts.js') }}"></script>
    <script src="{{ asset('asset/script/app.js') }}"></script>


    <!-- include summernote css/js -->
    <link href="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote.min.js"></script>
    <script>
        $('#app_name').keyup(function() {
            let appName = $(this).val();
            $('.logo-name').text(appName);
            document.title = appName;
        });
    </script>
</body>

</html>
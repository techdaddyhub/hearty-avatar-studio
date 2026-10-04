<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <title>{!! Session::get('app_name') !!}</title>
    <link rel='shortcut icon' type='image/x-icon' href="{{ asset('asset/img/favicon.png') }}" style="width: 2px !important;" />

    <link rel="stylesheet" href="{{ asset('asset/css/bootstrap.min.css') }}" type="text/css" />
    <link rel="stylesheet" href="{{ asset('asset/cdncss/iziToast.css') }}" type="text/css" />
    <link rel="stylesheet" href="{{ asset('asset/css/style.css') }}">
</head>

<body>
    <div class="login-page">
        <div class="container">
            <div class="row align-items-center justify-content-center mt-5">
                <div class="col-lg-5 col-md-5 col-sm-12">
                    <div class="login-box">
                        <div class="text-center mb-4">
                            <h3> {{ Session::get('app_name') }} </h3>
                        </div>
                        <div class="card login-card">
                            <div class="card-header">
                                <h4>{{ __('Log In')}}</h4>
                            </div>
                            <div class="card-body">
                                <form id="loginForm" action="javascript:void(0);">
                                    @csrf
                                    <div class="mb-3">
                                        <label for="user_name" class="form-label">{{ __('Username')}}</label>
                                        <input class="form-control" type="text" id="user_name" name="user_name" required="" placeholder="Enter your username" autocomplete>
                                    </div>
                                    <div class="mb-3">
                                        <label for="user_password" class="form-label">{{ __('Password')}}</label>
                                        <div class="position-relative">
                                            <input type="password" id="user_password" name="user_password" class="form-control" placeholder="Enter your password" autocomplete>
                                            <div class="password-icon">
                                                <i data-feather="eye" class="eye1"></i>
                                                <i data-feather="eye-off" class="eye-off1"></i>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="mb-0 text-center">
                                        <button class="btn btn-primary w-100 shadow-none" type="submit"> {{ __('Log In')}} </button>
                                    </div>
                                    <hr>
                                    <div class="">
                                        <div class="text-center">
                                            <a href="javascript:;" data-bs-toggle="modal" data-bs-target="#forgotPasswordModal"> {{ __('Forgot Password')}}? </a>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="forgotPasswordModal" tabindex="-1" aria-labelledby="addGenreModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="standard-modalLabel">{{ __('Forgot Password')}}</h4>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-hidden="true"></button>
                </div>
                <form id="forgotPasswordForm" method="POST">
                    @csrf
                    <div class="modal-body">
                        <div class="mb-3">
                            <label for="database_username" class="form-label">{{ __('Database Username')}}</label>
                            <input class="form-control" type="text" id="database_username" name="database_username" placeholder="Enter your database username" required="" autocomplete>
                        </div>
                        <div class="mb-3">
                            <label for="database_password" class="form-label">{{ __('Database Password')}}</label>
                            <div class="position-relative">
                                <input type="password" id="database_password" name="database_password" class="form-control" placeholder="Enter your database password" required="" autocomplete>
                                <div class="password-icon">
                                    <i data-feather="eye" class="eye4"></i>
                                    <i data-feather="eye-off" class="eye-off4"></i>
                                </div>
                            </div>
                        </div>
                        <hr>
                        <div class="mb-3">
                            <label for="new_password" class="form-label">{{ __('New Password') }}</label>
                            <div class="position-relative">
                                <input type="password" id="new_password" name="new_password" class="form-control" placeholder="Enter new your password" required="" autocomplete>
                                <div class="password-icon">
                                    <i data-feather="eye" class="eye2"></i>
                                    <i data-feather="eye-off" class="eye-off2"></i>
                                </div>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="confirm_password" class="form-label">{{ __('Confirm Password') }}</label>
                            <div class="position-relative">
                                <input type="password" id="confirm_password" name="confirm_password" class="form-control" placeholder="Enter confirm your password" required="" autocomplete>
                                <div class="password-icon">
                                    <i data-feather="eye" class="eye3"></i>
                                    <i data-feather="eye-off" class="eye-off3"></i>
                                </div>
                            </div>
                        </div>

                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">{{ __('Close')}}</button>
                        <button type="submit" class="btn btn-primary">
                            {{ __('Save')}}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- scripts -->
    <input type="hidden" value="{{ env('APP_URL')}}" id="appUrl">
    <script src="{{ asset('asset/cdnjs/iziToast.min.js') }}"></script>
    <script src="{{ asset('asset/js/bootstrap.min.js') }}"></script>
    <script src="{{ asset('asset/js/app.min.js') }}"></script>
    <script src="{{ asset('asset/js/custom.js') }}"></script>
    <script src="{{ asset('asset/js/scripts.js') }}"></script>
    <script src="{{ asset('asset/script/app.js') }}"></script>

    <script src="{{ asset('asset/script/env.js') }}"></script>
    <script src="{{ asset('asset/script/login.js') }}"></script>

</body>

</html>
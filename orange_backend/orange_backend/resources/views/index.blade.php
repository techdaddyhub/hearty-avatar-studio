@extends('include.app')
@section('header')
<script src="{{ asset('asset/script/index.js') }}"></script>
<script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>

@endsection

@section('content')
<style>
    .chartjs-render-monitor {
        -webkit-animation: chartjs-render-animation 0.001s;
        animation: chartjs-render-animation 0.001s;
    }

    *,
    ::after,
    ::before {
        -webkit-box-sizing: border-box;
        box-sizing: border-box;
    }

    .mainbg {
        background-image: linear-gradient(#FF6F43, #FE1B03) !important;
    }

    .card-icon2 {
        width: 50px;
        height: 50px;
        line-height: 50px;
        font-size: 22px;
        margin: 5px 0px;
        box-shadow: 2px 2px 10px 0 #97979794;
        border-radius: 10px;
        background: #ff5622;
        text-align: center;
    }

    .maincolor {
        color: white !important;
    }
</style>

<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-header border-bottom d-flex align-items-center">
                <h4 class="header-title me-auto">{{__('Analytics')}}</h4>
                <div class="d-flex align-content-around w-auto">
                    <select class="picker me-1 form-control px-1" name="month" id="months">
                        <option value="01">January</option>
                        <option value="02">February</option>
                        <option value="03">March</option>
                        <option value="04">April</option>
                        <option value="05">May</option>
                        <option value="06">June</option>
                        <option value="07">July</option>
                        <option value="08">August</option>
                        <option value="09">September</option>
                        <option value="10">October</option>
                        <option value="11">November</option>
                        <option value="12">December</option>
                    </select>
                    <select class="picker form-control px-1" name="year" id="years">
                        <option value="2024">2024</option>
                        <option value="2025">2025</option>
                        <option value="2026">2026</option>
                        <option value="2027">2027</option>
                    </select>
                </div>
            </div>
            <div class="card-body">

                <div dir="ltr">
                    <div id="chart-dashboard" class="apex-charts" data-colors="#B754F9,#0acf97"></div>
                </div>
            </div>
            <!-- end card body-->
        </div>
        <!-- end card -->
    </div>
</div>

<div class="row">
    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-xs-12">
        <div class="card">
            <div class="card-statistic-4">
                <div class="align-items-center justify-content-between">
                    <div class="row ">
                        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 pr-0 ">
                            <div class="card-icon2 mainbg">
                                <i class="fas fa-user maincolor"></i>
                            </div>
                            <div class="card-content">
                                <h5 class="font-15 mt-3">{{ __('All Users') }}</h5>
                                <h3 class="mb-3 ">{{ $totalUsers }}</h3>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-xs-12">
        <div class="card">
            <div class="card-statistic-4">
                <div class="align-items-center justify-content-between">
                    <div class="row ">
                        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 pr-0 ">
                            <div class="card-icon2 mainbg">
                                <i class="fas fa-user maincolor"></i>
                            </div>
                            <div class="card-content">
                                <h5 class="font-15 mt-3">{{ __('Total Posts') }}</h5>
                                <h3 class="mb-3 ">{{ $totalPosts }}</h3>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-xs-12">
        <div class="card">
            <div class="card-statistic-4">
                <div class="align-items-center justify-content-between">
                    <div class="row ">
                        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 pr-0 ">
                            <div class="card-icon2 mainbg">
                                <i class="fas fa-camera-retro maincolor"></i>
                            </div>
                            <div class="card-content">
                                <h5 class="font-15 mt-3">{{ __('Livestream Enabled Users') }}</h5>
                                <h3 class="mb-3 ">{{ $liveStreamUsers }}</h3>

                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-xs-12">
        <div class="card">
            <div class="card-statistic-4">
                <div class="align-items-center justify-content-between">
                    <div class="row ">
                        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 pr-0 ">
                            <div class="card-icon2 mainbg">
                                <i class="fas fa-ban maincolor"></i>
                            </div>
                            <div class="card-content">
                                <h5 class="font-15 mt-3">{{ __('Blocked Users') }}</h5>
                                <h3 class="mb-3 ">{{ $blockedUsers }}</h3>

                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-xs-12">
        <div class="card">
            <div class="card-statistic-4">
                <div class="align-items-center justify-content-between">
                    <div class="row ">
                        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 pr-0 ">
                            <div class="card-icon2 mainbg">
                                <i class="fas fa-camera-retro maincolor"></i>
                            </div>
                            <div class="card-content">
                                <h5 class="font-15 mt-3">{{ __('Live Applications') }}</h5>
                                <h3 class="mb-3 ">{{ $liveApplications }}</h3>

                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-xs-12">
        <div class="card">
            <div class="card-statistic-4">
                <div class="align-items-center justify-content-between">
                    <div class="row ">
                        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 pr-0 ">
                            <div class="card-icon2 mainbg">
                                <i class="fas fa-user maincolor"></i>
                            </div>
                            <div class="card-content">
                                <h5 class="font-15 mt-3">{{ __('Pending Redeems') }}</h5>
                                <h3 class="mb-3 ">{{ $pendingRedeems }}</h3>

                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-xs-12">
        <div class="card">
            <div class="card-statistic-4">
                <div class="align-items-center justify-content-between">
                    <div class="row ">
                        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 pr-0 ">
                            <div class="card-icon2 mainbg">
                                <i class="fas fa-camera-retro maincolor"></i>
                            </div>
                            <div class="card-content">
                                <h5 class="font-15 mt-3">{{ __('Completed Redeems') }}</h5>
                                <h3 class="mb-3 ">{{ $completedRedeems }}</h3>

                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-xs-12">
        <div class="card">
            <div class="card-statistic-4">
                <div class="align-items-center justify-content-between">
                    <div class="row ">
                        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 pr-0 ">
                            <div class="card-icon2 mainbg">
                                <i class="fas fa-ban maincolor"></i>
                            </div>
                            <div class="card-content">
                                <h5 class="font-15 mt-3">{{ __('Diamond Packs') }}</h5>
                                <h3 class="mb-3 ">{{ $diamondPacks }}</h3>

                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-xs-12">
        <div class="card">
            <div class="card-statistic-4">
                <div class="align-items-center justify-content-between">
                    <div class="row ">
                        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 pr-0 ">
                            <div class="card-icon2 mainbg">
                                <i class="fas fa-camera-retro maincolor"></i>
                            </div>
                            <div class="card-content">
                                <h5 class="font-15 mt-3">{{ __('Gifts') }}</h5>
                                <h3 class="mb-3 ">{{ $gifts }}</h3>

                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-xs-12">
        <div class="card">
            <div class="card-statistic-4">
                <div class="align-items-center justify-content-between">
                    <div class="row ">
                        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 pr-0 ">
                            <div class="card-icon2 mainbg">
                                <i class="fas fa-user maincolor"></i>
                            </div>
                            <div class="card-content">
                                <h5 class="font-15 mt-3">{{ __('Verification Requests') }}</h5>
                                <h3 class="mb-3 ">{{ $verifyRequests }}</h3>

                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-xs-12">
        <div class="card">
            <div class="card-statistic-4">
                <div class="align-items-center justify-content-between">
                    <div class="row ">
                        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 pr-0 ">
                            <div class="card-icon2 mainbg">
                                <i class="fas fa-ban maincolor"></i>
                            </div>
                            <div class="card-content">
                                <h5 class="font-15 mt-3">{{ __('Interests') }}</h5>
                                <h3 class="mb-3 ">{{ $interests }}</h3>

                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-xl-3 col-lg-3 col-md-3 col-sm-12 col-xs-12">
        <div class="card">
            <div class="card-statistic-4">
                <div class="align-items-center justify-content-between">
                    <div class="row ">
                        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 pr-0 ">
                            <div class="card-icon2 mainbg">
                                <i class="fas fa-camera-retro maincolor"></i>
                            </div>
                            <div class="card-content">
                                <h5 class="font-15 mt-3">{{ __('Reports') }}</h5>
                                <h3 class="mb-3 ">{{ $reports }}</h3>

                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

</div>

@endsection
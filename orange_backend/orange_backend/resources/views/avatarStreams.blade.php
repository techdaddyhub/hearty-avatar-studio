@extends('include.app')

@section('content')
<section class="section">
    <div class="section-header">
        <h1><i class="fas fa-broadcast-tower mr-2"></i> {{ __('Live Stream & RTMP Gateway Management') }}</h1>
        <div class="section-header-breadcrumb">
            <div class="breadcrumb-item active"><a href="{{ route('index') }}">{{ __('app.Dashboard') }}</a></div>
            <div class="breadcrumb-item">{{ __('Live Streams') }}</div>
        </div>
    </div>

    <!-- Quick Stats -->
    <div class="row">
        <div class="col-lg-4 col-md-6 col-sm-6 col-12">
            <div class="card card-statistic-1">
                <div class="card-icon bg-danger">
                    <i class="fas fa-satellite-dish"></i>
                </div>
                <div class="card-wrap">
                    <div class="card-header">
                        <h4>{{ __('Active Live Broadcasts') }}</h4>
                    </div>
                    <div class="card-body">
                        {{ $activeStreamsCount ?? 0 }}
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-4 col-md-6 col-sm-6 col-12">
            <div class="card card-statistic-1">
                <div class="card-icon bg-primary">
                    <i class="fas fa-video"></i>
                </div>
                <div class="card-wrap">
                    <div class="card-header">
                        <h4>{{ __('Total Broadcast Sessions') }}</h4>
                    </div>
                    <div class="card-body">
                        {{ $totalStreamsCount ?? 0 }}
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-4 col-md-6 col-sm-6 col-12">
            <div class="card card-statistic-1">
                <div class="card-icon bg-success">
                    <i class="fas fa-share-alt"></i>
                </div>
                <div class="card-wrap">
                    <div class="card-header">
                        <h4>{{ __('Active Multi-Platform Relays') }}</h4>
                    </div>
                    <div class="card-body">
                        {{ $destinationsCount ?? 0 }}
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Live Stream Sessions Table -->
    <div class="card">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h4>{{ __('Live Stream Sessions & Social Destinations') }}</h4>
            <button class="btn btn-outline-primary btn-sm" onclick="$('#streamTable').DataTable().ajax.reload();">
                <i class="fas fa-sync-alt mr-1"></i> {{ __('Refresh Live Status') }}
            </button>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-striped table-hover w-100" id="streamTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>{{ __('Streamer') }}</th>
                            <th>{{ __('Title') }}</th>
                            <th>{{ __('Status') }}</th>
                            <th>{{ __('Resolution') }}</th>
                            <th>{{ __('FPS') }}</th>
                            <th>{{ __('Bitrate') }}</th>
                            <th>{{ __('Relay Platforms') }}</th>
                            <th>{{ __('Started At') }}</th>
                            <th style="width: 120px;">{{ __('Action') }}</th>
                        </tr>
                    </thead>
                </table>
            </div>
        </div>
    </div>
</section>

<script>
$(document).ready(function() {
    $('#streamTable').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: "{{ route('adminFetchStreams') }}",
            type: "POST",
            data: {
                _token: "{{ csrf_token() }}"
            }
        },
        order: [[0, "desc"]]
    });
});

function endStreamAdmin(streamId) {
    swal({
        title: 'Terminate Stream?',
        text: 'This will forcefully shut down the RTMP broadcast ingest and disconnect social relays!',
        icon: 'warning',
        buttons: true,
        dangerMode: true,
    }).then((confirm) => {
        if (confirm) {
            $.post("{{ route('adminEndStream') }}", {
                _token: "{{ csrf_token() }}",
                stream_id: streamId
            }, function(res) {
                if (res.status) {
                    $('#streamTable').DataTable().ajax.reload(null, false);
                    iziToast.success({ title: 'Stream Ended', message: res.message, position: 'topRight' });
                }
            });
        }
    });
}
</script>
@endsection

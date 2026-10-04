@extends('include.app')

@section('content')
<section class="section">
    <div class="section-header">
        <h1><i class="fas fa-user-astronaut mr-2"></i> {{ __('Avatar Studio Management') }}</h1>
        <div class="section-header-breadcrumb">
            <div class="breadcrumb-item active"><a href="{{ route('index') }}">{{ __('app.Dashboard') }}</a></div>
            <div class="breadcrumb-item">{{ __('Avatars') }}</div>
        </div>
    </div>

    <!-- Quick Metric Cards -->
    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-6 col-12">
            <div class="card card-statistic-1">
                <div class="card-icon bg-primary">
                    <i class="fas fa-user-astronaut"></i>
                </div>
                <div class="card-wrap">
                    <div class="card-header">
                        <h4>{{ __('Total Avatars') }}</h4>
                    </div>
                    <div class="card-body">
                        {{ $totalAvatars ?? 0 }}
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 col-sm-6 col-12">
            <div class="card card-statistic-1">
                <div class="card-icon bg-info">
                    <i class="fas fa-cube"></i>
                </div>
                <div class="card-wrap">
                    <div class="card-header">
                        <h4>{{ __('3D VRM Models') }}</h4>
                    </div>
                    <div class="card-body">
                        {{ $total3D ?? 0 }}
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 col-sm-6 col-12">
            <div class="card card-statistic-1">
                <div class="card-icon bg-success">
                    <i class="fas fa-paint-brush"></i>
                </div>
                <div class="card-wrap">
                    <div class="card-header">
                        <h4>{{ __('2D Sprites') }}</h4>
                    </div>
                    <div class="card-body">
                        {{ $total2D ?? 0 }}
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 col-sm-6 col-12">
            <div class="card card-statistic-1">
                <div class="card-icon bg-warning">
                    <i class="fas fa-brain"></i>
                </div>
                <div class="card-wrap">
                    <div class="card-header">
                        <h4>{{ __('AI Neural Photos') }}</h4>
                    </div>
                    <div class="card-body">
                        {{ $totalAI ?? 0 }}
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Table Card -->
    <div class="card">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h4>{{ __('All Avatars & System Presets') }}</h4>
            <button class="btn btn-primary" data-toggle="modal" data-target="#addAvatarModal">
                <i class="fas fa-plus mr-1"></i> {{ __('Add System Avatar') }}
            </button>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-striped table-hover w-100" id="avatarTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>{{ __('Preview') }}</th>
                            <th>{{ __('Name / Owner') }}</th>
                            <th>{{ __('Engine Type') }}</th>
                            <th>{{ __('Gender') }}</th>
                            <th>{{ __('Style') }}</th>
                            <th>{{ __('Default') }}</th>
                            <th>{{ __('Status') }}</th>
                            <th>{{ __('Created') }}</th>
                            <th style="width: 120px;">{{ __('Action') }}</th>
                        </tr>
                    </thead>
                </table>
            </div>
        </div>
    </div>
</section>

<!-- Add Avatar Modal -->
<div class="modal fade" id="addAvatarModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-plus-circle mr-1"></i> {{ __('Add System Preset Avatar') }}</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form id="addAvatarForm" enctype="multipart/form-data">
                @csrf
                <div class="modal-body">
                    <div class="form-group">
                        <label>{{ __('Avatar Name') }} <span class="text-danger">*</span></label>
                        <input type="text" name="name" class="form-control" required placeholder="e.g. Cyber Punk Girl">
                    </div>
                    <div class="form-group">
                        <label>{{ __('Avatar Engine Type') }} <span class="text-danger">*</span></label>
                        <select name="type" class="form-control" required>
                            <option value="3d">3D Humanoid Model (VRM / GLB)</option>
                            <option value="2d">2D Kinematic Sprite (Low CPU)</option>
                            <option value="ai_photo">AI Photorealistic Neural Puppeteer</option>
                            <option value="preset">System Animated Preset</option>
                        </select>
                    </div>
                    <div class="row">
                        <div class="col-md-6 form-group">
                            <label>{{ __('Gender') }}</label>
                            <select name="gender" class="form-control">
                                <option value="female">Female</option>
                                <option value="male">Male</option>
                                <option value="neutral">Neutral</option>
                            </select>
                        </div>
                        <div class="col-md-6 form-group">
                            <label>{{ __('Style') }}</label>
                            <select name="style" class="form-control">
                                <option value="anime">Anime / VTuber</option>
                                <option value="realistic">Photorealistic</option>
                                <option value="cartoon">Stylized Cartoon</option>
                                <option value="pixel">Retro Pixel Art</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>{{ __('Thumbnail Image') }}</label>
                        <input type="file" name="thumbnail" class="form-control" accept="image/png, image/jpeg, image/webp">
                    </div>
                    <div class="form-check">
                        <input type="checkbox" name="is_default" value="1" class="form-check-input" id="isDefaultCheck">
                        <label class="form-check-label" for="isDefaultCheck">{{ __('Set as default avatar for new users') }}</label>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">{{ __('Cancel') }}</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-save mr-1"></i> {{ __('Save Avatar') }}</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    var table = $('#avatarTable').DataTable({
        processing: true,
        serverSide: true,
        ajax: {
            url: "{{ route('adminFetchAvatars') }}",
            type: "POST",
            data: {
                _token: "{{ csrf_token() }}"
            }
        },
        order: [[0, "desc"]]
    });

    $('#addAvatarForm').on('submit', function(e) {
        e.preventDefault();
        var formData = new FormData(this);

        $.ajax({
            url: "{{ route('adminAddAvatar') }}",
            type: "POST",
            data: formData,
            contentType: false,
            processData: false,
            success: function(response) {
                if (response.status) {
                    $('#addAvatarModal').modal('hide');
                    $('#addAvatarForm')[0].reset();
                    table.ajax.reload();
                    iziToast.success({
                        title: 'Success',
                        message: response.message,
                        position: 'topRight'
                    });
                } else {
                    iziToast.error({
                        title: 'Error',
                        message: response.message,
                        position: 'topRight'
                    });
                }
            }
        });
    });
});

function toggleAvatarStatus(avatarId) {
    $.post("{{ route('adminToggleAvatar') }}", {
        _token: "{{ csrf_token() }}",
        avatar_id: avatarId
    }, function(res) {
        if (res.status) {
            $('#avatarTable').DataTable().ajax.reload(null, false);
            iziToast.success({ title: 'Updated', message: res.message, position: 'topRight' });
        }
    });
}

function deleteAvatar(avatarId) {
    swal({
        title: 'Are you sure?',
        text: 'This will permanently remove the avatar and its configuration!',
        icon: 'warning',
        buttons: true,
        dangerMode: true,
    }).then((willDelete) => {
        if (willDelete) {
            $.post("{{ route('adminDeleteAvatar') }}", {
                _token: "{{ csrf_token() }}",
                avatar_id: avatarId
            }, function(res) {
                if (res.status) {
                    $('#avatarTable').DataTable().ajax.reload(null, false);
                    iziToast.success({ title: 'Deleted', message: res.message, position: 'topRight' });
                }
            });
        }
    });
}
</script>
@endsection

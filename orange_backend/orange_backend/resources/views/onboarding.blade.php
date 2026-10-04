@extends('include.app')

@section('header')
<script src="{{ asset('asset/script/onboarding.js') }}"></script>
@endsection

@section('content')
<div class="card">
    <div class="card-header">
        <h4>{{ __('app.Onboarding') }}</h4>
        <a class="btn btn-primary onboardingModalBtn ml-auto" href="" data-bs-toggle="modal" data-bs-target="#addOnboardingModal">{{ __('app.AddOnboarding') }}
        </a>
    </div>
    <div class="card-body">
        <table class="table table-striped w-100" id="onboardingTable">
            <thead>
                <tr>
                    <th style="width: 25px;text-align: center;">{{ __('app.Sortable') }}</th>
                    <th>{{ __('app.Position') }}</th>
                    <th class="w-100">{{ __('app.Onboarding') }}</th>
                    <th class="text-end" width="200px">{{ __('app.Action') }}</th>
                </tr>
            </thead>
        </table>
    </div>
</div>

<div class="modal fade" id="addOnboardingModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <div class=" ">
                    <h5>{{ __('app.AddOnboardingScreen') }} </h5>
                </div>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form action="" method="post" enctype="multipart/form-data" id="addOnboarding" autocomplete="off">
                    @csrf
                    <div class="form-group">
                        <label>{{ __('app.Image') }} </label>
                        <input type="file" id="image" name="image" class="form-control" required accept="image/*">
                    </div>
                    <div class="form-group">
                        <label>{{ __('app.Title') }} </label>
                        <input type="text" id="title" name="title" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>{{ __('app.Description') }} </label>
                        <textarea name="description" id="description" class="form-control" rows="3" required maxlength="70"></textarea>
                    </div>
                    <div class="form-group text-right m-0">
                        <input class="btn btn-primary mr-1" type="submit" value="{{ __('app.Save') }}">
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="editOnboardingModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
    aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">{{ __('app.EditOnboardingScreen') }}</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form action="" method="post" enctype="multipart/form-data" id="editOnboardingForm" autocomplete="off">
                    @csrf
                    <input type="hidden" class="form-control" id="editOnboardingId" name="id">
                    <div class="form-group">
                        <label>{{ __('app.Image') }} </label>
                        <input type="file" id="edit_image" name="image" class="form-control" accept="image/*">
                    </div>
                    <div class="form-group">
                        <label>{{ __('app.Title') }} </label>
                        <input type="text" id="edit_title" name="title" class="form-control">
                    </div>
                    <div class="form-group">
                        <label>{{ __('app.Description') }} </label>
                        <textarea name="description" id="edit_description" class="form-control" rows="3" maxlength="70"></textarea>
                    </div>

                    <div class="form-group text-right m-0">
                        <input type="submit" value="{{ __('app.Save') }}" class=" btn btn-primary" id="editcat2">
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
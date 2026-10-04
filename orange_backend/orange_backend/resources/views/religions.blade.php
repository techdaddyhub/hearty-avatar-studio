@extends('include.app')
@section('header')
<script src="{{ asset('asset/script/religion.js') }}"></script>
@endsection
@section('content')
<div class="card">
    <div class="card-header">
        <h4>{{ __('app.Religions') }}</h4>
        <a class="btn btn-primary addModalBtn ml-auto" data-bs-toggle="modal" data-bs-target="#addReligionModal"
            href="">{{ __('app.AddReligion') }}
        </a>
    </div>
    <div class="card-body">
        <table class="table table-striped w-100" id="religionTable">
            <thead>
                <tr>
                    <th class="w-100"> {{ __('app.Title') }}</th>
                    <th width="200px" style="text-align: right;"> {{ __('app.Action') }}</th>
                </tr>
            </thead>
        </table>
    </div>
</div>

<div class="modal fade" id="addReligionModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5>{{ __('app.AddReligion') }}</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form action="" method="post" enctype="multipart/form-data" id="addReligionForm" autocomplete="off">
                    @csrf
                    <div class="form-group">
                        <label> {{ __('app.Title') }}</label>
                        <input type="text" name="title" class="form-control" required>
                    </div>
                    <div class="form-group text-right m-0">
                        <input class="btn btn-primary mr-1" type="submit" value="{{ __('app.Save') }}">
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="editReligionModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel"> {{ __('app.EditReligion') }}</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form action="" method="post" enctype="multipart/form-data" id="editReligionForm" autocomplete="off">
                    @csrf
                    <input type="hidden" id="editReligionId">
                    <div class="form-group">
                        <label> {{ __('app.Title') }}</label>
                        <input type="text" name="title" id="edit_title" class="form-control" required>
                    </div>
                    <div class="form-group text-right m-0">
                        <input class="btn btn-primary mr-1" type="submit" value="{{ __('app.Save') }}">
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
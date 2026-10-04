@extends('include.app')
@section('header')
<script src="{{ asset('asset/script/relationshipGoal.js') }}"></script>
@endsection
@section('content')
<div class="card">
    <div class="card-header">
        <h4>{{ __('app.RelationshipGoals') }}</h4>
        <a class="btn btn-primary addModalBtn ml-auto" data-bs-toggle="modal" data-bs-target="#addRelationshipGoalModal"
            href="">{{ __('app.AddRelationshipGoal') }}
        </a>
    </div>
    <div class="card-body">
        <table class="table table-striped w-100" id="relationshipGoalTable">
            <thead>
                <tr>
                    <th class="w-100"> {{ __('app.Info') }}</th>
                    <th width="200px" style="text-align: right;"> {{ __('app.Action') }}</th>
                </tr>
            </thead>
        </table>
    </div>
</div>

<div class="modal fade" id="addRelationshipGoalModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5>{{ __('app.AddRelationshipGoal') }}</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form action="" method="post" enctype="multipart/form-data" id="addRelationshipGoalForm" autocomplete="off">
                    @csrf
                    <div class="form-group">
                        <label> {{ __('app.Title') }}</label>
                        <input type="text" name="title" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label> {{ __('app.Description') }}</label>
                        <textarea name="description" id="description" class="form-control" required></textarea>
                    </div>
                    <div class="form-group text-right m-0">
                        <input class="btn btn-primary mr-1" type="submit" value="{{ __('app.Save') }}">
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="editRelationshipGoalModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel"> {{ __('app.EditRelationshipGoal') }}</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form action="" method="post" enctype="multipart/form-data" id="editRelationshipGoalForm" autocomplete="off">
                    @csrf
                    <input type="hidden" id="editRelationshipGoalId">
                    <div class="form-group">
                        <label> {{ __('app.Title') }}</label>
                        <input type="text" name="title" id="edit_title" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label> {{ __('app.Description') }}</label>
                        <textarea name="description" id="edit_description" class="form-control" required></textarea>
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
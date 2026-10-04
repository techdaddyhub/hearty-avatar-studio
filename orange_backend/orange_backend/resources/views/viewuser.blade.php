@extends('include.app')

@section('header')
<script src="{{ asset('asset/script/viewuser.js') }}"></script>
<link rel="stylesheet" href="{{ asset('asset/style/addFakeUser.css') }}">
@endsection

@section('content')
<div class="card">
    <div class="card-header" id="reloadContent">
        <h4>
            @php use Carbon\Carbon; @endphp

            {{ $data['fullname'] }}
            @if (!empty($data['dob']))
            ({{ Carbon::parse($data['dob'])->age }})
            @endif

            @if ($data['can_go_live'] == 2)
            <span class="ml-2 badge bg-success text-white fw-normal px-3">Can Go Live</span>
            @endif

            @if($data['is_fake'] == 1)
            <span class="ml-2 badge bg-black text-white fw-normal px-3">Fake User</span>
            @else
            <span class="ml-2 badge bg-success text-white fw-normal px-3">Real User</span>
            @endif

            @if($data['gender'] == 1)
            <span class='ml-2 badge bg-primary text-white fw-normal px-3'>{{ __('app.Male') }}</span>
            @else
            <span class='ml-2 badge bg-primary text-white fw-normal px-3'>{{ __('app.Female') }}</span>
            @endif
        </h4>

        <div class="d-flex ml-auto">

            @if($data['is_block'] == 1)
            <h2 class='btn btn-success unblock' rel='{{ $data->id }}'>{{ __('app.Unblock') }}</h2>
            @else
            <h2 class='btn btn-danger block' rel='{{ $data->id }}'>{{ __('app.Block') }}</h2>
            @endif

            @if($data['can_go_live'] == 2)
            <h2 class='btn btn-danger ml-2 restrict-live' rel='{{ $data->id }}'>{{ __('app.Restrict_live') }}</h2>
            @else
            <h2 class='btn btn-success ml-2 allow-live' rel='{{ $data->id }}'>{{ __('app.Allow_live') }}</h2>
            @endif



            <h2 class='btn btn-danger ml-2 deleteUser' rel='{{ $data->id }}'>
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-trash-2 me-2">
                    <polyline points="3 6 5 6 21 6"></polyline>
                    <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                    <line x1="10" y1="11" x2="10" y2="17"></line>
                    <line x1="14" y1="11" x2="14" y2="17"></line>
                </svg>
                {{ __('app.deleteUser') }}
            </h2>
        </div>
    </div>

    <div class="card-body">

        <div class="form-row">
            @foreach ($data['images'] as $image)
            {{-- <img class="rounded m-1 " src="{{ env('image') }}{{ $image->image }}" width="130" height="130"> --}}
            <div class="borderwrap2 " data-href="">
                <div class="filenameupload2">
                    <img class="rounded " src="{{ env('image') }}{{ $image->image }}" width="130" height="130">
                    <div data-imgid="{{ $image->id }}" class="middle btnRemove">
                        <i class="material-icons remove_img2">cancel</i>
                    </div>
                </div>
            </div>
            @endforeach
        </div>

        <div class="">
            <button id="btnAddImage" class="btn btn-primary">Add Image</button>
        </div>



    </div>
</div>

<div class="row">
    <div class="col-md-4">
        <div class="card">
            <div class="card-body">
                <form method="post" class="" action="" id="userUpdate" enctype="multipart/form-data">
                    @csrf
                    <input class=" form-control" readonly name="id" value="{{ $data['id'] }}" type="text" id="userId" hidden>

                    <div class="bg-body-secondary border d-flex align-items-center justify-content-around rounded-pill overflow-hidden">
                        <div class="form-group mb-0 py-2  w-100 text-center border-right">
                            <label class="m-0">{{ __('app.Following') }} : </label> {{ $data['following'] }}
                        </div>
                        <div class="form-group mb-0 py-2 w-100 text-center">
                            <label class="m-0">{{ __('app.Followers') }} : </label> {{ $data['followers'] }}
                        </div>
                    </div>

                    <hr>
                    
                    @if ($data['is_fake'] == 0)
                    <div class="form-group mb-2">
                        <label class="m-0">{{ __('app.Identity') }} : </label> {{ $data['identity'] }}
                    </div>
                    @else
                    <div class="form-group mb-2">
                        <label class="m-0">{{ __('app.Identity') }} : </label> {{ $data['identity'] }}
                    </div>
                    <div class="form-group mb-2">
                        <label class="m-0">{{ __('app.Password') }} : </label> {{ $data['password'] }}
                    </div>
                    @endif

                    <div class="form-group mb-2">
                        <label class="m-0">{{ __('app.Dob') }} : </label> {{ $data['dob'] }}
                    </div>
                    <div class="form-group mb-2">
                        <label class="m-0">{{ __('app.Live') }} : </label> {{ $data['city'] }}, {{ $data['state'] }}, {{ $data['country'] }}
                    </div>
                    <div class="form-group mb-2">
                        <label class="m-0">{{ __('app.Interests') }} : </label>
                        @foreach($interestTitles as $interestTitle)
                        {{ $interestTitle }},
                        @endforeach
                    </div>
                    <div class="form-group mb-2">
                        <label class="m-0">{{ __('app.GenderPreferred') }} : </label>
                        @if ($data['gender_preferred'] == 1)
                        {{ __('app.Male') }}
                        @elseif ($data['gender_preferred'] == 2)
                        {{ __('app.Female') }}
                        @elseif ($data['gender_preferred'] == 3)
                        {{ __('app.Both') }}
                        @else
                        -
                        @endif
                    </div>
                    <div class="form-group mb-2">
                        <label class="m-0">{{ __('app.RelationshipGoal') }} : </label> {{ $matchedRelationshipGoal->title }}
                    </div>

                    <div class="form-group mb-2">
                        <label class="m-0">{{ __('app.ReligionKey') }} : </label> {{ $data['religion_key'] }}
                    </div>
                    <div class="form-group mb-2">
                        <label class="m-0">{{ __('app.LanguageKeys') }} : </label> {{ $data['language_keys'] }}
                    </div>
                  
                    <hr>
                     <div class="form-row">
                        <div class="form-group col-md-12">
                            <label>{{ __('app.Youtube') }}</label>
                            <input name="youtube" class="form-control" value="{{ $data['youtube'] }}">
                        </div>
                        <div class="form-group col-md-12">
                            <label>{{ __('app.Instagram') }}</label>
                            <input name="instagram" class="form-control" value="{{ $data['instagram'] }}">
                        </div>
                        <div class="form-group col-md-12">
                            <label>{{ __('app.Facebook') }}</label>
                            <input name="facebook" class="form-control" value="{{ $data['facebook'] }}">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group col-md-12">
                            <label>{{ __('app.Bio') }} </label>
                            <textarea name="bio" class="form-control">{{ $data['bio'] }}</textarea>

                        </div>
                        <div class="form-group col-md-12">
                            <label for="product_description">{{ __('app.About') }} </label>
                            <textarea name="about" class="form-control">{{ $data['about'] }}</textarea>

                        </div>
                    </div>
                    <div class="form-row">
                        <button type="submit" class="btn btn-primary">{{ __('app.Submit') }}</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <div class="col-md-8">
        <div class="mb-3 card-tab">
            <ul class="nav nav-tabs" id="myTab" role="tablist">
                <li class="nav-item " role="presentation">
                    <button class="nav-link active" id="allUserPostsTab" data-bs-toggle="tab" data-bs-target="#allUserPostsTab-pane" type="button" role="tab" aria-controls="allUserPostsTab-panel" aria-selected="true"> {{ __('app.posts')}} </button>
                </li>
                <li class="nav-item " role="presentation">
                    <button class="nav-link" id="userStoryTab" data-bs-toggle="tab" data-bs-target="#userStoryTab-pane" type="button" role="tab" aria-controls="userStoryTab-panel" aria-selected="true"> {{ __('app.stories')}} </button>
                </li>
            </ul>
        </div>
        <div class="tab-content" id="myTabContent">
            <div class="tab-pane show active" id="allUserPostsTab-pane" role="tabpanel" tabindex="0">
                <div class="card">
                    <div class="card-header">
                        <div class="page-title w-100">
                            <div class="d-flex align-items-center justify-content-between">
                                <h4 class="mb-0 fw-normal d-flex align-items-center"> {{ __('app.userPosts') }} </h4>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <input type="hidden" name="" id="userId" value="{{$data->id}}">
                        <table class="table table-striped w-100" id="userPostTable">
                            <thead>
                                <tr>
                                    <th style="width: 150px"> {{ __('Content') }} </th>
                                    <th> {{ __('Comments') }} </th>
                                    <th> {{ __('Likes') }} </th>
                                    <th> {{ __('Created At') }} </th>
                                    <th style="text-align: right; width: 200px;"> {{ __('Action') }} </th>
                                </tr>
                            </thead>
                        </table>
                    </div>
                </div>
            </div>
            <div class="tab-pane" id="userStoryTab-pane" role="tabpanel" tabindex="0">
                <div class="card">
                    <div class="card-header">
                        <div class="page-title w-100">
                            <div class="d-flex align-items-center justify-content-between">
                                <h4 class="mb-0 fw-normal d-flex align-items-center"> {{ __('app.userStories') }} </h4>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <table class="table table-striped w-100" id="userStoryTable">
                            <thead>
                                <tr>
                                    <th width="100px"> {{ __('app.content')}} </th>
                                    <th width="100px"> {{ __('app.time')}} </th>
                                    <th width="250px" style="text-align: right"> {{ __('app.action')}} </th>
                                </tr>
                            </thead>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>


<!-- View Story Modal -->
<div class="modal fade" id="viewStoryModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5 fw-normal" id="exampleModalLabel">{{ __('app.viewStory') }}</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="form-group position-relative m-0">
                    <label> {{ __('app.story') }}</label>
                    <img src="" alt="" srcset="" id="story_content" class="img-fluid story_content_view">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">{{ __('close') }}</button>
            </div>
        </div>
    </div>
</div>

<!-- View Story Modal -->
<div class="modal fade" id="viewStoryVideoModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5 fw-normal" id="exampleModalLabel">{{ __('app.viewStoryVideo') }}</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="form-group position-relative m-0">
                    <label class="form-label"> {{ __('story') }}</label>
                    <video controls id="story_content_video" class="img-fluid story_content_view">

                    </video>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">{{ __('app.close') }}</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="addImageModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">

                <h5>{{ __('app.Add_Image') }}</h5>

                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">

                <form action="" method="post" enctype="multipart/form-data" class="add_category" id="addForm" autocomplete="off">
                    @csrf
                    <input class=" form-control" readonly name="id" value="{{ $data['id'] }}" type="text" id="userId" hidden>

                    <div class="form-group">
                        <div class="mb-3">
                            <label for="gift_image" class="form-label">{{ __('Image') }}</label>
                            <input id="gift_image" class="form-control" type="file" accept="image/png, image/gif, image/jpeg" name="image" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <input class="btn btn-primary mr-1" type="submit" value=" {{ __('app.Submit') }}">
                    </div>

                </form>
            </div>

        </div>
    </div>
</div>

<!-- View Post Modal -->
<div class="modal fade" id="viewPostModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5 fw-normal" id="exampleModalLabel">View Post</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label> {{ __('Post Description') }}</label>
                    <p id="postDesc"> </p>
                </div>
                <hr>
                <div class="form-group position-relative">
                    <label> {{ __('Post') }}</label>
                    <div class="swiper-container mySwiper">
                        <div id="post_contents">
                        </div>
                    </div>
                    <div class="swiper-button swiper-button-prev"></div>
                    <div class="swiper-button swiper-button-next"></div>
                    <div class="swiper-pagination"></div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<!-- View Post Desc Modal -->
<div class="modal fade" id="viewPostDescModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5 fw-normal" id="exampleModalLabel">View Post</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="form-group m-0">
                    <label> {{ __('Post Description') }}</label>
                    <p class="m-0" id="postDesc1"> </p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
@endsection
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Users extends Model
{
    use HasFactory;

    public $table = "users";
    public $timestamps = false;

    protected $casts = [
        'id' => 'integer',
        'is_block' => 'integer',
        'gender' => 'integer',
        'login_type' => 'integer',
        'device_type' => 'integer',
        'wallet' => 'integer',
        'total_collected' => 'integer',
        'total_streams' => 'integer',
        'is_notification' => 'integer',
        'is_verified' => 'integer',
        'show_on_map' => 'integer',
        'anonymous' => 'integer',
        'is_video_call' => 'integer',
        'can_go_live' => 'integer',
        'is_live_now' => 'integer',
        'is_fake' => 'integer',
        'following' => 'integer',
        'followers' => 'integer',
        'gender_preferred' => 'integer',
        'age_preferred_min' => 'integer',
        'age_preferred_max' => 'integer',
        'distance_preference' => 'integer',
        'relationship_goal_id' => 'integer',
    ];

    public function images()
    {
        return $this->hasMany(Images::class, 'user_id', 'id');
    }

    public function notifications()
    {
        return $this->hasMany(UserNotification::class, 'user_id', 'id');
    }

    public function interests()
    {
        return $this->hasMany(Interest::class, 'id', 'interests');
    }

    function liveApplications()
    {
        return $this->hasOne(LiveApplications::class, 'user_id', 'id');
    }
    
    function verifyRequest()
    {
        return $this->hasOne(VerifyRequest::class, 'user_id', 'id');
    }

    function liveHistory()
    {
        return $this->hasMany(LiveHistory::class, 'user_id', 'id');
    }

    function redeemRequests()
    {
        return $this->hasMany(RedeemRequest::class, 'user_id', 'id');
    }

    public function stories()
    {
        return $this->hasMany(Story::class, 'user_id', 'id');
    }
}

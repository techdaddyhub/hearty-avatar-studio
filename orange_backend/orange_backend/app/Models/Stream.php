<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Stream extends Model
{
    use HasFactory;

    protected $table = 'streams';

    protected $fillable = [
        'stream_uuid',
        'user_id',
        'title',
        'description',
        'avatar_id',
        'status',
        'ingress_url',
        'stream_key',
        'viewer_count',
        'peak_viewers',
        'started_at',
        'ended_at',
    ];

    protected $dates = [
        'started_at',
        'ended_at',
    ];

    public function user()
    {
        return $this->belongsTo(Users::class, 'user_id', 'id');
    }

    public function avatar()
    {
        return $this->belongsTo(Avatar::class, 'avatar_id', 'id');
    }

    public function destinations()
    {
        return $this->hasMany(StreamDestination::class, 'stream_id', 'id');
    }
}

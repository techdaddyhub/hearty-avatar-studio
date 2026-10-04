<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CallParticipant extends Model
{
    use HasFactory;

    protected $table = 'call_participants';

    protected $fillable = [
        'call_id',
        'user_id',
        'role',
        'status',
        'avatar_mode',
        'avatar_id',
        'joined_at',
        'left_at',
    ];

    protected $casts = [
        'avatar_mode' => 'boolean',
    ];

    protected $dates = [
        'joined_at',
        'left_at',
    ];

    public function call()
    {
        return $this->belongsTo(Call::class, 'call_id', 'id');
    }

    public function user()
    {
        return $this->belongsTo(Users::class, 'user_id', 'id');
    }

    public function avatar()
    {
        return $this->belongsTo(Avatar::class, 'avatar_id', 'id');
    }
}

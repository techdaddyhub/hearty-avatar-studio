<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Call extends Model
{
    use HasFactory;

    protected $table = 'calls';

    protected $fillable = [
        'call_uuid',
        'caller_id',
        'call_type',
        'room_id',
        'status',
        'started_at',
        'ended_at',
    ];

    protected $dates = [
        'started_at',
        'ended_at',
    ];

    public function caller()
    {
        return $this->belongsTo(Users::class, 'caller_id', 'id');
    }

    public function participants()
    {
        return $this->hasMany(CallParticipant::class, 'call_id', 'id');
    }
}

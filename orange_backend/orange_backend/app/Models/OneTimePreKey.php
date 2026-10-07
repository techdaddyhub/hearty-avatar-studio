<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OneTimePreKey extends Model
{
    use HasFactory;

    public $table = 'one_time_prekeys';
    public $timestamps = false;
    protected $fillable = [
        'user_id',
        'device_id',
        'key_id',
        'public_key',
        'is_consumed',
    ];

    public function user()
    {
        return $this->belongsTo(Users::class, 'user_id', 'id');
    }
}


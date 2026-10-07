<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserPreKey extends Model
{
    use HasFactory;

    public $table = 'user_prekeys';
    protected $fillable = [
        'user_id',
        'device_id',
        'identity_key',
        'signed_prekey_id',
        'signed_prekey',
        'signed_prekey_signature',
        'registration_id',
    ];

    public function user()
    {
        return $this->belongsTo(Users::class, 'user_id', 'id');
    }
}

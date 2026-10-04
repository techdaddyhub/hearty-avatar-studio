<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Crypt;

class SocialAccount extends Model
{
    use HasFactory;

    protected $table = 'social_accounts';

    protected $fillable = [
        'user_id',
        'platform',
        'account_name',
        'account_id',
        'channel_title',
        'access_token_encrypted',
        'refresh_token_encrypted',
        'token_expires_at',
        'is_connected',
    ];

    protected $casts = [
        'is_connected' => 'boolean',
    ];

    protected $dates = [
        'token_expires_at',
    ];

    public function user()
    {
        return $this->belongsTo(Users::class, 'user_id', 'id');
    }

    public function setAccessTokenAttribute($value)
    {
        $this->attributes['access_token_encrypted'] = $value ? Crypt::encryptString($value) : null;
    }

    public function getAccessTokenAttribute()
    {
        try {
            return $this->attributes['access_token_encrypted'] ? Crypt::decryptString($this->attributes['access_token_encrypted']) : null;
        } catch (\Exception $e) {
            return null;
        }
    }

    public function setRefreshTokenAttribute($value)
    {
        $this->attributes['refresh_token_encrypted'] = $value ? Crypt::encryptString($value) : null;
    }

    public function getRefreshTokenAttribute()
    {
        try {
            return $this->attributes['refresh_token_encrypted'] ? Crypt::decryptString($this->attributes['refresh_token_encrypted']) : null;
        } catch (\Exception $e) {
            return null;
        }
    }
}

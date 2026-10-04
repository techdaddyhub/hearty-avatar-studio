<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Crypt;

class StreamDestination extends Model
{
    use HasFactory;

    protected $table = 'stream_destinations';

    protected $fillable = [
        'stream_id',
        'user_id',
        'platform',
        'destination_name',
        'rtmp_url',
        'stream_key_encrypted',
        'is_enabled',
        'status',
        'error_message',
    ];

    protected $casts = [
        'is_enabled' => 'boolean',
    ];

    public function stream()
    {
        return $this->belongsTo(Stream::class, 'stream_id', 'id');
    }

    public function user()
    {
        return $this->belongsTo(Users::class, 'user_id', 'id');
    }

    public function setStreamKeyAttribute($value)
    {
        $this->attributes['stream_key_encrypted'] = Crypt::encryptString($value);
    }

    public function getStreamKeyAttribute()
    {
        try {
            return Crypt::decryptString($this->attributes['stream_key_encrypted']);
        } catch (\Exception $e) {
            return null;
        }
    }
}

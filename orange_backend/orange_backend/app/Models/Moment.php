<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Moment extends Model
{
    use HasFactory;

    public $table = 'moments';
    public $timestamps = false;
    protected $fillable = [
        'user_id',
        'encrypted_content',
        'encrypted_media_urls',
        'content_iv',
        'content_mac',
        'visibility',
    ];

    protected $casts = [
        'user_id' => 'integer',
        'encrypted_media_urls' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(Users::class, 'user_id', 'id')->with('images');
    }

    public function keyEnvelopes()
    {
        return $this->hasMany(MomentKeyEnvelope::class, 'moment_id', 'id');
    }
}


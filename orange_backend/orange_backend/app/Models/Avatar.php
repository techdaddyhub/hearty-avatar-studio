<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Avatar extends Model
{
    use HasFactory;

    protected $table = 'avatars';

    protected $fillable = [
        'user_id',
        'name',
        'type',
        'thumbnail_url',
        'model_url',
        'config_json',
        'is_default',
        'is_active',
    ];

    protected $casts = [
        'is_default' => 'boolean',
        'is_active' => 'boolean',
        'config_json' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(Users::class, 'user_id', 'id');
    }

    public function assets()
    {
        return $this->hasMany(AvatarAsset::class, 'avatar_id', 'id');
    }
}

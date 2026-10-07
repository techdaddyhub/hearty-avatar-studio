<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MiniProgram extends Model
{
    use HasFactory;

    public $table = 'mini_programs';
    public $timestamps = false;
    protected $fillable = [
        'app_id',
        'name',
        'icon_url',
        'entry_url',
        'package_hash',
        'permissions',
        'is_active',
    ];

    protected $casts = [
        'permissions' => 'array',
        'is_active' => 'integer',
    ];
}


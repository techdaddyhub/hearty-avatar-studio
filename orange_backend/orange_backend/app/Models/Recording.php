<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Recording extends Model
{
    use HasFactory;

    protected $table = 'recordings';

    protected $fillable = [
        'user_id',
        'session_type',
        'session_id',
        'title',
        'file_path',
        'file_size',
        'duration_seconds',
        'resolution',
    ];

    public function user()
    {
        return $this->belongsTo(Users::class, 'user_id', 'id');
    }

    public function getDownloadUrlAttribute()
    {
        return GlobalFunction::createMediaUrl($this->file_path);
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Contact extends Model
{
    use HasFactory;

    public $table = 'contacts';
    protected $fillable = [
        'user_id',
        'contact_user_id',
        'remark',
        'is_starred',
        'is_muted',
        'is_blocked',
        'source',
    ];

    protected $casts = [
        'user_id' => 'integer',
        'contact_user_id' => 'integer',
        'is_starred' => 'integer',
        'is_muted' => 'integer',
        'is_blocked' => 'integer',
    ];

    public function owner()
    {
        return $this->belongsTo(Users::class, 'user_id', 'id');
    }

    public function contactUser()
    {
        return $this->belongsTo(Users::class, 'contact_user_id', 'id')->with('images');
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ContactRequest extends Model
{
    use HasFactory;

    public $table = 'contact_requests';
    protected $fillable = [
        'sender_id',
        'recipient_id',
        'greeting_message',
        'status',
    ];

    protected $casts = [
        'sender_id' => 'integer',
        'recipient_id' => 'integer',
    ];

    public function sender()
    {
        return $this->belongsTo(Users::class, 'sender_id', 'id')->with('images');
    }

    public function recipient()
    {
        return $this->belongsTo(Users::class, 'recipient_id', 'id')->with('images');
    }
}


<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EncryptedMessageQueue extends Model
{
    use HasFactory;

    public $table = 'encrypted_message_queue';
    public $timestamps = false;
    protected $fillable = [
        'message_uid',
        'sender_id',
        'recipient_id',
        'device_id',
        'message_type',
        'ciphertext_payload',
        'iv',
        'mac',
        'media_url',
        'status',
    ];

    protected $casts = [
        'sender_id' => 'integer',
        'recipient_id' => 'integer',
        'device_id' => 'integer',
    ];
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MomentKeyEnvelope extends Model
{
    use HasFactory;

    public $table = 'moment_key_envelopes';
    public $timestamps = false;
    protected $fillable = [
        'moment_id',
        'recipient_id',
        'encrypted_symmetric_key',
    ];

    protected $casts = [
        'moment_id' => 'integer',
        'recipient_id' => 'integer',
    ];

    public function moment()
    {
        return $this->belongsTo(Moment::class, 'moment_id', 'id');
    }
}

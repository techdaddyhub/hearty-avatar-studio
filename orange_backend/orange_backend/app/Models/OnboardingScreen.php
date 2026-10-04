<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OnboardingScreen extends Model
{
    use HasFactory;
    public $table = "onboarding_screens";

    protected $fillable = [
        'title',
        'position',
        'description',
        'image'
    ];

}

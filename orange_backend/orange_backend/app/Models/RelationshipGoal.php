<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RelationshipGoal extends Model
{
    use HasFactory;
    public $table = "relationship_goals";

    protected $fillable = [
        'title',
        'description'
    ];
}

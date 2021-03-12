<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Question extends Model
{

    protected $table = 'Questions';
    public $timestamps = false;

    protected $fillable = [
        'id',
        'question',
        'answers',
        'correctOption',
        'ip',
        'modifiedBy',
        'createdAt'
    ];

    protected $casts = [
        'answers' => 'array'
    ];
}

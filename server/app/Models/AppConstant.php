<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AppConstant extends Model
{

    protected $table = 'AppConstants';
    public $timestamps = false;

    protected $fillable = [
        'id',
        'appConstantName',
        'appConstantStringValue',
        'appConstantJsonValue',
        'appConstantIntegerValue',
        'ip',
        'modifiedBy',
        'createdAt',
    ];

    protected $casts = [
        'appConstantJsonValue' => 'array'
    ];
}

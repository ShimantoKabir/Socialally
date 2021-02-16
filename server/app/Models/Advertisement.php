<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Advertisement extends Model
{

    protected $table = 'Advertisements';
    public $timestamps = false;

    protected $fillable = [
        'id',
        'title',
        'targetedDestinationUrl',
        'bannerImageUrl',
        'adCost',
        'adDuration',
        'givenBy',
        'ip',
        'modifiedBy',
        'createdAt',
    ];
}

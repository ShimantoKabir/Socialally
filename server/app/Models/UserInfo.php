<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserInfo extends Model
{

    protected $table = 'UserInfos';
    public $timestamps = false;

    protected $fillable = [
        'id',
        'token',
        'email',
        'imageUrl',
        'password',
        'lastName',
        'regionId',
        'firstName',
        'countryId',
        'contactNumber',
        'isEmailVerified',
        'agreedTermsAndCondition',
        'wantNewsLetterNotification',
        'type',
        'ip',
        'modifiedBy',
        'createdAt',
    ];
}

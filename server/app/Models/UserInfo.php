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
        'regionName',
        'firstName',
        'countryName',
        'contactNumber',
        'nationalId',
        'passportId',
        'isEmailVerified',
        'agreedTermsAndCondition',
        'wantNewsLetterNotification',
        'accountNumber',
        'type',
        'referId',
        'userInfoId',
        'referredBy',
        'quantityOfEarnByRefer',
        'ip',
        'modifiedBy',
        'createdAt'
    ];
}

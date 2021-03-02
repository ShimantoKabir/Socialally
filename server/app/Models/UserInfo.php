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
        'nationalId',
        'passportId',
        'isEmailVerified',
        'agreedTermsAndCondition',
        'wantNewsLetterNotification',
        'accountNumber',
        'type',
        'referId',
        'referredBy',
        'quantityOfEarnByRefer',
        'ip',
        'modifiedBy',
        'createdAt',
    ];
}

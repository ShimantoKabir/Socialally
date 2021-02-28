<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{

    protected $table = 'Notifications';
    public $timestamps = false;

    protected $fillable = [
        'id',
        'message',
        'receiverId',
        'senderId',
        'isSeen',
        'isForAll',
        'type',
        'ip',
        'modifiedBy',
        'createdAt',
    ];
}

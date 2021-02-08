<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;


class Transaction extends Model
{

    protected $table = 'Transactions';
    public $timestamps = false;

    protected $fillable = [
        'id',
        'depositAmount',
        'withdrawAmount',
        'accountHolderId',
        'transactionType',
        'transactionId',
        'accountNumber',
        'paymentGatewayName',
        'status',
        'ip',
        'modifiedBy',
        'createdAt',
    ];
}

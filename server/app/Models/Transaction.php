<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;


class Transaction extends Model
{

    protected $table = 'Transactions';
    public $timestamps = false;

    protected $fillable = [
        'id',
        'creditAmount', // deposit 101
        'debitAmount', // withdraw 102
        'accountHolderId',
        'ledgerId',
        'transactionId',
        'accountNumber',
        'paymentGatewayName',
        'status',
        'ip',
        'modifiedBy',
        'createdAt'
    ];
}

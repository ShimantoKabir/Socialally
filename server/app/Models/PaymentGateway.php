<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PaymentGateway extends Model
{

    protected $table = 'PaymentGateways';
    public $timestamps = false;

    protected $fillable = [
        'id',
        'paymentGatewayName',
        'cashInNumber',
        'personalNumber',
        'agentNumber',
        'ip',
        'modifiedBy',
        'createdAt',
    ];
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChartOfAccount extends Model
{

    protected $table = 'ChartOfAccounts';
    public $timestamps = false;

    protected $fillable = [
        'id',
        'ledgerId',
        'ledgerName',
        'ip',
        'modifiedBy',
        'createdAt',
    ];
}

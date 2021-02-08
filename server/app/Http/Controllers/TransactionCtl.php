<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Repository\TransactionRpo;
use App\Http\Controllers\Controller;

class TransactionCtl extends Controller
{

    private $transactionRpo;

    /**
     * TransactionCtl constructor.
     */
    public function __construct()
    {
        $this->transactionRpo = new TransactionRpo();
    }

    public function create(Request $request)
    {
        return $this->transactionRpo->create($request);
    }

    public function readByQuery(Request $request)
    {
        return $this->transactionRpo->readByQuery($request);
    }
}

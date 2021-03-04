<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Repository\PaymentGatewayRpo;

class PaymentGatewayCtl extends Controller
{

    private $paymentGatewayRpo;

    /**
     * PaymentGatewayCtl constructor.
     */
    public function __construct()
    {
        $this->paymentGatewayRpo = new PaymentGatewayRpo();
    }

    public function create(Request $request)
    {
        return $this->paymentGatewayRpo->create($request);
    }

    public function read(Request $request)
    {
        return $this->paymentGatewayRpo->read($request);
    }

    public function update(Request $request)
    {
        return $this->paymentGatewayRpo->update($request);
    }

    public function delete(Request $request, $id)
    {
        return $this->paymentGatewayRpo->delete($request, $id);
    }
}

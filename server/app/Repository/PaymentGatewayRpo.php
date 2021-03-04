<?php

namespace App\Repository;

use Exception;
use Illuminate\Http\Request;
use App\Models\PaymentGateway;
use Illuminate\Support\Facades\DB;

class PaymentGatewayRpo
{

    public function create(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rPaymentGateway = $request['paymentGateway'];
        DB::beginTransaction();
        try {

            $paymentGateway = new PaymentGateway();
            $paymentGateway->paymentGatewayName = $rPaymentGateway['paymentGatewayName'];
            $paymentGateway->agentNumber = $rPaymentGateway['agentNumber'];
            $paymentGateway->cashInNumber = $rPaymentGateway['cashInNumber'];
            $paymentGateway->personalNumber = $rPaymentGateway['personalNumber'];
            $paymentGateway->save();

            $res['code'] = 200;
            $res['msg'] = "Payment gateway save successfully!";

            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function read(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            $res['paymentGateways'] = PaymentGateway::all();
            $res['code'] = 200;
            $res['msg'] = "Payment gateway fetched successfully!";
        } catch (Exception $e) {
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function update(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rPaymentGateway = $request['paymentGateway'];
        DB::beginTransaction();
        try {

            PaymentGateway::where("id", $rPaymentGateway['id'])
                ->update(array(
                    "agentNumber" =>  $rPaymentGateway['agentNumber'],
                    "paymentGatewayName" =>  $rPaymentGateway['paymentGatewayName'],
                    "cashInNumber" =>  $rPaymentGateway['cashInNumber'],
                    "personalNumber" =>  $rPaymentGateway['personalNumber']
                ));

            $res['lol'] = $request->all();
            $res['code'] = 200;
            $res['msg'] = "Payment gateway updated successfully!";

            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function delete(Request $request, $id)
    {
        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            PaymentGateway::where('id', $id)->delete();

            $res['code'] = 200;
            $res['msg'] = "Payment gateway deleted successfully!";
        } catch (Exception $e) {
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }
}

<?php

namespace App\Repository;

use App\Models\Notification;
use App\Models\Transaction;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TransactionRpo
{

    public function create(Request $request)
    {

        $res = [
            "code" => "",
            "msg" => ""
        ];

        $rTransaction = $request->transaction;

        DB::beginTransaction();
        try {

            $transaction = new Transaction();
            $transaction->depositAmount = $rTransaction["depositAmount"];
            $transaction->withdrawAmount = $rTransaction["withdrawAmount"];
            $transaction->accountHolderId = $rTransaction["accountHolderId"];
            $transaction->transactionType = $rTransaction["transactionType"];
            $transaction->transactionId = $rTransaction["transactionId"];
            $transaction->accountNumber = $rTransaction["accountNumber"];
            $transaction->paymentGatewayName = $rTransaction["paymentGatewayName"];
            $transaction->save();

            if ($rTransaction["transactionType"] == "deposit") {
                $msg = "Deposit request " . $rTransaction['depositAmount'] . "$ By " . $rTransaction["paymentGatewayName"] . ".";
            } else {
                $msg = "Withdraw request " . $rTransaction['withdrawAmount'] . "$ By " . $rTransaction["paymentGatewayName"] . ".";
            }

            Notification::create([
                "message" => $msg,
                "receiverId" => 2,
                "senderId" => $rTransaction['accountHolderId'],
                "isSeen" => 0,
                "type" => 2
            ]);

            DB::commit();
            $res['code'] = 200;
            $res['msg'] = "Transaction save successfully!";
        } catch (Exception $e) {
            DB::rollback();
            $res['code'] = $e->getCode();
            $res['msg'] = $e->getMessage();
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function readByQuery(Request $request)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        $userInfoId = 0;
        $parPage = 10;
        $pageIndex = 10;

        if (!$request->has('par-page')) {
            $res['code'] = 404;
            $res['msg'] = "Par page required!";
        } else if (!$request->has('page-index')) {
            $res['code'] = 404;
            $res['msg'] = "Page index required!";
        } else {

            $parPage = $request->query('par-page');
            $pageIndex = $request->query('page-index');

            try {

                $sql = "SELECT * FROM Transactions";

                if ($request->has('user-info-id')) {
                    $userInfoId = $request->query('user-info-id');
                    $sql = $sql . " WHERE Transactions.accountHolderId = " . $userInfoId
                        . " ORDER BY Transactions.id DESC LIMIT " . $pageIndex . ", " . $parPage;
                } else {
                    $sql = $sql .  " ORDER BY Transactions.id DESC LIMIT " . $pageIndex . ", " . $parPage;
                }

                $res['transactions'] = DB::select(DB::raw($sql));

                $res['code'] = 200;
                $res['msg'] = "Transactions fetched successfully!";
            } catch (Exception $e) {
                $res['msg'] = $e->getMessage();
                $res['code'] = 404;
            }
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }


    public function update(Request $request)
    {
        $res = [
            "code" => "",
            "msg" => ""
        ];

        $rTransaction = $request->transaction;

        DB::beginTransaction();
        try {

            if ($rTransaction["transactionType"] == "withdraw") {
                $updateQuery = array(
                    "status" => $rTransaction["status"],
                    "transactionId" => $rTransaction["transactionId"]
                );
                $msg = "Your withdraw request "
                    . $rTransaction['withdrawAmount']
                    . "$ By "
                    . $rTransaction["paymentGatewayName"] . " is "
                    . $rTransaction["status"];
            } else {
                $updateQuery = array(
                    "status" => $rTransaction["status"]
                );
                $msg = "Your deposit request "
                    . $rTransaction['depositAmount']
                    . "$ By "
                    . $rTransaction["paymentGatewayName"] . " is "
                    . $rTransaction["status"];
            }

            Transaction::where('id', $rTransaction["id"])->update($updateQuery);

            Notification::create([
                "message" => $msg,
                "receiverId" => $rTransaction["accountHolderId"],
                "senderId" => 2,
                "isSeen" => 0,
                "type" => 1
            ]);

            DB::commit();
            $res['code'] = 200;
            $res['msg'] = "Transactions " . $rTransaction["status"] . " successfully!";
        } catch (Exception $e) {
            DB::rollback();
            $res['msg'] = $e->getMessage();
            $res['code'] = 404;
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }
}

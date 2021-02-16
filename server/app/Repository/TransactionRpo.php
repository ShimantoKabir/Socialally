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

            // deposit = creditAmount,101 , withdraw = debitAmount,102
            if ($rTransaction['ledgerId'] == 101) {
                self::saveTransaction($rTransaction);
                $res['code'] = 200;
                $res['msg'] = "Deposit successfully!";
            } else {

                $balance = self::getBalance($rTransaction);

                if ($rTransaction['debitAmount'] < $balance) {
                    self::saveTransaction($rTransaction);
                    $res['code'] = 200;
                    $res['msg'] = "Your withdrawal amount is waiting for admin approval!";
                } else {
                    $res['code'] = 404;
                    $res['msg'] = "Your withdrawal amount cross the balance!";
                }
            }


            if ($rTransaction["ledgerId"] == 101) {
                $msg = "Deposit request " . $rTransaction['creditAmount'] . "$ By " . $rTransaction["paymentGatewayName"] . ".";
            } else {
                $msg = "Withdraw request " . $rTransaction['debitAmount'] . "$ By " . $rTransaction["paymentGatewayName"] . ".";
            }

            Notification::create([
                "message" => $msg,
                "receiverId" => 2,
                "senderId" => $rTransaction['accountHolderId'],
                "isSeen" => 0,
                "type" => 2
            ]);

            DB::commit();
        } catch (Exception $e) {
            DB::rollback();
            $res['code'] = $e->getCode();
            $res['msg'] = $e->getMessage();
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public static function saveTransaction($rTransaction)
    {
        $transaction = new Transaction();
        $transaction->creditAmount = $rTransaction["creditAmount"];
        $transaction->debitAmount = $rTransaction["debitAmount"];
        $transaction->accountHolderId = $rTransaction["accountHolderId"];
        $transaction->ledgerId = $rTransaction["ledgerId"];
        $transaction->transactionId = $rTransaction["transactionId"];
        $transaction->accountNumber = $rTransaction["accountNumber"];
        $transaction->status = $rTransaction["status"];
        $transaction->paymentGatewayName = $rTransaction["paymentGatewayName"];
        $transaction->save();
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

                // deposit = creditAmount,101 , withdraw = debitAmount,102
                $sql = "SELECT
                            Transactions.id AS id,
                            Transactions.accountHolderId AS accountHolderId,
                            IFNULL(transactionId,'N/A') AS transactionId,
                            IFNULL(Transactions.paymentGatewayName,'N/A') AS paymentGatewayName,
                            ChartOfAccounts.ledgerName,
                            IFNULL(accountNumber,'N/A') AS accountNumber,
                            Transactions.status,
                            Transactions.createdAt AS createdAt,
                            ChartOfAccounts.ledgerId,
                            Transactions.debitAmount,
                            Transactions.creditAmount,
                            IFNULL(Transactions.debitAmount,Transactions.creditAmount) AS amount 
                        FROM
                            Transactions 
                            JOIN
                            ChartOfAccounts 
                            on Transactions.ledgerId = ChartOfAccounts.ledgerId";

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

            if ($rTransaction["ledgerId"] == 102) {
                $updateQuery = array(
                    "status" => $rTransaction["status"],
                    "transactionId" => $rTransaction["transactionId"]
                );
                $msg = "Your withdraw request "
                    . $rTransaction['debitAmount']
                    . "$ By "
                    . $rTransaction["paymentGatewayName"] . " is "
                    . $rTransaction["status"];
            } else {
                $updateQuery = array(
                    "status" => $rTransaction["status"]
                );
                $msg = "Your deposit request "
                    . $rTransaction['creditAmount']
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

    public function getBalanceSummary(Request $request)
    {

        $res = [
            "code" => "",
            "msg" => ""
        ];

        $rTransaction = $request->transaction;

        try {

            if (!$request->has('account-holder-id')) {
                $res['code'] = 404;
                $res['msg'] = "Account holder id required!";
            } else {

                $depositTransaction = [
                    "accountHolderId" => $request->query("account-holder-id"),
                    "ledgerId" => 101
                ];

                $withdrawTransaction = [
                    "accountHolderId" => $request->query("account-holder-id"),
                    "ledgerId" => 102
                ];

                $earningTransaction = [
                    "accountHolderId" => $request->query("account-holder-id"),
                    "ledgerId" => 103
                ];

                $jobPostingTransaction = [
                    "accountHolderId" => $request->query("account-holder-id"),
                    "ledgerId" => 103
                ];

                $res['balance'] = self::getBalance($depositTransaction);
                $res['depositTransaction'] = self::getAmountByLedger($depositTransaction);
                $res['withdrawTransaction'] = self::getAmountByLedger($withdrawTransaction);
                $res['earningTransaction'] = self::getAmountByLedger($earningTransaction);
                $res['jobPostingTransaction'] = self::getAmountByLedger($jobPostingTransaction);
                $res['code'] = 200;
                $res['msg'] = "Balance summary getting successful!";
            }
        } catch (Exception $e) {
            $res['code'] = $e->getCode();
            $res['msg'] = $e->getMessage();
        }
        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public static function getBalance($rTransaction)
    {

        $sql = "SELECT
                    TRUNCATE((IFNULL(SUM(creditAmount),0.0) - IFNULL(SUM(debitAmount),0.0)),3) AS balance
                FROM
                    Transactions 
                WHERE
                    status = 'Approved'
                AND
                    accountHolderId = " . $rTransaction['accountHolderId'];

        $res = DB::select(DB::raw($sql));

        return $res[0]->balance;
    }

    public static function getAmountByLedger($rTransaction)
    {

        $sql = "SELECT
            IFNULL(SUM(debitAmount),0.0) AS debitAmount,
            IFNULL(SUM(creditAmount),0.0) AS creditAmount
        FROM
            Transactions 
        WHERE
            status = 'Approved'
        AND
            accountHolderId = " . $rTransaction['accountHolderId'] . " AND ledgerId = " . $rTransaction['ledgerId'];

        $res = DB::select(DB::raw($sql));

        return $res[0];
    }
}

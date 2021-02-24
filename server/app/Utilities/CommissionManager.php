<?php

namespace App\Utilities;

use App\Models\UserInfo;
use App\Models\AppConstant;
use App\Models\Notification;
use App\Repository\TransactionRpo;

class CommissionManager
{

    public static function giveCommission($userInfoId, $type)
    {

        $userInfo = UserInfo::where("id", $userInfoId)->first();

        if ($userInfo['referredBy'] != null) {

            $commissionGainer = UserInfo::where("referId", $userInfo['referredBy'])->first();

            if ($userInfo['quantityOfEarnByRefer'] == -1) {

                return self::executeTransaction($commissionGainer, $userInfo, $type);
            } else {

                if ($userInfo['quantityOfEarnByRefer'] != 0) {

                    UserInfo::where('id', $userInfoId)->update(array(
                        'quantityOfEarnByRefer' => $userInfo['quantityOfEarnByRefer'] - 1,
                    ));

                    return self::executeTransaction($commissionGainer, $userInfo, $type);
                }
            }
        } else {
            return null;
        }
    }

    public static function executeTransaction($commissionGainer, $userInfo, $type)
    {

        $referCommission = AppConstant::where(
            "appConstantName",
            "referCommission"
        )->first()['appConstantDoubleValue'];

        $userName = $userInfo['firstName'] == null ? $userInfo['email'] : $userInfo['firstName'];

        $rTransaction = [
            "creditAmount" => $referCommission,
            "debitAmount" => null,
            "accountHolderId" => $commissionGainer["id"],
            "ledgerId" => 106,
            "status" => "Pending",
            "transactionId" => null,
            "accountNumber" => null,
            "paymentGatewayName" => null,
        ];

        TransactionRpo::saveTransaction($rTransaction);

        $notification = [
            "message" => "Your " . $referCommission . "GBP commission is pending for admin approval by " . $userName . " " . $type . ".",
            "receiverId" => $commissionGainer["id"],
            "senderId" => $userInfo["id"],
            "isSeen" => 0,
            "type" => 1
        ];

        Notification::create($notification);

        $res = [
            'referCommission' => $referCommission,
            'rTransaction' => $rTransaction,
            'notification' => $notification,
        ];

        return $res;
    }
}

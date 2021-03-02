<?php

namespace App\Utilities;

use App\Models\AppConstant;

class AppConstantReader
{

    public static function read()
    {

        $res = [];

        $appConstants = AppConstant::all();

        foreach ($appConstants as $key => $val) {
            if ($val["appConstantName"] == "clientDashboardHeadline") {
                $res["clientDashboardHeadline"] = $val["appConstantStringValue"];
            }
            if ($val["appConstantName"] == "jobApprovalType") {
                $res["jobApprovalType"] = $val["appConstantIntegerValue"];
            }
            if ($val["appConstantName"] == "referCommission") {
                $res["referCommission"] = $val["appConstantDoubleValue"];
            }
            if ($val["appConstantName"] == "referCommission") {
                $res["referCommission"] = $val["appConstantDoubleValue"];
            }
            if ($val["appConstantName"] == "jobPostingCharge") {
                $res["jobPostingCharge"] = $val["appConstantDoubleValue"];
            }
            if ($val["appConstantName"] == "minimumWithdraw") {
                $res["minimumWithdraw"] = $val["appConstantDoubleValue"];
            }
            if ($val["appConstantName"] == "minimumDeposit") {
                $res["minimumDeposit"] = $val["appConstantDoubleValue"];
            }
            if ($val["appConstantName"] == "takePerPound") {
                $res["takePerPound"] = $val["appConstantDoubleValue"];
            }
            if ($val["appConstantName"] == "proofSubmissionStatus") {
                $res["proofSubmissionStatus"] = $val["appConstantJsonValue"];
            }
            if ($val["appConstantName"] == "adCostPlanList") {
                $res["adCostPlanList"] = $val["appConstantJsonValue"];
            }
            if ($val["appConstantName"] == "supportInfo") {
                $res["supportInfo"] = $val["appConstantJsonValue"];
            }
        }

        return $res;
    }
}

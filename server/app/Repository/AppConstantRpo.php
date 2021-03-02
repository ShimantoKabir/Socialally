<?php

namespace App\Repository;

use Exception;
use App\Models\AppConstant;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Utilities\AppConstantReader;

class AppConstantRpo
{

    public function getGeneralSettingData(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            $appConstants = AppConstantReader::read();

            $res["clientDashboardHeadline"] = $appConstants["clientDashboardHeadline"];
            $res["referCommission"] = $appConstants["referCommission"];
            $res["jobPostingCharge"] = $appConstants["jobPostingCharge"];
            $res["minimumWithdraw"] = $appConstants["minimumWithdraw"];
            $res["minimumDeposit"] = $appConstants["minimumDeposit"];
            $res["takePerPound"] = $appConstants["takePerPound"];
            $res["jobApprovalType"] = $appConstants["jobApprovalType"];

            $res['msg'] = "App constant value fetched successfully!";
            $res['code'] = 200;
        } catch (Exception $e) {
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }

    public function updateGeneralSettingData(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $generalSetting = $request->generalSetting;

        DB::beginTransaction();
        try {

            AppConstant::where('appConstantName', 'takePerPound')->update(array(
                'appConstantDoubleValue' => $generalSetting['takePerPound']
            ));

            AppConstant::where('appConstantName', 'minimumDeposit')->update(array(
                'appConstantDoubleValue' => $generalSetting['minimumDeposit']
            ));

            AppConstant::where('appConstantName', 'minimumWithdraw')->update(array(
                'appConstantDoubleValue' => $generalSetting['minimumWithdraw']
            ));

            AppConstant::where('appConstantName', 'jobPostingCharge')->update(array(
                'appConstantDoubleValue' => $generalSetting['jobPostingCharge']
            ));

            AppConstant::where('appConstantName', 'referCommission')->update(array(
                'appConstantDoubleValue' => $generalSetting['referCommission']
            ));

            AppConstant::where('appConstantName', 'jobApprovalType')->update(array(
                'appConstantIntegerValue' => $generalSetting['jobApprovalType']
            ));

            AppConstant::where('appConstantName', 'clientDashboardHeadline')->update(array(
                'appConstantStringValue' => $generalSetting['clientDashboardHeadline']
            ));

            DB::commit();
            $res['msg'] = "App constant updated successfully!";
            $res['code'] = 200;
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }
}

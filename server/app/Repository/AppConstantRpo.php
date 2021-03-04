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
            $res["quantityOfEarnByRefer"] = $appConstants["quantityOfEarnByRefer"];

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

            AppConstant::where('appConstantName', 'quantityOfEarnByRefer')->update(array(
                'appConstantIntegerValue' => $generalSetting['quantityOfEarnByRefer']
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

    public function getAddCostPlanList(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            $res["adCostPlans"] = AppConstant::where("appConstantName", "adCostPlanList")->first()['appConstantJsonValue'];
            $res['msg'] = "Add cost plan list fetched successfully!";
            $res['code'] = 200;
        } catch (Exception $e) {
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }

    public function createAddCostPlan(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rAdCostPlan = $request->adCostPlan;

        DB::beginTransaction();
        try {

            $adCostPlans = AppConstant::where("appConstantName", "adCostPlanList")->first()['appConstantJsonValue'];

            array_push($adCostPlans, array(
                "day" => $rAdCostPlan['day'],
                "cost" => $rAdCostPlan['cost']
            ));

            AppConstant::where("appConstantName", "adCostPlanList")
                ->update([
                    "appConstantJsonValue" => json_encode($adCostPlans)
                ]);

            $res['msg'] = "Ad cost plan save successfully!";
            $res['code'] = 200;

            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }

    public function deleteAddCostPlan(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            $adCostPlans = AppConstant::where("appConstantName", "adCostPlanList")->first()['appConstantJsonValue'];

            array_pop($adCostPlans);

            AppConstant::where("appConstantName", "adCostPlanList")
                ->update([
                    "appConstantJsonValue" => json_encode($adCostPlans)
                ]);

            $res['msg'] = "Ad cost plan deleted successfully!";
            $res['code'] = 200;
        } catch (Exception $e) {
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }


    public function getSupportInfoList(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            $res["supportInfos"] = AppConstant::where("appConstantName", "supportInfoList")->first()['appConstantJsonValue'];
            $res['msg'] = "Support info fetched successfully!";
            $res['code'] = 200;
        } catch (Exception $e) {
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }

    public function createSupportInfo(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rSupportInfo = $request->supportInfo;

        DB::beginTransaction();
        try {

            $adCostPlans = AppConstant::where("appConstantName", "supportInfoList")->first()['appConstantJsonValue'];

            array_push($adCostPlans, array(
                "name" => $rSupportInfo['name'],
                "address" => $rSupportInfo['address']
            ));

            AppConstant::where("appConstantName", "supportInfoList")
                ->update([
                    "appConstantJsonValue" => json_encode($adCostPlans)
                ]);

            $res['msg'] = "Support info save successfully!";
            $res['code'] = 200;

            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }

    public function deleteSupportInfo(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            $adCostPlans = AppConstant::where("appConstantName", "supportInfoList")->first()['appConstantJsonValue'];

            array_pop($adCostPlans);

            AppConstant::where("appConstantName", "supportInfoList")
                ->update([
                    "appConstantJsonValue" => json_encode($adCostPlans)
                ]);

            $res['msg'] = "Support info deleted successfully!";
            $res['code'] = 200;
        } catch (Exception $e) {
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }
}

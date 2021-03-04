<?php

namespace App\Http\Controllers;


use Illuminate\Http\Request;
use App\Repository\AppConstantRpo;

class AppConstantCtl extends Controller
{

    private $appConstantRpo;

    /**
     * AppConstantCtl constructor.
     */
    public function __construct()
    {
        $this->appConstantRpo = new AppConstantRpo();
    }

    public function getGeneralSettingData(Request $request)
    {
        return $this->appConstantRpo->getGeneralSettingData($request);
    }

    public function updateGeneralSettingData(Request $request)
    {
        return $this->appConstantRpo->updateGeneralSettingData($request);
    }

    public function getAddCostPlanList(Request $request)
    {
        return $this->appConstantRpo->getAddCostPlanList($request);
    }

    public function createAddCostPlan(Request $request)
    {
        return $this->appConstantRpo->createAddCostPlan($request);
    }

    public function deleteAddCostPlan(Request $request)
    {
        return $this->appConstantRpo->deleteAddCostPlan($request);
    }

    public function getSupportInfoList(Request $request)
    {
        return $this->appConstantRpo->getSupportInfoList($request);
    }

    public function createSupportInfo(Request $request)
    {
        return $this->appConstantRpo->createSupportInfo($request);
    }

    public function deleteSupportInfo(Request $request)
    {
        return $this->appConstantRpo->deleteSupportInfo($request);
    }
}

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
}

<?php

namespace App\Repository;

use App\Models\AppConstant;
use Exception;
use Illuminate\Http\Request;

class WelcomeRpo
{

    public function read(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            $res['supportInfoList'] = AppConstant::select("appConstantJsonValue")
                ->where("appConstantName", "supportInfoList")
                ->first()["appConstantJsonValue"];

            $res["code"] = 200;
            $res['msg'] = "OK";
        } catch (Exception $e) {
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }
}

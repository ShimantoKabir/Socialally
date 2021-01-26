<?php


namespace App\Utilities;


use App\Models\UserInfo;

class Auth
{

    public static function isValid($request, $dbOpState)
    {

        /*
         * c = create
         * r = read
         * u = update
         * d = delete
         * n = null
         * */

        $res = [
            'res' => '',
            'code' => ''
        ];

        $cookie = json_decode($request->cookie('userInfo'), true);
        $userInfos = UserInfo::where('email', $cookie['email'])->where('sessionId', $cookie['sessionId'])->get();

        if (count($userInfos) > 0) {

            $userInfo = $userInfos[0];

            if (strcmp($dbOpState, "n") == 0) {

                $res['code'] = 200;
                $res['msg'] = 'Authentication successful.';
                $res['userInfo'] = $userInfo;

            } else if (strcmp($dbOpState, "r") == 0) {

                $res['code'] = 200;
                $res['msg'] = 'Authentication successful.';
                $res['userInfo'] = $userInfo;

            } else if (strcmp($dbOpState, "u") == 0) {

                $res['code'] = 200;
                $res['msg'] = 'Authentication successful.';
                $res['userInfo'] = $userInfo;

            } else if (strcmp($dbOpState, "c") == 0) {

                $res['code'] = 200;
                $res['msg'] = 'Authentication successful.';
                $res['userInfo'] = $userInfo;

            } else {

                $res['code'] = 200;
                $res['msg'] = 'Authentication successful.';
                $res['userInfo'] = $userInfo;

            }

        } else {

            $res['code'] = 404;
            $res['msg'] = 'Authentication unsuccessful.';

        }

        return $res;

    }

}

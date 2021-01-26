<?php

namespace App\Http\Middleware;

use App\Utilities\Auth;
use Closure;

class UserInfoMlr
{
    /**
     * Handle an incoming request.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Closure $next
     * @return mixed
     */
    public function handle($request, Closure $next, $check)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        if (strcmp($check, 'registration') == 0) {

            $userInfo = $request->userInfo;

            if (is_null($userInfo['email']) || empty($userInfo['email'])) {

                $res['msg'] = "User mail required!";
                $res['code'] = 404;
                return response()->json($res, 200);

            } else if (is_null($userInfo['password']) || empty($userInfo['password'])) {

                $res['msg'] = "User password required!";
                $res['code'] = 404;
                return response()->json($res, 200);

            } else {

                return $next($request);

            }

        } else {

            return $next($request);

        }
    }
}

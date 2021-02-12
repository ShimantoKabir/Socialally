<?php

namespace App\Repository;

use Exception;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NotificationRpo
{

    public function readByQuery(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            if (!$request->has('type')) {
                $res['code'] = 404;
                $res['msg'] = "Type query required!";
            } else if (!$request->has('user-info-id')) {
                $res['code'] = 404;
                $res['msg'] = "User info id required!";
            } else if (!$request->has('per-page')) {
                $res['code'] = 404;
                $res['msg'] = "Per page required!";
            } else if (!$request->has('page-index')) {
                $res['code'] = 404;
                $res['msg'] = "Page index required!";
            } else {

                $type = $request->query('type');
                $userInfoId = $request->query('user-info-id');
                $perPage = $request->query('per-page');
                $pageIndex = $request->query('page-index');

                $sql = "SELECT 
                            Notifications.*, 
                            IFNULL(
                                UserInfos.firstName, UserInfos.email
                            ) AS senderName 
                        FROM 
                            Notifications 
                            JOIN UserInfos ON UserInfos.id = Notifications.senderId 
                        WHERE 
                            Notifications.receiverId = " . $userInfoId . "
                            AND Notifications.type = " . $type . "
                        ORDER BY Notifications.id DESC " . "
                        LIMIT " . $pageIndex . ", " . $perPage;

                // $res['sql'] = $sql;
                $res["notifications"] = DB::select(DB::raw($sql));
                $res['code'] = 200;
                $res['msg'] = "Notification fetched successfully!";
            }
        } catch (Exception $e) {
            $res['msg'] = $e->getMessage();
            $res['code'] = 404;
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function update(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rNotification = $request->notification;
        DB::beginTransaction();
        try {

            Notification::where("id", $rNotification['id'])
                ->update(array(
                    "isSeen" => true
                ));

            $res['msg'] = "Notification seen successfully!";
            $res['code'] = 200;

            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = 200;
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }
}

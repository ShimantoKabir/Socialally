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

                $sqlMiddle = "SELECT 
                            n.*, 
                            IFNULL(
                                u.firstName, u.email
                            ) AS senderName 
                        FROM 
                            Notifications AS n
                            JOIN UserInfos AS u ON u.id = n.senderId 
                        WHERE 
                            n.receiverId = " . $userInfoId . "
                            AND n.type = " . $type;

                $sqlAll = " UNION SELECT a.*, 'Admin' AS senderName FROM Notifications AS a WHERE a.isForAll = 1 ";

                $sqlEnd = " ORDER BY n.id DESC " . "
                        LIMIT " . $pageIndex . ", " . $perPage;

                if ($type == 2) { // for admin
                    $sql = $sqlMiddle . $sqlEnd;
                } else { // for client 
                    $sql = "SELECT * FROM (" . $sqlMiddle . $sqlAll . " ) n " . $sqlEnd;
                };

                $res['sql'] = $sql;
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

    public function create(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rNotification = $request->notification;
        DB::beginTransaction();
        try {

            $notification = new Notification();

            if ($rNotification["isForAll"] == 1) {
                $notification->message = $rNotification["message"];
                $notification->receiverId = 0;
                $notification->senderId = 0;
                $notification->isSeen = 1;
                $notification->isForAll = 1;
                $notification->type = 0;
            } else {
                $notification->message = $rNotification["message"];
                $notification->receiverId = $rNotification['receiverId'];
                $notification->senderId = 2;
                $notification->isSeen = 0;
                $notification->isForAll = 0;
                $notification->type = 1;
            }

            $notification->save();

            $res['msg'] = "Notification sent successfully!";
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

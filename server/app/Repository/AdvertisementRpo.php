<?php

namespace App\Repository;

use Exception;
use App\Models\Project;
use Faker\Provider\Uuid;
use App\Models\Transaction;
use App\Models\Notification;
use Illuminate\Http\Request;
use App\Models\Advertisement;
use App\Utilities\FileUploader;
use Illuminate\Support\Facades\DB;

class AdvertisementRpo
{

    public function create(Request $request)
    {

        date_default_timezone_set('Asia/Dhaka');

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rAdvertisement = $request->advertisement;
        $appUrl = env('APP_URL');

        DB::beginTransaction();
        try {

            $rTransaction = [
                "accountHolderId" => $rAdvertisement['givenBy'],
                "debitAmount" => $rAdvertisement['adCost'],
                "creditAmount" => null,
                "ledgerId" => 105,
                "status" => "Approved",
                "transactionId" => null,
                "accountNumber" => null,
                "paymentGatewayName" => null
            ];

            $balance = TransactionRpo::getBalance($rTransaction);

            if ($rTransaction['debitAmount'] < $balance) {

                $advertisement = new Advertisement();
                $advertisement->title = $rAdvertisement["title"];
                $advertisement->targetedDestinationUrl = $rAdvertisement["targetedDestinationUrl"];
                $advertisement->adCost = $rAdvertisement["adCost"];
                $advertisement->adDuration = $rAdvertisement["adDuration"];
                $advertisement->givenBy = $rAdvertisement["givenBy"];
                $advertisement->save();

                $adminNotification = [
                    "message" =>  "Advertisement approver request. Duration " . $rAdvertisement["adDuration"] . " Days and Cost " . $rAdvertisement["adCost"] . " GBP",
                    "receiverId" => 2,
                    "senderId" => $rAdvertisement['givenBy'],
                    "isSeen" => 0,
                    "type" => 2
                ];

                Notification::create($adminNotification);

                if (!is_null($rAdvertisement['bannerImageString'])) {
                    $imageName = Uuid::uuid() . "." . $rAdvertisement['bannerImageExt'];
                    $data = [
                        "fileString" => $rAdvertisement['bannerImageString'],
                        "id" => $advertisement->id,
                        "appUrl" => $appUrl,
                        "fileName" => $imageName,
                        "type" => "img",
                        "tableName" => "Advertisements",
                        "columnName" => "bannerImageUrl"
                    ];
                    FileUploader::upload($data);
                }
                $res["msg"] = "Advertisement successful!";
                $res["code"] = 200;
            } else {
                $res['code'] = 404;
                $res['msg'] = "Your advertisement cost cross the balance!";
            }

            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function readByQuery(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            $perPage = 0;
            $pageIndex = 0;

            if (!$request->has('per-page')) {
                $res['code'] = 404;
                $res['msg'] = "Per page required!";
            } else if (!$request->has('page-index')) {
                $res['code'] = 404;
                $res['msg'] = "Page index required!";
            } else if (!$request->has('type')) {
                $res['code'] = 404;
                $res['msg'] = "Type required!";
            } else {

                $perPage = $request->query('per-page');
                $pageIndex = $request->query('page-index');
                $type = $request->query('type');

                $sql = "SELECT * FROM Advertisements ";

                if ($type == 1) {

                    $sql =  $sql . "WHERE 
                            (
                                NOW() BETWEEN approvedOrDeclinedDate 
                                AND DATE_ADD(
                                    approvedOrDeclinedDate, INTERVAL adDuration DAY
                                )
                            ) 
                            AND status = 'Approved' ORDER BY id DESC ";
                } else if ($type == 2) {

                    $givenBy = $request->query('given-by');
                    $sql = $sql . " WHERE givenBy = " . $givenBy;
                } else {

                    $sql = $sql . " WHERE status = 'Pending' ";
                }

                if ($type != 1) {
                    $sql = $sql . " ORDER BY id DESC LIMIT " . $pageIndex . ", " . $perPage;
                }

                $res["advertisements"] = DB::select(DB::raw($sql));
                $res['msg'] = "Advertisement fetched successfully!";
                $res['code'] = 200;
                $res["sql"] = $sql;
            }
        } catch (Exception $e) {
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function update(Request $request)
    {

        date_default_timezone_set('Asia/Dhaka');

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rAdvertisement = $request->advertisement;
        try {

            if ($rAdvertisement['status'] == "Approved") {

                $ad = Advertisement::where("id", $rAdvertisement['id'])->first();

                $rTransaction = [
                    "accountHolderId" => $ad['givenBy'],
                    "debitAmount" => $ad['adCost'],
                    "creditAmount" => null,
                    "ledgerId" => 105,
                    "status" => "Approved",
                    "transactionId" => null,
                    "accountNumber" => null,
                    "paymentGatewayName" => null
                ];

                TransactionRpo::saveTransaction($rTransaction);


                $clientNotification = [
                    "message" => "Your advertisement has been approved. Your account has been debited " . $ad['adCost'] . " GBP.",
                    "receiverId" => $ad['givenBy'],
                    "senderId" => 2,
                    "isSeen" => 0,
                    "type" => 1
                ];

                Notification::create($clientNotification);
            }

            Advertisement::where("id", $rAdvertisement['id'])
                ->update([
                    "status" => $rAdvertisement['status'],
                    "approvedOrDeclinedDate" => date('Y-m-d H:i:s')
                ]);

            $res["msg"] = "Status updated successfully!";
            $res["code"] = 200;
        } catch (Exception $e) {
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }


        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }
}

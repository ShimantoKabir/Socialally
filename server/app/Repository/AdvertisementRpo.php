<?php

namespace App\Repository;

use Exception;
use App\Models\Project;
use Faker\Provider\Uuid;
use Illuminate\Http\Request;
use App\Models\Advertisement;
use App\Models\Transaction;
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

                TransactionRpo::saveTransaction($rTransaction);

                $advertisement = new Advertisement();
                $advertisement->title = $rAdvertisement["title"];
                $advertisement->targetedDestinationUrl = $rAdvertisement["targetedDestinationUrl"];
                $advertisement->adCost = $rAdvertisement["adCost"];
                $advertisement->adDuration = $rAdvertisement["adDuration"];
                $advertisement->givenBy = $rAdvertisement["givenBy"];
                $advertisement->save();

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

                $sql = "SELECT * FROM Advertisements";

                if ($type == 1) {

                    $sql = $sql . " WHERE status = 'Approved' ";
                } else if ($type == 2) {

                    $givenBy = $request->query('given-by');
                    $sql = $sql . " WHERE givenBy = " . $givenBy;
                } else {

                    $sql = $sql . " WHERE status = 'Pending' ";
                }

                $sql = $sql . " ORDER BY id DESC LIMIT " . $pageIndex . ", " . $perPage;

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

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $advertisement = $request->advertisement;
        try {

            Advertisement::where("id", $advertisement['id'])
                ->update([
                    "status" => $advertisement['status']
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

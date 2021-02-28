<?php

namespace App\Repository;

use Exception;
use App\Models\Project;
use Faker\Provider\Uuid;
use App\Models\Notification;
use Illuminate\Http\Request;
use App\Models\ProofSubmission;
use Illuminate\Support\Facades\DB;
use App\Utilities\CommissionManager;
use Illuminate\Support\Facades\Storage;

class ProofSubmissionRpo
{

    public function create(Request $request)
    {

        $res = [
            "code" => "",
            "msg" => ""
        ];

        $rProofSubmission = $request->proofSubmission;
        $appUrl = env('APP_URL');

        DB::beginTransaction();
        try {

            $givenScreenshotUrls = array();
            foreach (json_decode($rProofSubmission["givenScreenshots"]) as $key => $val) {
                $imageName = Uuid::uuid() . "." . $val->imageExt;
                $givenScreenshotUrl = self::uploadFileToFtp(
                    $val->imageString,
                    $appUrl,
                    $imageName,
                    "img"
                );
                array_push($givenScreenshotUrls, $givenScreenshotUrl);
            }

            $proofSubmission = new ProofSubmission();
            $proofSubmission->projectId = $rProofSubmission["projectId"];
            $proofSubmission->submittedBy = $rProofSubmission["submittedBy"];
            $proofSubmission->givenProofs = $rProofSubmission["givenProofs"];
            $proofSubmission->givenScreenshotUrls = $givenScreenshotUrls;
            $proofSubmission->givenScreenshotUrls = $givenScreenshotUrls;
            $proofSubmission->save();

            Notification::create([
                "message" => $rProofSubmission["applicantName"] . " has applied to your posted job!",
                "receiverId" => $rProofSubmission["publishedBy"],
                "senderId" => $rProofSubmission["submittedBy"],
                "isSeen" => 0,
                "type" => 1
            ]);

            DB::commit();
            $res['code'] = 200;
            $res['msg'] = "Proof submitted successfully!";
        } catch (Exception $e) {
            DB::rollback();
            $res['code'] = $e->getCode();
            $res['msg'] = $e->getMessage();
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function update(Request $request)
    {

        $res = [
            "code" => "",
            "msg" => ""
        ];

        $rProofSubmission = $request->proofSubmission;

        DB::beginTransaction();
        try {

            ProofSubmission::where('id', $rProofSubmission['id'])->update(array(
                'status' => $rProofSubmission['status'],
            ));

            $project = Project::where("id", $rProofSubmission['projectId'])->first();

            if ($rProofSubmission['status'] == "Approved") {

                $rTransaction = [
                    "creditAmount" => $project['eachWorkerEarn'],
                    "debitAmount" => null,
                    "accountHolderId" => $rProofSubmission["submittedBy"],
                    "ledgerId" => 103,
                    "status" => $rProofSubmission["status"],
                    "transactionId" => null,
                    "accountNumber" => null,
                    "paymentGatewayName" => null,
                ];

                TransactionRpo::saveTransaction($rTransaction);
                $res['commissionInfo'] = CommissionManager::giveCommission($rProofSubmission["submittedBy"], "Earning");
            }

            Notification::create([
                "message" => $rProofSubmission["publisherName"] . " has " . $rProofSubmission['status'] . " your job proof.",
                "receiverId" => $rProofSubmission["submittedBy"],
                "senderId" => $rProofSubmission["publishedBy"],
                "isSeen" => 0,
                "type" => 1
            ]);

            DB::commit();
            $res['code'] = 200;
            $res['msg'] = "Proof submission status updated successfully!";
        } catch (Exception $e) {
            DB::rollback();
            $res['code'] = $e->getCode();
            $res['msg'] = $e->getMessage();
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    private static function uploadFileToFtp($fileString, $appUrl, $fileName, $type)
    {

        if ($type == "img") {
            $filePath = 'images/' . $fileName;
            $fileUrl = $appUrl . $filePath;
            $updateSql = array(
                'imageUrl' => $fileUrl
            );
        } else {
            $filePath = 'files/' . $fileName;
            $fileUrl = $appUrl . $filePath;
            $updateSql = array(
                'fileUrl' => $fileUrl
            );
        }

        Storage::disk('ftp')->put($filePath, base64_decode($fileString));

        return $fileUrl;
    }
}

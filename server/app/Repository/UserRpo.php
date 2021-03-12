<?php

namespace App\Repository;

use Exception;
use App\Jobs\MailSender;
use App\Models\UserInfo;
use Faker\Provider\Uuid;
use App\Models\AppConstant;
use App\Models\Notification;
use Illuminate\Http\Request;
use App\Models\PaymentGateway;
use App\Helpers\TokenGenerator;
use App\Models\ChartOfAccount;
use App\Models\ProjectCategory;
use Illuminate\Support\Facades\DB;
use PHPMailer\PHPMailer\PHPMailer;
use App\Utilities\AppConstantReader;
use App\Utilities\PHPMailSender;
use Illuminate\Foundation\Auth\User;
use Illuminate\Support\Facades\Storage;

class UserRpo
{
    private static function calculateProfileCompletionPercentage($userInfo)
    {

        $profileCompleted = 0;

        if (!is_null($userInfo['email']) && !empty($userInfo['email'])) {
            $profileCompleted = $profileCompleted + 20;
        }

        if (!is_null($userInfo['regionName']) && !empty($userInfo['regionName'])) {
            $profileCompleted = $profileCompleted + 20;
        }

        if (!is_null($userInfo['countryName']) && !empty($userInfo['countryName'])) {
            $profileCompleted = $profileCompleted + 20;
        }

        if (!is_null($userInfo['firstName']) && !empty($userInfo['firstName'])) {
            $profileCompleted = $profileCompleted + 10;
        }

        if (!is_null($userInfo['lastName']) && !empty($userInfo['lastName'])) {
            $profileCompleted = $profileCompleted + 10;
        }

        if (!is_null($userInfo['contactNumber']) && !empty($userInfo['contactNumber'])) {
            $profileCompleted = $profileCompleted + 10;
        }

        if (
            !is_null($userInfo['agreedTermsAndCondition'])
            && !empty($userInfo['agreedTermsAndCondition'])
            && $userInfo['agreedTermsAndCondition'] == 1
        ) {
            $profileCompleted = $profileCompleted + 10;
        }

        return $profileCompleted;
    }

    public function register(Request $request)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        $rUserInfo = $request->userInfo;
        $clientUrl = $request->clientUrl;
        $isUserInfoExist = UserInfo::where('email', $rUserInfo['email'])->exists();

        if ($isUserInfoExist) {

            $res['msg'] = 'A account already been created using the email !';
            $res['code'] = 404;
        } else {

            DB::beginTransaction();

            try {

                $token = TokenGenerator::generate();
                $referId = rand();
                $quantityOfEarnByRefer = AppConstant::where(
                    "appConstantName",
                    "quantityOfEarnByRefer"
                )->first()['appConstantIntegerValue'];

                $userInfo = new UserInfo();
                $userInfo->email = $rUserInfo['email'];
                $userInfo->password = sha1($rUserInfo['password']);
                $userInfo->ip = $request->ip();
                $userInfo->token = $token;
                $userInfo->type = $rUserInfo['type'];
                $userInfo->referId = $referId;
                $userInfo->agreedTermsAndCondition = $rUserInfo['agreedTermsAndCondition'];
                $userInfo->regionName = $rUserInfo['regionName'];
                if ($rUserInfo['referredBy'] != "empty") {
                    $userInfo->referredBy = $rUserInfo['referredBy'];
                }
                $userInfo->quantityOfEarnByRefer = $quantityOfEarnByRefer;
                $userInfo->save();

                self::addUserInfoId($userInfo->id);

                $mailData = array(
                    'email' => $userInfo['email'],
                    'body' => $clientUrl . '/#/email-verification/' . $token
                );

                PHPMailSender::send($mailData);

                // Mail::send("mail.emailVerification", $mailData, function ($message) use ($mailData) {
                //     $message->to($mailData['email'])->subject('Email Verification');
                // });

                // Queue::push(new MailSender($mailData));

                $res['msg'] = "Registration successful, a link has been sent to your email please check and click the link to active your account.";
                // $res['msg'] = "Registration successful!";
                $res['code'] = 200;

                DB::commit();
            } catch (Exception $e) {

                DB::rollback();
                $res['msg'] = $e->getMessage();
                $res['code'] = 404;
            }
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function verifyEmail(Request $request)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        $rUserInfo = $request->userInfo;

        DB::beginTransaction();

        try {

            $isEmailAlreadyVerified = UserInfo::where('isEmailVerified', true)
                ->where('token', $rUserInfo['token'])
                ->exists();

            if ($isEmailAlreadyVerified) {
                $res['msg'] = "Email already verified!";
                $res['code'] = 404;
            } else {

                $isTokenMatch = UserInfo::where('token', $rUserInfo['token'])->exists();

                if ($isTokenMatch) {

                    UserInfo::where('token', $rUserInfo['token'])->update(array(
                        'isEmailVerified' => true
                    ));

                    $res['msg'] = "Email verification successful!";
                    $res['code'] = 200;
                } else {

                    $res['msg'] = "Email verification id didn't match!";
                    $res['code'] = 404;
                }
            }

            DB::commit();
        } catch (Exception $e) {

            DB::rollback();
            $res['msg'] = $e->getMessage();
            $res['code'] = 404;
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function login(Request $request)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        $rUserInfo = $request->userInfo;

        DB::beginTransaction();
        try {

            $isUserExists = UserInfo::where('email', $rUserInfo['email'])
                ->where('password', sha1($rUserInfo['password']))
                ->exists();

            if ($isUserExists) {

                $isEmailVerified = UserInfo::where('email', $rUserInfo['email'])
                    ->where('isEmailVerified', true)
                    ->exists();

                if ($isEmailVerified) {

                    $userInfo = UserInfo::where('email', $rUserInfo['email'])
                        ->where('password', sha1($rUserInfo['password']))
                        ->select(
                            'id',
                            'email',
                            'firstName',
                            'lastName',
                            'regionName',
                            'countryName',
                            'contactNumber',
                            'agreedTermsAndCondition',
                            'wantNewsLetterNotification',
                            'imageUrl',
                            'referId',
                            'type',
                            'userInfoId',
                            'isActive'
                        )
                        ->first();

                    if ($userInfo['isActive'] == 1) {

                        $referrerLink = env('APP_URL') . "#/user/registration/" . $userInfo['referId'];

                        $appConstants = AppConstantReader::read();

                        $res['userInfo'] = [
                            'id' => $userInfo['id'],
                            'email' => $userInfo['email'],
                            'firstName' => $userInfo['firstName'],
                            'lastName' => $userInfo['lastName'],
                            'regionName' => $userInfo['regionName'],
                            'countryName' => $userInfo['countryName'],
                            'contactNumber' => $userInfo['contactNumber'],
                            'referId' => $userInfo['referId'],
                            'referrerLink' => $referrerLink,
                            'agreedTermsAndCondition' => $userInfo['agreedTermsAndCondition'],
                            'wantNewsLetterNotification' => $userInfo['wantNewsLetterNotification'],
                            'imageUrl' => $userInfo['imageUrl'],
                            'type' => $userInfo['type'],
                            'userInfoId' => $userInfo['userInfoId'],
                            'profileCompleted' => self::calculateProfileCompletionPercentage($userInfo),
                            'paymentGateways' => PaymentGateway::all(),
                            'takePerPound' => $appConstants["takePerPound"],
                            'proofSubmissionStatus' => $appConstants["proofSubmissionStatus"],
                            'adCostPlanList' => $appConstants['adCostPlanList'],
                            "jobPostingCharge" =>  $appConstants['jobPostingCharge'],
                            "supportInfoList" =>  $appConstants['supportInfoList'],
                            "minimumWithdraw" =>  $appConstants['minimumWithdraw'],
                            "minimumDeposit" =>  $appConstants['minimumDeposit'],
                            "clientDashboardHeadline" =>  $appConstants['clientDashboardHeadline'],
                            "quantityOfJoinByYourRefer" => UserInfo::select("id")->where("referredBy", $userInfo['referId'])->count(),
                            "totalUnseenNotification" => Notification::where("receiverId", $userInfo['id'])->where("isSeen", false)->count(),
                            "projectCategories" => ProjectCategory::select('categoryId', 'categoryName')->distinct('categoryId')->get(),
                            "chartOfAccounts" => ChartOfAccount::where("type", 1)->get()
                        ];

                        $res['msg'] = "Login successful!";
                        $res['code'] = 200;
                    } else {

                        $res['msg'] = "Your account has been deactivated!";
                        $res['code'] = 404;
                    }
                } else {
                    $res['msg'] = "Please verify your email address first!";
                    $res['code'] = 404;
                }
            } else {
                $res['msg'] = "Your given credential did not match with any account!";
                $res['code'] = 404;
            }

            DB::commit();
        } catch (Exception $e) {

            DB::rollback();
            $res['msg'] = $e->getMessage();
            $res['code'] = 404;
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function update(Request $request)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        $rUserInfo = $request->userInfo;

        DB::beginTransaction();

        try {

            UserInfo::where('id', $rUserInfo['id'])->update(array(
                'firstName' => $rUserInfo['firstName'],
                'lastName' => $rUserInfo['lastName'],
                'regionName' => $rUserInfo['regionName'],
                'countryName' => $rUserInfo['countryName'],
                'contactNumber' => $rUserInfo['contactNumber'],
                'nationalId' => $rUserInfo['nationalId'],
                'passportId' => $rUserInfo['passportId'],
                'agreedTermsAndCondition' => $rUserInfo['agreedTermsAndCondition'],
                'wantNewsLetterNotification' => $rUserInfo['wantNewsLetterNotification'],
            ));

            $rUserInfo['profileCompleted'] = self::calculateProfileCompletionPercentage($rUserInfo);

            $res['userInfo'] = $rUserInfo;
            $res['msg'] = "Profile updated successfully!";
            $res['code'] = 200;

            DB::commit();
        } catch (Exception $e) {

            DB::rollback();
            $res['msg'] = $e->getMessage();
            $res['code'] = 404;
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function uploadImage(Request $request)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        $rUserInfo = $request->userInfo;
        $imageString = $rUserInfo['imageString'];
        $id = $rUserInfo['id'];
        $fileExt = $rUserInfo['fileExt'];
        $appUrl = env('APP_URL');

        DB::beginTransaction();

        try {

            $userInfo = UserInfo::where('id', $id)->first();
            $imageName = Uuid::uuid() . "." . $fileExt;

            if (is_null($userInfo['imageUrl'])) {

                $imageUrl = self::uploadFileToFtp($imageString, $id, $appUrl, $imageName);
                $res['msg'] = "Image uploaded successfully!";
                $res['code'] = 200;
            } else {

                $imagPath = str_replace($appUrl, "", $userInfo['imageUrl']);
                $isImageExist = Storage::disk("ftp")->exists($imagPath);
                if ($isImageExist) {
                    Storage::disk("ftp")->delete($imagPath);
                    $imageUrl = self::uploadFileToFtp($imageString, $id, $appUrl, $imageName);
                    $res['msg'] = "Image replaced successfully!";
                    $res['code'] = 200;
                } else {
                    $imageUrl = "Image url not found!";
                    $res['msg'] = $imageUrl;
                    $res['code'] = 404;
                }
            }

            $res['userInfo'] = [
                'id' => $id,
                'imageUrl' => $imageUrl
            ];

            DB::commit();
        } catch (Exception $e) {

            DB::rollback();
            $res['msg'] = $e->getMessage();
            $res['code'] = 404;
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    private static function uploadFileToFtp($imageString, $id, $appUrl, $imageName)
    {
        $imagePath = 'images/' . $imageName;
        Storage::disk('ftp')->put($imagePath, base64_decode($imageString));
        $imageUrl = $appUrl . $imagePath;
        UserInfo::where('id', $id)->update(array(
            'imageUrl' => $imageUrl
        ));
        return $imageUrl;
    }

    public function changePassword(Request $request)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        $rUserInfo = $request->userInfo;

        DB::beginTransaction();

        try {


            $isExists = UserInfo::where("id", $rUserInfo['id'])
                ->where("password", sha1($rUserInfo['oldPassword']))->exists();

            if ($isExists) {
                UserInfo::where('id', $rUserInfo['id'])->update(array(
                    'password' => sha1($rUserInfo['newPassword'])
                ));
                $res['msg'] = "Password updated successfully!";
                $res['code'] = 200;
            } else {
                $res['msg'] = "Old password did not match with current password!";
                $res['code'] = 404;
            }

            DB::commit();
        } catch (Exception $e) {

            DB::rollback();
            $res['msg'] = $e->getMessage();
            $res['code'] = 404;
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

            if ($request->has('first-name')) {

                $firstName = $request->has('first-name') ?  $request->query('first-name') : "none";
                $res['userInfos'] = UserInfo::select("id", DB::raw("IFNULL(firstName,email) AS firstName"))
                    ->where(DB::raw("IFNULL(firstName,email)"), 'like', '%' . $firstName . '%')
                    ->get();

                $res['msg'] = "User info fetched successfully!";
                $res['code'] = 200;
            } else {
                $res['msg'] = "First name required!";
                $res['code'] = 404;
            }
        } catch (Exception $e) {
            $res['code'] = 404;
            $res['msg'] = $e->getMessage();
        }

        return $res;
    }

    public function readById(Request $request, $id)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            $res['userInfo'] = UserInfo::select(
                "id",
                "imageUrl",
                "email",
                "firstName",
                "lastName",
                "contactNumber",
                "nationalId",
                "passportId",
                "agreedTermsAndCondition",
                "wantNewsLetterNotification",
                "regionName",
                "countryName",
                "userInfoId"
            )->where('id', $id)->first();

            $res['msg'] = "User info fetched successfully!";
            $res['code'] = 200;
        } catch (Exception $e) {
            $res['code'] = 404;
            $res['msg'] = $e->getMessage();
        }

        return $res;
    }

    public static function addUserInfoId($id)
    {

        $uid = str_pad($id, 8, "0", STR_PAD_LEFT);
        $monthYear = date("m-y");
        $companyCode = "WE";

        $userInfoId = $companyCode . "-" . $monthYear . "-" . $uid;

        UserInfo::where("id", $id)->update([
            "userInfoId" => $userInfoId
        ]);
    }


    public static function changeStatus(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rUserInfo = $request->userInfo;
        DB::beginTransaction();
        try {

            UserInfo::where("id", $rUserInfo["id"])->update([
                "isActive" => $rUserInfo['isActive']
            ]);

            $res['msg'] = "User status change successfully!";
            $res['code'] = 200;

            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = 404;
        }

        return response()->json($res, 200);
    }

    public static function read(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            if (!$request->has('par-page')) {
                $res['msg'] = "Per page required!";
                $res['code'] = 404;
            } else if (!$request->has('page-index')) {
                $res['msg'] = "Page index required!";
                $res['code'] = 404;
            } else if (!$request->has('type')) {
                $res['msg'] = "User type required!";
                $res['code'] = 404;
            } else {

                $perPage = $request->query('par-page');
                $pageIndex = $request->query('page-index');
                $type = $request->query('type');

                $sql = "SELECT 
                            id,
                            IFNULL(email,'N/A') AS email,
                            imageUrl,
                            IFNULL(firstName,'N/A') AS firstName,
                            IFNULL(lastName,'N/A') AS lastName,
                            IFNULL(regionName,'N/A') AS regionName,
                            IFNULL(countryName,'N/A') AS countryName,
                            IF(agreedTermsAndCondition = 1,'Agreed','Disagreed') AS agreedTermsAndCondition,
                            IF(wantNewsLetterNotification = 1,'Yes','No') AS wantNewsLetterNotification,
                            isActive
                        FROM 
                            UserInfos 
                        WHERE 
                            type = " . $type . " 
                        ORDER BY 
                            id DESC 
                        LIMIT 
                            " . $pageIndex . ", " . $perPage;

                $res["userInfos"] = DB::select(DB::raw($sql));

                $res['msg'] = "User info fetched successfully!";
                $res['code'] = 200;
            }
        } catch (Exception $e) {
            $res['code'] = 404;
            $res['msg'] = $e->getMessage();
        }

        return $res;
    }

    public function readByUserInfoId(Request $request)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        $userInfoId = 0;

        if (!$request->has('user-info-id')) {
            $res['code'] = 404;
            $res['msg'] = "User info id required!";
        } else {

            $userInfoId = $request->query('user-info-id');

            try {

                $res['userInfos'] = UserInfo::select("id", "userInfoId")
                    ->where("userInfoId", 'like', '%' . $userInfoId . '%')
                    ->where("type", 1)
                    ->get();

                $res['code'] = 200;
                $res['msg'] = "User info1 fetched successfully!";
            } catch (Exception $e) {
                $res['msg'] = $e->getMessage();
                $res['code'] = 404;
            }
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }
}

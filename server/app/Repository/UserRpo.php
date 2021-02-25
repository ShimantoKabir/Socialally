<?php

namespace App\Repository;

use App\Helpers\TokenGenerator;
use App\Models\ProjectCategory;
use App\Models\UserInfo;
use App\Jobs\MailSender;
use App\Models\AppConstant;
use App\Models\Notification;
use App\Models\PaymentGateway;
use App\Models\Transaction;
use Exception;
use Faker\Provider\Uuid;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Queue;
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
                $referId = TokenGenerator::generate();
                $quantityOfEarnByRefer = AppConstant::where(
                    "appConstantName",
                    "quantityOfEarnByRefer"
                )->first()['appConstantIntegerValue'];

                $userInfo = new UserInfo();
                $userInfo->email = $rUserInfo['email'];
                $userInfo->password = sha1($rUserInfo['password']);
                $userInfo->ip = $request->ip();
                $userInfo->token = $token;
                $userInfo->isEmailVerified = true;
                $userInfo->type = $rUserInfo['type'];
                $userInfo->referId = $referId;
                if ($rUserInfo['referredBy'] != "empty") {
                    $userInfo->referredBy = $rUserInfo['referredBy'];
                }
                $userInfo->quantityOfEarnByRefer = $quantityOfEarnByRefer;
                $userInfo->save();

                // $mailData = array(
                //     'email' => $userInfo['email'],
                //     'verificationLink' => $clientUrl . '/#/email-verification/' . $token
                // );

                // Mail::send("mail.emailVerification", $mailData, function ($message) use ($mailData) {
                //     $message->to($mailData['email'])->subject('Email Verification');
                // });

                // Queue::push(new MailSender($mailData));

                // $res['msg'] = "Registration successful, a link has been sent to your email please check and click the link to active your account.";
                $res['msg'] = "Registration successful!";
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
                        'accountNumber',
                        'referId',
                        'type'
                    )
                    ->first();

                if (!is_null($userInfo)) {

                    $referrerLink = env('APP_URL') . "#/user/registration/" . $userInfo['referId'];

                    $res['userInfo'] = [
                        'id' => $userInfo['id'],
                        'email' => $userInfo['email'],
                        'firstName' => $userInfo['firstName'],
                        'lastName' => $userInfo['lastName'],
                        'regionName' => $userInfo['regionName'],
                        'countryName' => $userInfo['countryName'],
                        'contactNumber' => $userInfo['contactNumber'],
                        'referId' => $userInfo['referId'],
                        'accountNumber' => $userInfo['accountNumber'],
                        'referrerLink' => $referrerLink,
                        'agreedTermsAndCondition' => $userInfo['agreedTermsAndCondition'],
                        'wantNewsLetterNotification' => $userInfo['wantNewsLetterNotification'],
                        'imageUrl' => $userInfo['imageUrl'],
                        'type' => $userInfo['type'],
                        'profileCompleted' => self::calculateProfileCompletionPercentage($userInfo),
                        'paymentGateways' => PaymentGateway::all(),
                        'takePerDollar' => AppConstant::where("appConstantName", "takePerDollar")->first(),
                        'takePerPound' => AppConstant::where("appConstantName", "takePerPound")->first(),
                        'proofSubmissionStatus' => AppConstant::where("appConstantName", "proofSubmissionStatus")->first(),
                        'adCostPlanList' => AppConstant::where("appConstantName", "adCostPlanList")
                            ->first()['appConstantJsonValue'],
                        "totalUnseenNotification" => Notification::where("receiverId", $userInfo['id'])
                            ->where("isSeen", false)->count(),
                        "jobPostingCharge" =>  AppConstant::where("appConstantName", "jobPostingCharge")
                            ->first()['appConstantDoubleValue'],
                        "quantityOfJoinByYourRefer" => UserInfo::select("id")
                            ->where("referredBy", $userInfo['referId'])
                            ->count()
                    ];

                    $res['userInfo']['projectCategories'] = ProjectCategory::select(
                        'categoryId',
                        'categoryName',
                    )->distinct('categoryId')->get();

                    $res['msg'] = "Login successful!";
                    $res['code'] = 200;
                } else {
                    $res['msg'] = "This email and password did not with any account!";
                    $res['code'] = 404;
                }
            } else {
                $res['msg'] = "Please verify your email address first!";
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
                'accountNumber' => $rUserInfo['accountNumber'],
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
}

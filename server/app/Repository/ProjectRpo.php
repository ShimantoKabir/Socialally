<?php


namespace App\Repository;

use Exception;
use App\Models\Project;
use Faker\Provider\Uuid;
use App\Models\AppConstant;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ProjectRpo
{

    public function create(Request $request)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        $rProject = $request->project;
        $rUserInfo = $request->userInfo;
        $appUrl = env('FTP_URL');

        DB::beginTransaction();
        try {

            // 1 = automatic, 0 = manual
            $jobApprovalType = AppConstant::where("appConstantName", "jobApprovalType")->first()["appConstantIntegerValue"];

            if ($jobApprovalType == 0) {

                Notification::create([
                    "message" => "A new job has been posted by " . $rUserInfo["firstName"] . " waiting for approval.",
                    "receiverId" => 2,
                    "senderId" => $rUserInfo['id'],
                    "isSeen" => 0,
                    "type" => 2
                ]);
            }

            $rTransaction = [
                "accountHolderId" => $rUserInfo['id'],
                "debitAmount" => $rProject['estimatedCost'],
                "creditAmount" => null,
                "ledgerId" => 104,
                "status" => "Approved",
                "transactionId" => null,
                "accountNumber" => null,
                "paymentGatewayName" => null
            ];

            $balance = TransactionRpo::getBalance($rTransaction);

            if ($rTransaction['debitAmount'] < $balance) {

                TransactionRpo::saveTransaction($rTransaction);

                $project = new Project();
                $project->title = $rProject['title'];
                $project->todoSteps = $rProject['todoSteps'];
                $project->requiredProofs = $rProject['requiredProofs'];
                $project->categoryId = $rProject['categoryId'];
                $project->subCategoryId = $rProject['subCategoryId'];
                $project->regionName = $rProject['regionName'];
                $project->countryNames = $rProject['countryNames'];
                $project->workerNeeded = $rProject['workerNeeded'];
                $project->requiredScreenShots = $rProject['requiredScreenShots'];
                $project->estimatedDay = $rProject['estimatedDay'];
                $project->estimatedCost = $rProject['estimatedCost'];
                $project->eachWorkerEarn = $rProject['eachWorkerEarn'];
                $project->publishedBy = $rUserInfo['id'];
                if ($jobApprovalType == 1) {
                    $project->status = "Approved";
                }
                $project->save();

                if (!is_null($rProject['imageString']) && !is_null($rProject['imageExt'])) {
                    $imageName = Uuid::uuid() . "." . $rProject['imageExt'];
                    self::uploadFileToFtp($rProject['imageString'], $project->id, $appUrl, $imageName, "img");
                }

                if (!is_null($rProject['fileString']) && !is_null($rProject['fileExt'])) {
                    $fileName = Uuid::uuid() . "." . $rProject['fileExt'];
                    self::uploadFileToFtp($rProject['fileString'], $project->id, $appUrl, $fileName, "file");
                }

                $res['id'] = $project->id;
                $res['msg'] = "Job posted successfully!";
                $res['code'] = 200;
            } else {
                $res['code'] = 404;
                $res['msg'] = "Your job posting cost cross the balance!";
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
            'msg' => '',
            'code' => ''
        ];

        $userInfoId = 0;
        $type = 0;
        $parPage = 10;
        $pageIndex = 10;

        if (!$request->has('type')) {
            $res['code'] = 404;
            $res['msg'] = "Type query required!";
        } else if (!$request->has('user-info-id')) {
            $res['code'] = 404;
            $res['msg'] = "User info id required!";
        } else if (!$request->has('par-page')) {
            $res['code'] = 404;
            $res['msg'] = "Par page required!";
        } else if (!$request->has('page-index')) {
            $res['code'] = 404;
            $res['msg'] = "Page index required!";
        } else {

            $type = $request->query('type');
            $userInfoId = $request->query('user-info-id');
            $parPage = $request->query('par-page');
            $pageIndex = $request->query('page-index');
            $categoryId = $request->has('category-id') ? $request->query('category-id') : null;
            $regionName = $request->has('region-name') ? $request->query('region-name') : "none";
            $sortBy = $request->has('sort-by') ? $request->query('sort-by') : "none";
            $searchText = $request->has('search-text') ? $request->query('search-text') : "none";
            $projectId = $request->has('project-id') ? $request->query('project-id') : 0;

            $sqlBefore = "SELECT
                pf.id AS proofSubmissionId,
                pf.submittedBy,
                pf.givenProofs,
                pf.givenScreenshotUrls,
                pf.status AS pfdStatus,
                ui.firstName AS applicantName,
                p.* 
            from
                ProofSubmissions AS pf JOIN (";

            $sqlAfter = ") AS p ON pf.projectId = p.id JOIN UserInfos AS ui ON ui.id = pf.submittedBy";

            try {

                $sql = "SELECT
                    Projects.id,
                    Projects.title,
                    Projects.todoSteps,
                    Projects.requiredProofs,
                    Projects.requiredScreenShots,
                    Projects.categoryId,
                    dpg.categoryName AS categoryName,
                    Projects.subCategoryId,
                    ProjectCategories.subCategoryName,
                    ProjectCategories.chargeByCategory,
                    Projects.regionName,
                    Projects.imageUrl,
                    Projects.fileUrl,
                    Projects.status,
                    Projects.countryNames,
                    Projects.workerNeeded,
                    Projects.estimatedDay,
                    Projects.eachWorkerEarn,
                    Projects.estimatedCost,
                    Projects.publishedBy,
                    Projects.createdAt,
                    IFNULL(UserInfos.firstName, UserInfos.email) AS publisherName,
                    (
                    SELECT
                        COUNT(*) 
                    FROM
                        ProofSubmissions 
                    WHERE
                        (
                            status = 'Pending' 
                            OR status = 'Approved'
                        )
                        AND ProofSubmissions.projectId = Projects.id 
                    )
                    AS totalApplied,
                    (
                    SELECT
                        status 
                    FROM
                        ProofSubmissions 
                    WHERE
                        ProofSubmissions.projectId = Projects.id 
                        AND ProofSubmissions.submittedBy = $userInfoId
                    )
                    AS pfStatus
                FROM
                    Projects 
                    JOIN
                    (
                        SELECT DISTINCT
                            categoryId,
                            categoryName 
                        FROM
                            ProjectCategories 
                    )
                    AS dpg 
                    ON Projects.categoryId = dpg.categoryId 
                    JOIN
                    ProjectCategories 
                    ON Projects.subCategoryId = ProjectCategories.id 
                    JOIN
                    UserInfos 
                    ON UserInfos.id = Projects.publishedBy 
                WHERE
                    Projects.publishedBy";

                if ($type == 1) { // available job
                    $sql = $sql . " != " . $userInfoId;
                    $sql = $sql . " AND Projects.status = 'Approved' AND Projects.id NOT IN (SELECT projectId FROM ProofSubmissions WHERE submittedBy = " . $userInfoId . ") AND Projects.workerNeeded > (SELECT COUNT(*) FROM ProofSubmissions WHERE (status = 'Pending' OR status = 'Approved') AND ProofSubmissions.projectId = Projects.id) ORDER BY Projects.createdAt DESC ";
                } else if ($type == 2) { // job approve request
                    $sql = $sqlBefore . $sql . " = " . $userInfoId . $sqlAfter;
                    $sql = $sql . " ORDER BY p.createdAt DESC ";
                } else if ($type == 3) { // job published by me
                    $sql = $sql . " = " . $userInfoId;
                    $sql = $sql . " ORDER BY Projects.createdAt DESC ";
                } else if ($type == 4) { // job applied by me
                    $sql = $sql . " != " . $userInfoId;
                    $sql = $sql . " AND Projects.id IN (SELECT projectId FROM ProofSubmissions WHERE submittedBy = " . $userInfoId . ") ORDER BY Projects.createdAt DESC ";
                } else if ($type == 5) { // advertised job
                    $sql = $sql . " != " . $userInfoId;
                    $sql = $sql . " AND NOW() BETWEEN Projects.adPublishDate AND DATE_ADD(Projects.adPublishDate, INTERVAL Projects.adDuration DAY) ORDER BY Projects.createdAt DESC ";
                } else { // applicants
                    $sql = $sqlBefore . $sql . " = " . $userInfoId . $sqlAfter;
                    $sql = $sql . " WHERE p.id = " . $projectId . " ORDER BY p.createdAt DESC ";
                }

                $sql = $sql . " LIMIT " . $pageIndex . ", " . $parPage;

                $filterSql = "SELECT * FROM (" . $sql . ") f WHERE f.id IS NOT NULL ";

                if ($categoryId != "null") {
                    $filterSql = $filterSql . " AND f.categoryId = " . $categoryId;
                }

                if ($regionName != "none") {
                    $filterSql = $filterSql . " AND LOWER(REPLACE(f.regionName,' ','')) = '" . $regionName . "'";
                }

                if ($searchText != "none") {
                    $filterSql = $filterSql . " AND f.title LIKE '%" . $searchText . "%'";
                }

                if ($sortBy != "none") {
                    if ($sortBy == "finishsoon") {
                        $filterSql = $filterSql . " ORDER BY ROUND((f.totalApplied/f.workerNeeded * 100)) DESC ";
                    } else if ($sortBy == "lesspaid") {
                        $filterSql = $filterSql . " ORDER BY f.eachWorkerEarn ASC ";
                    } else if ($sortBy == "mostpaid") {
                        $filterSql = $filterSql . " ORDER BY f.eachWorkerEarn DESC ";
                    }
                }

                $res['projects'] = DB::select(DB::raw($filterSql));
                $res['sql'] = $sql;
                $res['code'] = 200;
                $res['msg'] = "Project fetched successfully!";
            } catch (Exception $e) {
                $res['msg'] = $e->getMessage();
                $res['code'] = 404;
            }
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function read(Request $request)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        DB::beginTransaction();
        try {

            $res['projects'] = Project::paginate(2);
            $res['msg'] = "Job fetched successfully!";
            $res['code'] = 200;

            DB::commit();
        } catch (Exception $e) {

            DB::rollback();
            $res['msg'] = $e->getMessage();
            $res['code'] = 404;
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    private static function uploadFileToFtp($fileString, $id, $appUrl, $fileName, $type)
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
        Project::where('id', $id)->update($updateSql);

        return $fileUrl;
    }

    public function readByTitle(Request $request)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        $userInfoId = 0;
        $type = 0;
        $parPage = 10;
        $pageIndex = 10;

        if (!$request->has('user-info-id')) {
            $res['code'] = 404;
            $res['msg'] = "User id required!";
        } else if (!$request->has('title')) {
            $res['code'] = 404;
            $res['msg'] = "Project title required!";
        } else {

            $title = $request->query('title');
            $userInfoId = $request->query('user-info-id');

            try {

                $res['projects'] = Project::where("title", 'like', '%' . $title . '%')
                    ->where("publishedBy", $userInfoId)->get();

                $res['code'] = 200;
                $res['msg'] = "Project fetched successfully!";
            } catch (Exception $e) {
                $res['msg'] = $e->getMessage();
                $res['code'] = 404;
            }
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function addAdToProject(Request $request)
    {

        date_default_timezone_set('Asia/Dhaka');

        $res = [
            'msg' => '',
            'code' => ''
        ];

        $rProject = $request->project;
        DB::beginTransaction();
        try {

            $rTransaction = [
                "accountHolderId" => $rProject['publishedBy'],
                "debitAmount" => $rProject['adCost'],
                "creditAmount" => null,
                "ledgerId" => 105,
                "status" => "Approved",
                "transactionId" => null,
                "accountNumber" => null,
                "paymentGatewayName" => null
            ];

            $balance = TransactionRpo::getBalance($rTransaction);

            $sql = "SELECT
                    * 
                FROM
                    Projects
                WHERE
                    publishedBy = " . $rProject['publishedBy'] . "
                    AND id = " . $rProject['id'] . "
                    AND NOW() BETWEEN adPublishDate AND DATE_ADD(adPublishDate, INTERVAL adDuration DAY)";

            $runningJobAdvertisements = DB::select(DB::raw($sql));

            if (count($runningJobAdvertisements) > 0) {

                $res['code'] = 404;
                $res['msg'] = "Job already in advertisement period!";
            } else if ($rTransaction['debitAmount'] < $balance) {

                TransactionRpo::saveTransaction($rTransaction);

                Project::where('id', $rProject['id'])->update(array(
                    'adCost' => $rProject['adCost'],
                    'adDuration' => $rProject['adDuration'],
                    'adPublishDate' => date('Y-m-d H:i:s'),
                    'adStatus' => 1
                ));

                $res['code'] = 200;
                $res['msg'] = "Job advertised successfully!";
            } else {

                $res['code'] = 404;
                $res['msg'] = "Your job advertisement cost cross the balance!";
            }

            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = 404;
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

        $rProject = $request->project;
        DB::beginTransaction();
        try {

            $oldProject = Project::where('id', $rProject['id'])->first();

            if ($rProject['estimatedCost'] > $oldProject['estimatedCost']) {

                $newEstimatedCost = $rProject['estimatedCost'] - $oldProject['estimatedCost'];

                $rTransaction = [
                    "accountHolderId" => $oldProject['publishedBy'],
                    "debitAmount" => $newEstimatedCost,
                    "creditAmount" => null,
                    "ledgerId" => 104,
                    "status" => "Approved",
                    "transactionId" => null,
                    "accountNumber" => null,
                    "paymentGatewayName" => null
                ];

                $balance = TransactionRpo::getBalance($rTransaction);

                if ($rTransaction['debitAmount'] < $balance) {

                    Project::where("id", $rProject['id'])
                        ->update(array(
                            "workerNeeded" => $rProject['workerNeeded'],
                            "estimatedCost" => $rProject['estimatedCost'],
                            "eachWorkerEarn" => $rProject['eachWorkerEarn'],
                            "createdAt" => date('Y-m-d H:i:s')
                        ));

                    $msg = "You have successfully increased worker, which cost is " . $newEstimatedCost . " GBP";
                    TransactionRpo::saveTransaction($rTransaction);
                    Notification::create([
                        "message" => $msg,
                        "receiverId" => $oldProject['publishedBy'],
                        "senderId" => 2,
                        "isSeen" => 0,
                        "type" => 1
                    ]);

                    $res['code'] = 200;
                    $res['msg'] = $msg;
                } else {
                    $res['code'] = 404;
                    $res['msg'] = "OOPS! Worker increasing cost cross the balance.";
                }
            } else {
                $res['code'] = 404;
                $res['msg'] = "Please increase you worker more then " . $oldProject['workerNeeded'] . ".";
            }

            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = 200;
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function updateStatus(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rProject = $request->project;
        DB::beginTransaction();
        try {

            Project::where("id", $rProject['id'])
                ->update(array(
                    "status" => $rProject['status'],
                    "approvedOrDeclinedDate" => date('Y-m-d H:i:s')
                ));

            Notification::create([
                "message" => "Your posted job has been " . $rProject['status'],
                "receiverId" => $rProject["publishedBy"],
                "senderId" => 2,
                "isSeen" => 0,
                "type" => 1
            ]);

            $res['data'] = $rProject;
            $res['msg'] = "Job status updated successfully!";
            $res['code'] = 200;

            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = 200;
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function readByStatus(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            if (!$request->has('status')) {
                $res['code'] = 404;
                $res['msg'] = "Status required!";
            } else if (!$request->has('par-page')) {
                $res['code'] = 404;
                $res['msg'] = "Par page required!";
            } else if (!$request->has('page-index')) {
                $res['code'] = 404;
                $res['msg'] = "Page index required!";
            } else {

                $status = $request->query('status');
                $parPage = $request->query('par-page');
                $pageIndex = $request->query('page-index');

                $sql = "SELECT 
                            p.*, 
                            IFNULL(u.firstName, u.email) AS firstName 
                        FROM 
                            Projects AS p 
                            INNER JOIN UserInfos AS u ON u.id = p.publishedBy 
                        WHERE 
                            p.status = '" . $status . "'
                        ORDER BY 
                            id DESC 
                        LIMIT 
                            " . $pageIndex . ", " . $parPage;

                $res['projects'] = DB::select(DB::raw($sql));
                $res['msg'] = "Job fetched successfully!";
                $res['code'] = 200;
            }
        } catch (Exception $e) {

            $res['msg'] = $e->getMessage();
            $res['code'] = 200;
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }
}

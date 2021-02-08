<?php


namespace App\Repository;

use App\Models\Project;
use Faker\Provider\Uuid;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Exception;
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
        $appUrl = env('APP_URL');

        DB::beginTransaction();
        try {

            $project = new Project();
            $project->title = $rProject['title'];
            $project->todoSteps = $rProject['todoSteps'];
            $project->requiredProofs = $rProject['requiredProofs'];
            $project->categoryId = $rProject['categoryId'];
            $project->subCategoryId = $rProject['subCategoryId'];
            $project->regionName = $rProject['regionName'];
            $project->countryName = $rProject['countryName'];
            $project->workerNeeded = $rProject['workerNeeded'];
            $project->requiredScreenShots = $rProject['requiredScreenShots'];
            $project->estimatedDay = $rProject['estimatedDay'];
            $project->estimatedCost = $rProject['estimatedCost'];
            $project->publishedBy = $rUserInfo['id'];
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

            $sqlBefore = "SELECT
                pf.id AS proofSubmissionId,
                pf.submittedBy,
                pf.givenProofs,
                pf.givenScreenshotUrls,
                pf.status AS pfStatus,
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
                    Projects.regionName,
                    Projects.imageUrl,
                    Projects.fileUrl,
                    Projects.countryName,
                    Projects.workerNeeded,
                    Projects.estimatedDay,
                    Projects.estimatedCost,
                    IFNULL(UserInfos.firstName, UserInfos.email) AS publisherName,
                    (
                    SELECT
                        COUNT(*) 
                    FROM
                        ProofSubmissions 
                    WHERE
                        ProofSubmissions.projectId = Projects.id 
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
                    AS status
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

                if ($type == 1) { // job accept published by me
                    $sql = $sql . " != " . $userInfoId;
                    $sql = $sql . " AND Projects.id NOT IN (SELECT projectId FROM ProofSubmissions WHERE submittedBy = " . $userInfoId . ")";
                } else if ($type == 2) { // job approve request
                    $sql = $sqlBefore . $sql . " = " . $userInfoId . $sqlAfter;
                } else if ($type == 3) { // job only published by me
                    $sql = $sql . " = " . $userInfoId;
                } else {
                    $sql = $sql . " != " . $userInfoId;
                    $sql = $sql . " AND Projects.id IN (SELECT projectId FROM ProofSubmissions WHERE submittedBy = " . $userInfoId . ")";
                }

                $sql = $sql . " LIMIT " . $pageIndex . ", " . $parPage;

                $res['projects'] = DB::select(DB::raw($sql));
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
}

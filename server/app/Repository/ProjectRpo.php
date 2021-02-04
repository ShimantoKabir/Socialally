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
            $project->estimatedDay = $rProject['estimatedDay'];
            $project->estimatedCost = $rProject['estimatedCost'];
            $project->postedBy = $rUserInfo['id'];
            $project->save();

            if (!is_null($rProject['imageString']) && !is_null($rProject['imageExt'])) {
                $imageName = Uuid::uuid() . "." . $rProject['imageExt'];
                self::uploadFileToFtp($rProject['imageString'], $project->id, $appUrl, $imageName, "img");
            }

            if(!is_null($rProject['fileString']) && !is_null($rProject['fileExt'])){
               $fileName = Uuid::uuid().".".$rProject['fileExt'];
               self::uploadFileToFtp($rProject['fileString'], $project->id, $appUrl,$fileName,"file");
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

    public function read(Request $request)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        DB::beginTransaction();
        try {

            $res['projects'] = DB::select(DB::raw("SELECT Projects.id,
                   Projects.title,
                   Projects.todoSteps,
                   Projects.requiredProofs,
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
                   Projects.estimatedCost
            FROM Projects
                     JOIN (SELECT distinct categoryId, categoryName from ProjectCategories) AS dpg
                          ON Projects.categoryId = dpg.categoryId
                     JOIN ProjectCategories ON Projects.subCategoryId = ProjectCategories.id"));

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

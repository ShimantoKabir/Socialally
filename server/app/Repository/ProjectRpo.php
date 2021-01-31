<?php


namespace App\Repository;

use App\Models\Project;
use App\Models\UserInfo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Exception;

class ProjectRpo
{

    public function create(Request $request)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        $rProject = $request->project;

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
            $project->save();

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

}

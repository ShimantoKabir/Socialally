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

        return response()->json($res, 200);

    }

    public function read(Request $request)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        DB::beginTransaction();
        try {

            $res['projects'] = DB::select(DB::raw("SELECT projects.id,
                   projects.title,
                   projects.todoSteps,
                   projects.requiredProofs,
                   projects.categoryId,
                   dpg.categoryName AS categoryName,
                   projects.subCategoryId,
                   projectcategories.subCategoryName,
                   projects.regionName,
                   projects.countryName,
                   projects.workerNeeded,
                   projects.estimatedDay,
                   projects.estimatedCost
            FROM projects
                     JOIN (SELECT distinct categoryId, categoryName from projectcategories) AS dpg
                          ON projects.categoryId = dpg.categoryId
                     JOIN projectcategories ON projects.subCategoryId = projectcategories.id"));

            $res['msg'] = "Job fetched successfully!";
            $res['code'] = 200;

            DB::commit();
        } catch (Exception $e) {

            DB::rollback();
            $res['msg'] = $e->getMessage();
            $res['code'] = 404;

        }

        return response()->json($res, 200);

    }

}

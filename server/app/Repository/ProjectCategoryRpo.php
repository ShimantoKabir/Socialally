<?php


namespace App\Repository;

use App\Models\ProjectCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Exception;

class ProjectCategoryRpo
{


    public function readCategory(Request $request)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        DB::beginTransaction();

        try {

            $res['projectCategories'] = ProjectCategory::select(
                'categoryId',
                'categoryName',
            )->distinct('categoryId')->get();

            $res['msg'] = "Category fetched successfully!";
            $res['code'] = 200;

            DB::commit();
        } catch (Exception $e) {

            DB::rollback();
            $res['msg'] = $e->getMessage();
            $res['code'] = 404;
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function getSubCategoriesById($categoryId)
    {

        $res = [
            'msg' => '',
            'code' => ''
        ];

        DB::beginTransaction();

        try {

            $res['projectCategories'] = ProjectCategory::select(
                'id',
                'subCategoryName',
            )->where('categoryId', $categoryId)->get();

            $res['msg'] = "Sub category fetched successfully!";
            $res['code'] = 200;

            DB::commit();
        } catch (Exception $e) {

            DB::rollback();
            $res['msg'] = $e->getMessage();
            $res['code'] = 404;
        }

        return response()->json($res, 200, [], JSON_NUMERIC_CHECK);
    }

    public function deleteCategory(Request $request, $categoryId)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        DB::beginTransaction();
        try {

            $totalProjectCategory = ProjectCategory::where("categoryId", $categoryId)->count();

            if ($totalProjectCategory == 0) {
                $res['msg'] = "No category found by this id!";
                $res['code'] = 404;
            } else if ($totalProjectCategory > 1) {

                $res['msg'] = "You can't delete this category, cause this category has sub category!";
                $res['code'] = 404;
            } else {
                ProjectCategory::where("categoryId", $categoryId)->delete();
                $res['msg'] = "Category deleted successfully!";
                $res['code'] = 200;
            }

            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res["code"] = 404;
        }

        return $res;
    }

    public function createCategory(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rProjectCategory = $request->projectCategory;

        DB::beginTransaction();
        try {

            $maxCategoryId = ProjectCategory::max("categoryId");
            $projectCategory = new ProjectCategory();
            $projectCategory->categoryId = $maxCategoryId + 1;
            $projectCategory->categoryName = $rProjectCategory['categoryName'];
            $projectCategory->save();

            $res['msg'] = "Project category save successfully!";
            $res['code'] = 200;

            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res["code"] = 404;
        }

        return $res;
    }

    public function updateCategory(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rProjectCategory = $request->projectCategory;

        DB::beginTransaction();
        try {

            ProjectCategory::where("categoryId", $rProjectCategory['categoryId'])
                ->update(array(
                    "categoryName" => $rProjectCategory['categoryName']
                ));

            $res['msg'] = "Project category updated successfully!";
            $res['code'] = 200;

            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res["code"] = 404;
        }

        return $res;
    }
}

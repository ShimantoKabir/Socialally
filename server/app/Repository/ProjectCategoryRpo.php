<?php


namespace App\Repository;

use App\Models\ProjectCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Exception;

class ProjectCategoryRpo
{


    public function read(Request $request)
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

    public function getSubCategoriesById(Request $request, $categoryId)
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
            )->where('categoryId',$categoryId)->get();

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
}

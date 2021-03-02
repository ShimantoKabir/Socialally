<?php


namespace App\Http\Controllers;


use App\Repository\ProjectCategoryRpo;
use Illuminate\Http\Request;

class ProjectCategoryCtl extends Controller
{
    private $projectCategoryRpo;

    /**
     * UserInfoCtl constructor.
     */
    public function __construct()
    {
        $this->projectCategoryRpo = new ProjectCategoryRpo();
    }

    public function readCategory(Request $request)
    {

        return $this->projectCategoryRpo->readCategory($request);
    }

    public function deleteCategory(Request $request, $categoryId)
    {

        return $this->projectCategoryRpo->deleteCategory($request, $categoryId);
    }

    public function createCategory(Request $request)
    {

        return $this->projectCategoryRpo->createCategory($request);
    }

    public function updateCategory(Request $request)
    {

        return $this->projectCategoryRpo->updateCategory($request);
    }

    public function getSubCategoriesById(Request $request, $categoryId)
    {

        return $this->projectCategoryRpo->getSubCategoriesById($request, $categoryId);
    }
}

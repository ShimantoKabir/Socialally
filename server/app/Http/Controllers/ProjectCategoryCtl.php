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

    public function getSubCategories(Request $request)
    {

        return $this->projectCategoryRpo->getSubCategories($request);
    }

    public function deleteSubCategory(Request $request, $id)
    {

        return $this->projectCategoryRpo->deleteSubCategory($request, $id);
    }

    public function createSubCategory(Request $request)
    {

        return $this->projectCategoryRpo->createSubCategory($request);
    }

    public function updateSubCategory(Request $request)
    {

        return $this->projectCategoryRpo->updateSubCategory($request);
    }
}

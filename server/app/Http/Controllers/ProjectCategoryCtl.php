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

    public function read(Request $request){

        return $this->projectCategoryRpo->read($request);

    }

    public function getSubCategoriesById(Request $request,$categoryId){

        return $this->projectCategoryRpo->getSubCategoriesById($request,$categoryId);

    }
}

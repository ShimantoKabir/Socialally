<?php

namespace App\Http\Controllers;

use App\Repository\ProjectRpo;
use Illuminate\Http\Request;

class ProjectCtl extends Controller
{

    private $projectRpo;

    /**
     * UserInfoCtl constructor.
     */
    public function __construct()
    {
        $this->projectRpo = new ProjectRpo();
    }

    public function create(Request $request){

        return $this->projectRpo->create($request);

    }

    public function read(Request $request){

        return $this->projectRpo->read($request);

    }

}

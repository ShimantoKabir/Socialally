<?php

namespace App\Http\Controllers;

use App\Repository\ProjectRpo;
use Illuminate\Http\Request;

class ProjectCtl extends Controller
{

    private $projectRpo;

    /**
     * ProjectCtl constructor.
     */
    public function __construct()
    {
        $this->projectRpo = new ProjectRpo();
    }

    public function create(Request $request)
    {
        return $this->projectRpo->create($request);
    }

    public function readByQuery(Request $request)
    {
        return $this->projectRpo->readByQuery($request);
    }

    public function read(Request $request)
    {
        return $this->projectRpo->read($request);
    }

    public function readByTitle(Request $request)
    {
        return $this->projectRpo->readByTitle($request);
    }

    public function addAdToProject(Request $request)
    {
        return $this->projectRpo->addAdToProject($request);
    }
}

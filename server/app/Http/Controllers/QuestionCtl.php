<?php

namespace App\Http\Controllers;

use App\Repository\QuestionRpo;
use Illuminate\Http\Request;

class QuestionCtl extends Controller
{

    private $questionRpo;

    /**
     * ProjectCtl constructor.
     */
    public function __construct()
    {
        $this->questionRpo = new QuestionRpo();
    }

    public function readByTime(Request $request)
    {
        return $this->questionRpo->readByTime($request);
    }

    public function create(Request $request)
    {
        return $this->questionRpo->create($request);
    }

    public function update(Request $request)
    {
        return $this->questionRpo->update($request);
    }

    public function delete(Request $request, $id)
    {
        return $this->questionRpo->delete($request, $id);
    }

    public function readByQuery(Request $request)
    {
        return $this->questionRpo->readByQuery($request);
    }
}

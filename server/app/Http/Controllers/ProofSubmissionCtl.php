<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Repository\ProofSubmissionRpo;
use Illuminate\Http\Request;

class ProofSubmissionCtl extends Controller
{

    private $proofSubmissionRpo;

    /**
     * ProofSubmissionCtl constructor.
     */
    public function __construct()
    {
        $this->proofSubmissionRpo = new ProofSubmissionRpo();
    }

    public function create(Request $request)
    {
        return $this->proofSubmissionRpo->create($request);
    }

    public function update(Request $request)
    {
        return $this->proofSubmissionRpo->update($request);
    }

    public function readPendingAfterDayGone(Request $request)
    {
        return $this->proofSubmissionRpo->readPendingAfterDayGone($request);
    }
}

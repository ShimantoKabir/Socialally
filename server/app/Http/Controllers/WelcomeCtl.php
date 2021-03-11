<?php

namespace App\Http\Controllers;

use App\Repository\WelcomeRpo;
use Illuminate\Http\Request;

class WelcomeCtl extends Controller
{

    private $welcomeRpo;

    /**
     * ProjectCtl constructor.
     */
    public function __construct()
    {
        $this->welcomeRpo = new WelcomeRpo();
    }

    public function read(Request $request)
    {
        return $this->welcomeRpo->read($request);
    }
}

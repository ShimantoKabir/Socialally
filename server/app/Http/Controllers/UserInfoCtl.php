<?php

namespace App\Http\Controllers;

use App\Repository\UserRpo;
use Illuminate\Http\Request;

class UserInfoCtl extends Controller
{

    private $userRpo;

    /**
     * UserInfoCtl constructor.
     */
    public function __construct()
    {
        $this->userRpo = new UserRpo();
    }

    public function register(Request $request)
    {

        return $this->userRpo->register($request);
    }

    public function verifyEmail(Request $request)
    {

        return $this->userRpo->verifyEmail($request);
    }

    public function login(Request $request)
    {

        return $this->userRpo->login($request);
    }

    public function update(Request $request)
    {

        return $this->userRpo->update($request);
    }

    public function uploadImage(Request $request)
    {

        return $this->userRpo->uploadImage($request);
    }

    public function changePassword(Request $request)
    {

        return $this->userRpo->changePassword($request);
    }

    public function readByQuery(Request $request)
    {
        return $this->userRpo->readByQuery($request);
    }

    public function read(Request $request, $id)
    {
        return $this->userRpo->read($request, $id);
    }
}

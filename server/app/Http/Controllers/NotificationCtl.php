<?php

namespace App\Http\Controllers;


use Illuminate\Http\Request;
use App\Repository\NotificationRpo;

class NotificationCtl extends Controller
{

    private $notificationRpo;

    /**
     * UserInfoCtl constructor.
     */
    public function __construct()
    {
        $this->notificationRpo = new NotificationRpo();
    }

    public function readByQuery(Request $request)
    {

        return $this->notificationRpo->readByQuery($request);
    }

    public function update(Request $request)
    {

        return $this->notificationRpo->update($request);
    }


    public function create(Request $request)
    {

        return $this->notificationRpo->create($request);
    }
}

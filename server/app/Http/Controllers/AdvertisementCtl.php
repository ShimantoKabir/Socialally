<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Repository\AdvertisementRpo;

class AdvertisementCtl extends Controller
{

    private $advertisementRpo;

    /**
     * ProjectCtl constructor.
     */
    public function __construct()
    {
        $this->advertisementRpo = new AdvertisementRpo();
    }

    public function create(Request $request)
    {
        return $this->advertisementRpo->create($request);
    }

    public function readByQuery(Request $request)
    {
        return $this->advertisementRpo->readByQuery($request);
    }
}

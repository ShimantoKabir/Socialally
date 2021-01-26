<?php


namespace App\Http\Controllers;


use Illuminate\Http\Request;

class TestCtl extends Controller
{
    public function test(Request $request)
    {
        return [
            'stats'=>'working ....!'
        ];
    }
}

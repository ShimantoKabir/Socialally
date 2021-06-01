<?php


namespace App\Http\Controllers;

use App\Models\ChartOfAccount;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;

class TestCtl extends Controller
{
    public function test(Request $request)
    {

        return [
            'stats' => 'working ....!',
            'chartOfAccounts' => ChartOfAccount::all()
        ];
    }
}

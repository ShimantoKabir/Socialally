<?php


namespace App\Helpers;

use Illuminate\Support\Facades\Hash;

class TokenGenerator
{

    public static function generate(){

        $date = date("Y_m_d_h_i_sa");
        return StringManager::cleanString(Hash::make($date));

    }

}

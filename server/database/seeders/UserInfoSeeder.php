<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;

class UserInfoSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * php artisan db:seed --class=UserInfoSeeder
     * @return void
     */
    public function run()
    {
        $userInfos = [
            [
                "email" => "admin420@mail.com",
                "password" => sha1("Admin420@"),
                "isEmailVerified" => true,
                "type" => 2
            ],
            [
                "email" => "developer420@mail.com",
                "password" => sha1("Developer420@"),
                "isEmailVerified" => true,
                "type" => 2
            ],
            [
                "email" => "sakib420@mail.com",
                "password" => sha1("Sakib420@"),
                "isEmailVerified" => true,
                "type" => 1
            ],
            [
                "email" => "musfiq420@mail.com",
                "password" => sha1("Musfiq420@"),
                "isEmailVerified" => true,
                "type" => 1
            ],
            [
                "email" => "liton420@mail.com",
                "password" => sha1("Liton420@"),
                "isEmailVerified" => true,
                "type" => 1
            ],
            [
                "email" => "tamim420@mail.com",
                "password" => sha1("Tamim420@"),
                "isEmailVerified" => true,
                "type" => 1
            ]
        ];

        // DB::table('UserInfos')->truncate();

        foreach ($userInfos as $key => $val) {

            DB::table('UserInfos')->insert([
                "email" => $val['email'],
                "password" => $val['password'],
                "isEmailVerified" => $val['isEmailVerified'],
                "type" => $val['type']
            ]);
        }
    }
}

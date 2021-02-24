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
                "id" => 1,
                "email" => "workersengineai247@mail.com",
                "password" => sha1("Workersengineai247@"),
                "isEmailVerified" => true,
                "firstName" => "WorkersEngineAi",
                "type" => 2
            ],
            [
                "id" => 2,
                "email" => "admin420@mail.com",
                "password" => sha1("Admin420@"),
                "isEmailVerified" => true,
                "firstName" => "Admin",
                "type" => 2
            ],
            [
                "id" => 3,
                "email" => "developer420@mail.com",
                "password" => sha1("Developer420@"),
                "firstName" => "Developer",
                "isEmailVerified" => true,
                "type" => 2
            ],
            [
                "id" => 4,
                "email" => "sakib420@mail.com",
                "password" => sha1("Sakib420@"),
                "firstName" => "Sakib",
                "isEmailVerified" => true,
                "type" => 1
            ],
            [
                "id" => 5,
                "email" => "musfiq420@mail.com",
                "password" => sha1("Musfiq420@"),
                "firstName" => "Musfiq",
                "isEmailVerified" => true,
                "type" => 1
            ],
            [
                "id" => 6,
                "email" => "liton420@mail.com",
                "password" => sha1("Liton420@"),
                "firstName" => "Liton",
                "isEmailVerified" => true,
                "type" => 1
            ],
            [
                "id" => 7,
                "email" => "tamim420@mail.com",
                "password" => sha1("Tamim420@"),
                "firstName" => "Tamim",
                "isEmailVerified" => true,
                "type" => 1
            ],
            [
                "id" => 8,
                "email" => "rubel420@mail.com",
                "password" => sha1("Rubel420@"),
                "firstName" => "Rubel",
                "isEmailVerified" => true,
                "type" => 1
            ],
            [
                "id" => 9,
                "email" => "sabbir420@mail.com",
                "password" => sha1("Sabbir420@"),
                "firstName" => "Sabbir",
                "isEmailVerified" => true,
                "type" => 1
            ],
            [
                "id" => 10,
                "email" => "mehedi420@mail.com",
                "password" => sha1("Mehedi420@"),
                "firstName" => "Mehedi420",
                "isEmailVerified" => true,
                "type" => 1
            ]
        ];

        DB::table('UserInfos')->truncate();

        foreach ($userInfos as $key => $val) {

            DB::table('UserInfos')->insert([
                "id" => $val['id'],
                "email" => $val['email'],
                "password" => $val['password'],
                "isEmailVerified" => $val['isEmailVerified'],
                "firstName" => $val['firstName'],
                "type" => $val['type']
            ]);
        }
    }
}

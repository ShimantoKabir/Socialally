<?php

namespace Database\Seeders;

use App\Helpers\TokenGenerator;
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
                "quantityOfEarnByRefer" => -1,
                "referId" => TokenGenerator::generate(),
                "type" => 2,
                "userInfoId" => "WE-01-01-00000001"
            ],
            [
                "id" => 2,
                "email" => "admin420@mail.com",
                "password" => sha1("Admin420@"),
                "isEmailVerified" => true,
                "firstName" => "Admin",
                "quantityOfEarnByRefer" => -1,
                "referId" => TokenGenerator::generate(),
                "type" => 2,
                "userInfoId" => "WE-01-01-00000002"
            ],
            [
                "id" => 3,
                "email" => "developer420@mail.com",
                "password" => sha1("Developer420@"),
                "firstName" => "Developer",
                "isEmailVerified" => true,
                "quantityOfEarnByRefer" => -1,
                "referId" => TokenGenerator::generate(),
                "type" => 2,
                "userInfoId" => "WE-01-01-00000003"
            ],
            [
                "id" => 4,
                "email" => "sakib420@mail.com",
                "password" => sha1("Sakib420@"),
                "firstName" => "Sakib",
                "quantityOfEarnByRefer" => -1,
                "referId" => TokenGenerator::generate(),
                "isEmailVerified" => true,
                "type" => 1,
                "userInfoId" => "WE-01-01-00000004"
            ],
            [
                "id" => 5,
                "email" => "musfiq420@mail.com",
                "password" => sha1("Musfiq420@"),
                "firstName" => "Musfiq",
                "isEmailVerified" => true,
                "quantityOfEarnByRefer" => 10,
                "referId" => TokenGenerator::generate(),
                "type" => 1,
                "userInfoId" => "WE-01-01-00000005"
            ],
            [
                "id" => 6,
                "email" => "liton420@mail.com",
                "password" => sha1("Liton420@"),
                "firstName" => "Liton",
                "isEmailVerified" => true,
                "quantityOfEarnByRefer" => 9,
                "referId" => TokenGenerator::generate(),
                "type" => 1,
                "userInfoId" => "WE-01-01-00000006"
            ],
            [
                "id" => 7,
                "email" => "tamim420@mail.com",
                "password" => sha1("Tamim420@"),
                "firstName" => "Tamim",
                "isEmailVerified" => true,
                "quantityOfEarnByRefer" => 8,
                "referId" => TokenGenerator::generate(),
                "type" => 1,
                "userInfoId" => "WE-01-01-00000007"
            ],
            [
                "id" => 8,
                "email" => "rubel420@mail.com",
                "password" => sha1("Rubel420@"),
                "firstName" => "Rubel",
                "isEmailVerified" => true,
                "quantityOfEarnByRefer" => 7,
                "referId" => TokenGenerator::generate(),
                "type" => 1,
                "userInfoId" => "WE-01-01-00000008"
            ],
            [
                "id" => 9,
                "email" => "sabbir420@mail.com",
                "password" => sha1("Sabbir420@"),
                "firstName" => "Sabbir",
                "isEmailVerified" => true,
                "quantityOfEarnByRefer" => 5,
                "referId" => TokenGenerator::generate(),
                "type" => 1,
                "userInfoId" => "WE-01-01-00000009"
            ],
            [
                "id" => 10,
                "email" => "mehedi420@mail.com",
                "password" => sha1("Mehedi420@"),
                "firstName" => "Mehedi",
                "quantityOfEarnByRefer" => 6,
                "referId" => TokenGenerator::generate(),
                "isEmailVerified" => true,
                "type" => 1,
                "userInfoId" => "WE-01-01-00000010"
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
                "referId" => $val['referId'],
                "quantityOfEarnByRefer" => $val['quantityOfEarnByRefer'],
                "type" => $val['type'],
                "userInfoId" => $val['userInfoId']
            ]);
        }
    }
}

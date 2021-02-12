<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;

class NotificationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * php artisan db:seed --class=NotificationSeeder
     * @return void
     */
    public function run()
    {
        $notifications = [
            [
                "message" => "Your account has been created by command line.",
                "receiverId" => 2,
                "senderId" => 1,
                "isSeen" => false,
                "type" => 2
            ],
            [
                "message" => "Your account has been created by command line.",
                "receiverId" => 3,
                "senderId" => 1,
                "isSeen" => false,
                "type" => 2
            ],
            [
                "message" => "Your account has been created by command line.",
                "receiverId" => 4,
                "senderId" => 2,
                "isSeen" => false,
                "type" => 1
            ],
            [
                "message" => "Your account has been created by command line.",
                "receiverId" => 5,
                "senderId" => 2,
                "isSeen" => false,
                "type" => 1
            ],
            [
                "message" => "Your account has been created by command line.",
                "receiverId" => 6,
                "senderId" => 2,
                "isSeen" => false,
                "type" => 1
            ],
            [
                "message" => "Your account has been created by command line.",
                "receiverId" => 7,
                "senderId" => 2,
                "isSeen" => false,
                "type" => 1
            ]
        ];

        DB::table('Notifications')->truncate();

        foreach ($notifications as $key => $val) {

            DB::table('Notifications')->insert([
                "message" => $val['message'],
                "receiverId" => $val['receiverId'],
                "senderId" => $val['senderId'],
                "isSeen" => $val['isSeen'],
                "type" => $val['type']
            ]);
        }
    }
}

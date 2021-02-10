<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;

class AppConstantSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * php artisan db:seed --class=AppConstantSeeder
     * @return void
     */
    public function run()
    {
        $categories = [
            [
                "appConstantName" => "takePerDollar",
                "appConstantStringValue" => null,
                "appConstantJsonValue" => null,
                "appConstantIntegerValue" => 85,
            ],
            [
                "appConstantName" => "proofSubmissionStatus",
                "appConstantStringValue" => null,
                "appConstantJsonValue" => json_encode(["Pending", "Accepted", "Denied"]),
                "appConstantIntegerValue" => null,
            ],
            [
                "appConstantName" => "adCostPlanList",
                "appConstantStringValue" => null,
                "appConstantJsonValue" => json_encode([
                    [
                        "day" => 1,
                        "cost" => 5
                    ],
                    [
                        "day" => 2,
                        "cost" => 10
                    ],
                    [
                        "day" => 3,
                        "cost" => 15
                    ],
                    [
                        "day" => 4,
                        "cost" => 20
                    ]
                ]),
                "appConstantIntegerValue" => null,
            ]
        ];

        DB::table('AppConstants')->truncate();

        foreach ($categories as $key => $val) {

            DB::table('AppConstants')->insert([
                "appConstantName" => $val['appConstantName'],
                "appConstantStringValue" => $val['appConstantStringValue'],
                "appConstantJsonValue" => $val['appConstantJsonValue'],
                "appConstantIntegerValue" => $val['appConstantIntegerValue']
            ]);
        }
    }
}

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
        $appConstants = [
            [
                "appConstantName" => "takePerDollar",
                "appConstantStringValue" => null,
                "appConstantJsonValue" => null,
                "appConstantIntegerValue" => null,
                "appConstantDoubleValue" => 85.0
            ],
            [
                "appConstantName" => "takePerPound",
                "appConstantStringValue" => null,
                "appConstantJsonValue" => null,
                "appConstantIntegerValue" => null,
                "appConstantDoubleValue" => 119.0
            ],
            [
                "appConstantName" => "minimumDeposit",
                "appConstantStringValue" => null,
                "appConstantJsonValue" => null,
                "appConstantIntegerValue" => null,
                "appConstantDoubleValue" => 5.0
            ],
            [
                "appConstantName" => "minimumWithdraw",
                "appConstantStringValue" => null,
                "appConstantJsonValue" => null,
                "appConstantIntegerValue" => null,
                "appConstantDoubleValue" => 5.0
            ],
            [
                "appConstantName" => "proofSubmissionStatus",
                "appConstantStringValue" => null,
                "appConstantJsonValue" => json_encode(["Pending", "Accepted", "Denied"]),
                "appConstantIntegerValue" => null,
                "appConstantDoubleValue" => null
            ],
            [
                "appConstantName" => "jobPostingCharge",
                "appConstantStringValue" => null,
                "appConstantJsonValue" => null,
                "appConstantIntegerValue" => null,
                "appConstantDoubleValue" => 0.1
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
                "appConstantDoubleValue" => null
            ],
            [
                "appConstantName" => "supportInfoList",
                "appConstantStringValue" => null,
                "appConstantJsonValue" => json_encode([
                    [
                        "name" => "Youtube",
                        "address" => "https://www.youtube.com/channel/UCuVshDJklV0TeIDPuw3K7-Q"
                    ],
                    [
                        "name" => "Facebook",
                        "address" => "https://web.facebook.com/WorkersEngine?_rdc=1&_rdr"
                    ],
                    [
                        "name" => "Twitter",
                        "address" => "https://twitter.com/WorkersEngine"
                    ],
                    [
                        "name" => "Email",
                        "address" => "help.workersengine@gmail.com"
                    ],
                    [
                        "name" => "WhatsApp",
                        "address" => "+447456336006"
                    ],
                    [
                        "name" => "AnswerSendMail",
                        "address" => "help.workersengine@gmail.com"
                    ]
                ]),
                "appConstantIntegerValue" => null,
                "appConstantDoubleValue" => null
            ],
            [
                "appConstantName" => "quantityOfEarnByRefer",
                "appConstantStringValue" => null,
                "appConstantJsonValue" => null,
                "appConstantIntegerValue" => 5,
                "appConstantDoubleValue" => null
            ],
            [
                "appConstantName" => "referCommission",
                "appConstantStringValue" => null,
                "appConstantJsonValue" => null,
                "appConstantIntegerValue" => null,
                "appConstantDoubleValue" => 1.5
            ],
            [
                "appConstantName" => "jobApprovalType",
                "appConstantStringValue" => null,
                "appConstantJsonValue" => null,
                "appConstantIntegerValue" => 0, // 1 = automatic, 0 = manual
                "appConstantDoubleValue" => null
            ],
            [
                "appConstantName" => "clientDashboardHeadline",
                "appConstantStringValue" => "This is earning application. You can send job, apply new job, withdraw directly to bkash or Rocket.",
                "appConstantJsonValue" => null,
                "appConstantIntegerValue" => 0,
                "appConstantDoubleValue" => null
            ],
            [
                "appConstantName" => "questionShowingTime",
                "appConstantStringValue" => "11:30 AM",
                "appConstantJsonValue" => null,
                "appConstantIntegerValue" => 0,
                "appConstantDoubleValue" => null
            ],
            [
                "appConstantName" => "withdrawalFee",
                "appConstantStringValue" => null,
                "appConstantJsonValue" => null,
                "appConstantIntegerValue" => null,
                "appConstantDoubleValue" => 1.0
            ]
        ];

        DB::table('AppConstants')->truncate();

        foreach ($appConstants as $key => $val) {

            DB::table('AppConstants')->insert([
                "appConstantName" => $val['appConstantName'],
                "appConstantStringValue" => $val['appConstantStringValue'],
                "appConstantJsonValue" => $val['appConstantJsonValue'],
                "appConstantIntegerValue" => $val['appConstantIntegerValue'],
                "appConstantDoubleValue" => $val['appConstantDoubleValue']
            ]);
        }
    }
}

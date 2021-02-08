<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;

class PaymentGatewaySeeder extends Seeder
{
    /**
     * Run the database seeds.
     * php artisan db:seed --class=PaymentGatewaySeeder
     * @return void
     */
    public function run()
    {
        $categories = [
            [
                "paymentGatewayName" => "Bkash",
                "cashInNumber" => "01751117995",
                "personalNumber" => "01973117995",
                "agentNumber" => "01612117995"
            ],
            [
                "paymentGatewayName" => "Rocket",
                "cashInNumber" => "01751117995",
                "personalNumber" => "01973117995",
                "agentNumber" => "01612117995"
            ],
            [
                "paymentGatewayName" => "Nogod",
                "cashInNumber" => "01751117995",
                "personalNumber" => "01973117995",
                "agentNumber" => "01612117995"
            ]
        ];

        DB::table('PaymentGateways')->truncate();

        foreach ($categories as $key => $val) {

            DB::table('PaymentGateways')->insert([
                "paymentGatewayName" => $val['paymentGatewayName'],
                "cashInNumber" => $val['cashInNumber'],
                "personalNumber" => $val['personalNumber'],
                "agentNumber" => $val['agentNumber']
            ]);
        }
    }
}

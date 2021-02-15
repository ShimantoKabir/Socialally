<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;

class ChartOfAccountSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * php artisan db:seed --class=ChartOfAccountSeeder
     * @return void
     */
    public function run()
    {
        $chartOfAccounts = [
            [
                "ledgerId" => 101,
                "ledgerName" => "Deposit"
            ],
            [
                "ledgerId" => 102,
                "ledgerName" => "Withdraw"
            ],
            [
                "ledgerId" => 103,
                "ledgerName" => "Earning"
            ],
            [
                "ledgerId" => 104,
                "ledgerName" => "Job Posting"
            ]
        ];

        DB::table('ChartOfAccounts')->truncate();

        foreach ($chartOfAccounts as $key => $val) {

            DB::table('ChartOfAccounts')->insert([
                "ledgerId" => $val['ledgerId'],
                "ledgerName" => $val['ledgerName']
            ]);
        }
    }
}

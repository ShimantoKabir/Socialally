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
                "ledgerName" => "Deposit",
                "type" => 1
            ],
            [
                "ledgerId" => 102,
                "ledgerName" => "Withdraw",
                "type" => 2
            ],
            [
                "ledgerId" => 103,
                "ledgerName" => "Earning",
                "type" => 1
            ],
            [
                "ledgerId" => 104,
                "ledgerName" => "Job Posting",
                "type" => 2
            ],
            [
                "ledgerId" => 105,
                "ledgerName" => "Advertisement Cost",
                "type" => 2
            ],
            [
                "ledgerId" => 106,
                "ledgerName" => "Referring Commission",
                "type" => 1
            ],
            [
                "ledgerId" => 107,
                "ledgerName" => "Play And Earn",
                "type" => 1
            ]
        ];

        DB::table('ChartOfAccounts')->truncate();

        foreach ($chartOfAccounts as $key => $val) {

            DB::table('ChartOfAccounts')->insert([
                "ledgerId" => $val['ledgerId'],
                "ledgerName" => $val['ledgerName'],
                "type" => $val['type']
            ]);
        }
    }
}

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class ChartOfAccounts extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('ChartOfAccounts', function (Blueprint $table) {
            $table->id();
            $table->integer('ledgerId');
            $table->string('ledgerName');
            $table->string('ip')->nullable();
            $table->integer('modifiedBy')->nullable();
            $table->timestamp('createdAt')->useCurrent();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists("ChartOfAccounts");
    }
}

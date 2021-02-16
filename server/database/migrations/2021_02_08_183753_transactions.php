<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class Transactions extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('Transactions', function (Blueprint $table) {
            $table->id();
            $table->double('creditAmount')->nullable()->comment("deposit, income, 101");
            $table->double('debitAmount')->nullable()->comment("withdraw, expanse, 102");
            $table->integer('accountHolderId');
            $table->integer('ledgerId');
            $table->string('transactionId')->nullable();
            $table->string('accountNumber')->nullable();
            $table->string('paymentGatewayName')->nullable();
            $table->string('status')->default("Pending")->comment("Pending, Approved, Declined");
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
        Schema::dropIfExists("Transactions");
    }
}

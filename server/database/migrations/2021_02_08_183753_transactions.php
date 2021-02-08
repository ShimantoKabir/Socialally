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
            $table->integer('depositAmount')->nullable();
            $table->integer('withdrawAmount')->nullable();
            $table->integer('accountHolderId');
            $table->string('transactionType');
            $table->string('transactionId')->nullable();
            $table->string('accountNumber');
            $table->string('paymentGatewayName');
            $table->string('status')->default("Pending")->comment("Pending, Accepted, Declined");
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

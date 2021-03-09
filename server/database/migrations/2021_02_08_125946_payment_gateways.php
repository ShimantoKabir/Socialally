<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class PaymentGateways extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('PaymentGateways', function (Blueprint $table) {
            $table->id();
            $table->string('paymentGatewayName');
            $table->string('cashInNumber')->nullable();
            $table->string('personalNumber')->nullable();
            $table->string('agentNumber')->nullable();
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
        Schema::dropIfExists("PaymentGateways");
    }
}

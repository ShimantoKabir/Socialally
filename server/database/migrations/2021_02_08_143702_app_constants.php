<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AppConstants extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('AppConstants', function (Blueprint $table) {
            $table->id();
            $table->string('appConstantName');
            $table->string('appConstantStringValue')->nullable();
            $table->integer('appConstantIntegerValue')->nullable();
            $table->json('appConstantJsonValue')->nullable();
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
        Schema::dropIfExists("AppConstants");
    }
}

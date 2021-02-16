<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class Advertisements extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('Advertisements', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('targetedDestinationUrl')->nullable();
            $table->string('bannerImageUrl')->nullable();
            $table->double('adCost');
            $table->integer('adDuration');
            $table->integer('givenBy');
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
        Schema::dropIfExists("Advertisements");
    }
}

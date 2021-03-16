<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class Projects extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('Projects', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->json('todoSteps');
            $table->json('requiredProofs');
            $table->integer('categoryId');
            $table->integer('subCategoryId');
            $table->string('regionName');
            $table->json('countryNames');
            $table->integer('workerNeeded');
            $table->integer('requiredScreenShots')->nullable();
            $table->integer('estimatedDay');
            $table->double('estimatedCost');
            $table->double('eachWorkerEarn');
            $table->string('fileUrl')->nullable();
            $table->string('imageUrl')->nullable();
            $table->integer('publishedBy');
            $table->integer('adCost')->nullable();
            $table->integer('adDuration')->nullable();
            $table->dateTime("adPublishDate")->nullable();
            $table->dateTime('approvedOrDeclinedDate')->nullable();
            $table->tinyInteger("adStatus")->default(2)->comment("2 = this job is not advertised, 1 = this job is advertised");
            $table->string("status")->default("Pending")->comment("Pending, Approved, Declined");
            $table->string('ip')->nullable();
            $table->boolean('isFinished')->default(false);
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
        Schema::dropIfExists('Projects');
    }
}

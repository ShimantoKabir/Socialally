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
            $table->string('countryName');
            $table->integer('workerNeeded');
			$table->integer('requiredScreenShots')->nullable();
            $table->integer('estimatedDay');
            $table->integer('estimatedCost');
            $table->string('fileUrl')->nullable();
            $table->string('imageUrl')->nullable();
            $table->integer('postedBy');
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

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class ProjectCategories extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('ProjectCategories', function (Blueprint $table) {
            $table->id();
            $table->integer('categoryId');
            $table->string('categoryName');
            $table->string('subCategoryName')->nullable();
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
        Schema::dropIfExists('ProjectCategories');
    }
}

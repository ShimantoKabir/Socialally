<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class ProofSubmissions extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('ProofSubmissions', function (Blueprint $table) {
            $table->id();
            $table->integer('projectId');
            $table->integer('submittedBy');
            $table->json('givenProofs');
            $table->json("givenScreenshotUrls");
            $table->string("status")->default("applied")->comment("Applied, Accepted, Denied");
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
        Schema::dropIfExists("ProofSubmissions");
    }
}

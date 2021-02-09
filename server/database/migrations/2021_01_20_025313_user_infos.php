<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class UserInfos extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('UserInfos', function (Blueprint $table) {
            $table->id();
            $table->string('token')->nullable();
            $table->string('email');
            $table->string('password');
            $table->string("imageUrl")->nullable();
            $table->string('lastName')->nullable();
            $table->string('regionName')->nullable();
            $table->string('firstName')->nullable();
            $table->string('countryName')->nullable();
            $table->string('contactNumber')->nullable();
            $table->boolean('isEmailVerified')->default(false);
            $table->boolean('agreedTermsAndCondition')->default(false);
            $table->boolean('wantNewsLetterNotification')->default(false);
            $table->integer("postedBy")->nullable();
            $table->tinyInteger("type")->comment("1 = user, 2 = admin");
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
        Schema::dropIfExists('UserInfos');
    }
}

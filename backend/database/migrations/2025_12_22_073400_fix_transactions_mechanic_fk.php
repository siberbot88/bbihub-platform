<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Drop the incorrect foreign key constraint
        Schema::table('transactions', function (Blueprint $table) {
            $table->dropForeign(['mechanic_uuid']);
        });

        // Add correct foreign key constraint (employments instead of users)
        Schema::table('transactions', function (Blueprint $table) {
            $table->foreign('mechanic_uuid')->references('id')->on('employments')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->dropForeign(['mechanic_uuid']);
        });

        Schema::table('transactions', function (Blueprint $table) {
            $table->foreign('mechanic_uuid')->references('id')->on('users')->onDelete('cascade');
        });
    }
};

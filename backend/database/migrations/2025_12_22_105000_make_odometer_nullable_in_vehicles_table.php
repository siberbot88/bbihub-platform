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
        Schema::table('vehicles', function (Blueprint $table) {
            $table->string('odometer')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('vehicles', function (Blueprint $table) {
            // Revert to non-nullable (careful if nulls exist)
            // For safety in down, we usually don't strictly revert if data might be lost/invalid, 
            // but here we can try reverting to string
            $table->string('odometer')->nullable(false)->change();
        });
    }
};

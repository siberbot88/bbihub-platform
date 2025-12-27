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
        Schema::table('service_logs', function (Blueprint $table) {
            // Drop foreign key first
            $table->dropForeign(['transaction_uuid']);

            // Make transaction_uuid nullable
            $table->foreignUuid('transaction_uuid')->nullable()->change()->constrained('transactions');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('service_logs', function (Blueprint $table) {
            $table->dropForeign(['transaction_uuid']);
            $table->foreignUuid('transaction_uuid')->change()->constrained('transactions');
        });
    }
};

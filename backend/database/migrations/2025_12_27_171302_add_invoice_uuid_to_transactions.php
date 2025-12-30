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
        // Add invoice_uuid to transactions untuk link invoice ke payment
        Schema::table('transactions', function (Blueprint $table) {
            $table->foreignUuid('invoice_uuid')->nullable()->after('service_uuid')->constrained('invoices');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->dropForeign(['invoice_uuid']);
            $table->dropColumn('invoice_uuid');
        });
    }
};

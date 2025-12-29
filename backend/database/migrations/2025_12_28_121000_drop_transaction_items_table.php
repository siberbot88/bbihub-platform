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
        Schema::dropIfExists('transaction_items');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::create('transaction_items', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('transaction_uuid')->constrained('transactions');
            $table->foreignUuid('service_uuid')->constrained('services');
            $table->string('name');
            $table->string('service_type')->nullable(); // 'jasa' or 'sparepart'
            $table->decimal('price', 15, 2);
            $table->integer('quantity');
            $table->decimal('subtotal', 15, 2);
            $table->timestamps();
        });
    }
};

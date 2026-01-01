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
        Schema::create('workshop_statistics', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('workshop_uuid')->constrained('workshops')->onDelete('cascade');

            $table->enum('period_type', ['monthly', 'yearly']);
            $table->date('period_date'); // First day of the month/year

            $table->decimal('revenue', 15, 2)->default(0);
            $table->integer('jobs_count')->default(0);
            $table->integer('active_employees_count')->default(0);

            $table->json('metadata')->nullable(); // For storing breakdown charts, top mechanics, etc.

            $table->timestamps();

            // Prevent duplicate stats for same period
            $table->unique(['workshop_uuid', 'period_type', 'period_date'], 'workshop_stats_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('workshop_statistics');
    }
};

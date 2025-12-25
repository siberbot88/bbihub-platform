<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     * 
     * Adds performance indexes for admin service management queries.
     */
    public function up(): void
    {
        Schema::table('services', function (Blueprint $table) {
            // Index for scheduling (pending services grouped by date)
            // Covers: WHERE workshop_uuid = X AND acceptance_status = 'pending' ORDER BY scheduled_date
            $table->index(['workshop_uuid', 'acceptance_status', 'scheduled_date'], 'idx_services_scheduling');

            // Index for service logging (in-progress services)
            // Covers: WHERE workshop_uuid = X AND acceptance_status = 'accepted' AND status = 'in progress'
            $table->index(['workshop_uuid', 'acceptance_status', 'status', 'accepted_at'], 'idx_services_logging');

            // Index for completed services
            // Covers: WHERE workshop_uuid = X AND status = 'completed' ORDER BY completed_at DESC
            $table->index(['workshop_uuid', 'status', 'completed_at'], 'idx_services_completed');

            // Index for service type filtering (booking vs on-site)
            $table->index(['workshop_uuid', 'type', 'created_at'], 'idx_services_type');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('services', function (Blueprint $table) {
            $table->dropIndex('idx_services_scheduling');
            $table->dropIndex('idx_services_logging');
            $table->dropIndex('idx_services_completed');
            $table->dropIndex('idx_services_type');
        });
    }
};

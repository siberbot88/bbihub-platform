<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Ubah ENUM status di service_logs untuk include semua possible values
        DB::statement("ALTER TABLE service_logs MODIFY COLUMN status ENUM('pending', 'accepted', 'in_progress', 'completed', 'rejected') DEFAULT 'accepted'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Rollback ke values lama
        DB::statement("ALTER TABLE service_logs MODIFY COLUMN status ENUM('accepted', 'rejected', 'completed') DEFAULT 'accepted'");
    }
};

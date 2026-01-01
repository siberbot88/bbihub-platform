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
        Schema::create('eis_snapshots', function (Blueprint $table) {
            $table->id();
            $table->integer('year')->index();
            $table->integer('month')->nullable()->index(); // For potential monthly snapshots
            $table->string('type')->index(); // 'clv', 'market_gap', 'summary', etc.
            $table->json('data'); // The frozen dataset
            $table->text('description')->nullable();
            $table->timestamp('snapshotted_at');
            $table->timestamps();

            // Ensure unique snapshot per type per period
            $table->unique(['year', 'month', 'type'], 'eis_snapshot_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('eis_snapshots');
    }
};

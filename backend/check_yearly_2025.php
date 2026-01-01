<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Workshop;
use App\Models\WorkshopStatistic;
use Carbon\Carbon;

echo "=== Checking Yearly Aggregations for 2025 ===\n\n";

$workshop = Workshop::first();
if (!$workshop) {
    die("No workshop found\n");
}

echo "Workshop: {$workshop->name}\n";
echo "UUID: {$workshop->id}\n\n";

// Check for yearly stat for 2025
$yearStart = Carbon::parse('2025-01-01');
$stat = WorkshopStatistic::where('workshop_uuid', $workshop->id)
    ->where('period_type', 'yearly')
    ->where('period_date', $yearStart->toDateString())
    ->first();

if ($stat) {
    echo "✅ Yearly stat EXISTS for 2025\n";
    echo "Revenue: Rp " . number_format($stat->total_revenue) . "\n";
    echo "Jobs: " . $stat->jobs_completed . "\n";
    echo "Metadata:\n";
    print_r($stat->metadata);
} else {
    echo "❌ NO yearly stat found for 2025\n";
    echo "Checking if we need to aggregate...\n\n";

    // Check if we have data in 2025
    $transactions = \App\Models\Transaction::where('workshop_uuid', $workshop->id)
        ->where('status', 'success')
        ->whereYear('created_at', 2025)
        ->count();

    echo "Transactions in 2025: $transactions\n";

    if ($transactions > 0) {
        echo "\n⚠️  Data exists but not aggregated!\n";
        echo "Need to run aggregation job for yearly 2025.\n";
    }
}

// Check monthly aggregations for 2025
echo "\n=== Monthly Aggregations in 2025 ===\n";
$monthlyStats = WorkshopStatistic::where('workshop_uuid', $workshop->id)
    ->where('period_type', 'monthly')
    ->whereYear('period_date', 2025)
    ->orderBy('period_date')
    ->get();

if ($monthlyStats->count() > 0) {
    foreach ($monthlyStats as $ms) {
        $date = Carbon::parse($ms->period_date);
        echo "- {$date->format('F Y')}: Rp " . number_format($ms->total_revenue) . " ({$ms->jobs_completed} jobs)\n";
    }
} else {
    echo "No monthly stats found for 2025\n";
}

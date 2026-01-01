<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\User;
use App\Models\Workshop;
use App\Models\WorkshopStatistic;
use Carbon\Carbon;

echo "=== Testing Mobile API Response for 2025 ===\n\n";

// Get owner user
$owner = User::where('role', 'owner')->first();
if (!$owner) {
    die("No owner found\n");
}

echo "Owner: {$owner->name}\n";
echo "Email: {$owner->email}\n";

// Get workshop
$workshop = Workshop::where('user_uuid', $owner->id)->first();
if (!$workshop) {
    die("No workshop found for this owner\n");
}

echo "Workshop: {$workshop->name}\n";
echo "Workshop UUID: {$workshop->id}\n\n";

// Check yearly stat for 2025
$yearStart = Carbon::parse('2025-01-01');
$stat = WorkshopStatistic::where('workshop_uuid', $workshop->id)
    ->where('period_type', 'yearly')
    ->where('period_date', $yearStart->toDateString())
    ->first();

if ($stat) {
    echo "✅ Yearly Stat EXISTS\n";
    echo "Revenue: Rp " . number_format($stat->total_revenue) . "\n";
    echo "Jobs: " . $stat->jobs_completed . "\n";
    echo "\nMetadata monthly_breakdown:\n";
    $meta = $stat->metadata ?? [];
    $monthly = $meta['monthly_breakdown'] ?? [];

    foreach ($monthly as $month => $data) {
        echo "- $month: Rp " . number_format($data['revenue']) . " ({$data['jobs']} jobs)\n";
    }

    echo "\nService Breakdown:\n";
    $services = $meta['service_breakdown'] ?? [];
    foreach ($services as $name => $count) {
        echo "- $name: $count\n";
    }
} else {
    echo "❌ No yearly stat found\n";
}

// Now simulate what AnalyticsController::report would return
echo "\n=== Simulating API Response ===\n";

// The controller should format data like this for mobile
$trendData = [];
$labels = [];
$revenue = [];
$jobs = [];

if ($stat && isset($stat->metadata['monthly_breakdown'])) {
    $monthly = $stat->metadata['monthly_breakdown'];

    // Sort by month
    ksort($monthly);

    foreach ($monthly as $monthKey => $data) {
        $date = Carbon::parse($monthKey . '-01');
        $labels[] = $date->format('M'); // Jan, Feb, etc
        $revenue[] = (float) $data['revenue'];
        $jobs[] = (int) $data['jobs'];
    }
}

echo "Labels: " . json_encode($labels) . "\n";
echo "Revenue: " . json_encode($revenue) . "\n";
echo "Jobs: " . json_encode($jobs) . "\n";

echo "\nExpected trend structure:\n";
$trend = [
    'labels' => $labels,
    'revenue' => $revenue,
    'jobs' => $jobs
];
echo json_encode($trend, JSON_PRETTY_PRINT) . "\n";

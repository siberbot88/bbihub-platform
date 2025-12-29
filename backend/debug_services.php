<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Checking Completed Services ===\n\n";

// Get services with completed_at set
$services = DB::table('services')
    ->select('id', 'code', 'workshop_uuid', 'status', 'scheduled_date', 'completed_at', 'created_at')
    ->whereNotNull('completed_at')
    ->orderBy('completed_at', 'desc')
    ->limit(5)
    ->get();

echo "Found " . $services->count() . " services with completed_at:\n\n";

foreach ($services as $svc) {
    echo "Code: {$svc->code}\n";
    echo "  Status: {$svc->status}\n";
    echo "  Workshop: {$svc->workshop_uuid}\n";
    echo "  Completed At: {$svc->completed_at}\n";
    echo "  Scheduled: {$svc->scheduled_date}\n";
    echo "---\n";
}

// Check date range for "this week"
$now = new DateTime();
$startOfWeek = (clone $now)->modify('Monday this week');
$endOfWeek = (clone $startOfWeek)->modify('+6 days');

echo "\n=== This Week Date Range ===\n";
echo "Start: " . $startOfWeek->format('Y-m-d') . "\n";
echo "End: " . $endOfWeek->format('Y-m-d') . "\n";
echo "Today: " . $now->format('Y-m-d') . "\n\n";

// Check services in this week's range
$thisWeek = DB::table('services')
    ->whereNotNull('completed_at')
    ->whereDate('completed_at', '>=', $startOfWeek->format('Y-m-d'))
    ->whereDate('completed_at', '<=', $endOfWeek->format('Y-m-d'))
    ->count();

echo "Services completed this week: {$thisWeek}\n";

<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Debugging Service History Issue ===\n\n";

// 1. Check services with completed_at
$completedServices = DB::table('services')
    ->whereNotNull('completed_at')
    ->orderBy('completed_at', 'desc')
    ->limit(5)
    ->get(['id', 'code', 'workshop_uuid', 'status', 'scheduled_date', 'completed_at']);

echo "Services with completed_at:\n";
echo "Count: " . $completedServices->count() . "\n\n";

foreach ($completedServices as $svc) {
    echo "Code: {$svc->code}\n";
    echo "  Workshop: {$svc->workshop_uuid}\n";
    echo "  Status: {$svc->status}\n";
    echo "  Completed: {$svc->completed_at}\n";
    echo "---\n";
}

// 2. Check date range for "this week"
$now = new DateTime();
$startOfWeek = (clone $now)->modify('Monday this week');
$endOfWeek = (clone $startOfWeek)->modify('+6 days');

echo "\n=== This Week Range ===\n";
echo "Start: " . $startOfWeek->format('Y-m-d') . " (Monday)\n";
echo "End: " . $endOfWeek->format('Y-m-d') . " (Sunday)\n";
echo "Today: " . $now->format('Y-m-d l') . "\n\n";

// 3. Check services in this week
$thisWeekServices = DB::table('services')
    ->whereNotNull('completed_at')
    ->whereDate('completed_at', '>=', $startOfWeek->format('Y-m-d'))
    ->whereDate('completed_at', '<=', $endOfWeek->format('Y-m-d'))
    ->get(['code', 'workshop_uuid', 'completed_at']);

echo "Services completed this week: " . $thisWeekServices->count() . "\n";
foreach ($thisWeekServices as $s) {
    echo "  - {$s->code} (workshop: {$s->workshop_uuid}, completed: {$s->completed_at})\n";
}

// 4. Get admin employment for workshop UUID
echo "\n=== Admin Workshop Mapping ===\n";
$adminEmployments = DB::table('employments')
    ->join('users', 'employments.user_uuid', '=', 'users.id')
    ->join('model_has_roles', 'users.id', '=', 'model_has_roles.model_uuid')
    ->join('roles', 'model_has_roles.role_id', '=', 'roles.id')
    ->where('roles.name', 'admin')
    ->select('users.id as user_id', 'users.name', 'employments.workshop_uuid')
    ->get();

echo "Admin users and their workshops:\n";
foreach ($adminEmployments as $emp) {
    echo "  - {$emp->name} (user_id: {$emp->user_id}) -> workshop: {$emp->workshop_uuid}\n";
}

echo "\n=== Summary ===\n";
echo "✅ Total services with completed_at: " . $completedServices->count() . "\n";
echo "✅ Services in this week: " . $thisWeekServices->count() . "\n";
echo "✅ Admin employments: " . $adminEmployments->count() . "\n";

// 5. Simulate API query
echo "\n=== Simulated API Query ===\n";
if ($adminEmployments->isNotEmpty()) {
    $firstAdmin = $adminEmployments->first();
    echo "Testing query for admin: {$firstAdmin->name}\n";
    echo "Workshop UUID: {$firstAdmin->workshop_uuid}\n\n";

    $apiResult = DB::table('services')
        ->whereNotNull('completed_at')
        ->where('workshop_uuid', $firstAdmin->workshop_uuid)
        ->whereDate('completed_at', '>=', $startOfWeek->format('Y-m-d'))
        ->whereDate('completed_at', '<=', $endOfWeek->format('Y-m-d'))
        ->get(['code', 'status', 'completed_at']);

    echo "Result count: " . $apiResult->count() . "\n";
    if ($apiResult->isNotEmpty()) {
        echo "Results:\n";
        foreach ($apiResult as $r) {
            echo "  - {$r->code} ({$r->status}) completed at {$r->completed_at}\n";
        }
    } else {
        echo "❌ NO RESULTS - This is the problem!\n";
        echo "Possible causes:\n";
        echo "  1. Workshop UUID mismatch\n";
        echo "  2. completed_at outside date range\n";
        echo "  3. No services for this workshop\n";
    }
}

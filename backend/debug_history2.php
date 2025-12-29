<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Service History Debug ===\n\n";

// 1. Count services with completed_at
$count = DB::table('services')->whereNotNull('completed_at')->count();
echo "Total services with completed_at: {$count}\n\n";

// 2. Get latest completed services
$services = DB::table('services')
    ->whereNotNull('completed_at')
    ->orderBy('completed_at', 'desc')
    ->limit(3)
    ->get(['code', 'workshop_uuid', 'status', 'completed_at']);

echo "Latest completed services:\n";
foreach ($services as $s) {
    echo "  {$s->code} - workshop:{$s->workshop_uuid} - completed:{$s->completed_at}\n";
}

// 3. Date range check
$now = new DateTime('2025-12-29'); // Today
$monday = new DateTime('2025-12-23'); // This week's Monday
$sunday = new DateTime('2025-12-29'); // This week's Sunday

echo "\n=== This Week ===\n";
echo "Range: {$monday->format('Y-m-d')} to {$sunday->format('Y-m-d')}\n\n";

// 4. Query with date range
$weekServices = DB::table('services')
    ->whereNotNull('completed_at')
    ->whereDate('completed_at', '>=', '2025-12-23')
    ->whereDate('completed_at', '<=', '2025-12-29')
    ->get(['code', 'completed_at']);

echo "Services completed this week: " . $weekServices->count() . "\n";
foreach ($weekServices as $ws) {
    echo "  {$ws->code} completed at {$ws->completed_at}\n";
}

// 5. Check admin's workshop
echo "\n=== Checking Admin Workshop ===\n";
$adminUser = DB::table('users')
    ->join('model_has_roles', 'users.id', '=', 'model_has_roles.model_uuid')
    ->join('roles', 'model_has_roles.role_id', '=', 'roles.id')
    ->where('roles.name', 'admin')
    ->where('roles.guard_name', 'sanctum')
    ->select('users.id', 'users.name')
    ->first();

if ($adminUser) {
    echo "Found admin: {$adminUser->name} (ID: {$adminUser->id})\n";

    $employment = DB::table('employments')
        ->where('user_uuid', $adminUser->id)
        ->first();

    if ($employment) {
        echo "Workshop UUID: {$employment->workshop_uuid}\n\n";

        // Test actual query
        $result = DB::table('services')
            ->whereNotNull('completed_at')
            ->where('workshop_uuid', $employment->workshop_uuid)
            ->whereDate('completed_at', '>=', '2025-12-23')
            ->whereDate('completed_at', '<=', '2025-12-29')
            ->get(['code', 'completed_at']);

        echo "Services for this admin's workshop: " . $result->count() . "\n";
        foreach ($result as $r) {
            echo "  {$r->code} - {$r->completed_at}\n";
        }
    } else {
        echo "❌ Admin has no employment record!\n";
    }
} else {
    echo "❌ No admin user found!\n";
}

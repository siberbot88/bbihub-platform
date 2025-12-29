<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== DEEP DIVE: Service History Debug ===\n\n";

// 1. Check if there are ANY services with completed_at
echo "1️⃣ Checking completed services in database...\n";
$completedCount = DB::table('services')->whereNotNull('completed_at')->count();
echo "   Total services with completed_at: {$completedCount}\n\n";

if ($completedCount === 0) {
    echo "❌ NO COMPLETED SERVICES FOUND!\n";
    echo "This is the root cause - no data to show in history.\n\n";

    // Check what services exist
    $totalServices = DB::table('services')->count();
    echo "Total services: {$totalServices}\n";

    $statusBreakdown = DB::table('services')
        ->select('status', DB::raw('count(*) as count'))
        ->groupBy('status')
        ->get();

    echo "\nStatus breakdown:\n";
    foreach ($statusBreakdown as $status) {
        echo "  - {$status->status}: {$status->count}\n";
    }

    exit("\n⚠️ Need to complete some services first!\n");
}

// 2. Get a sample completed service
echo "2️⃣ Sample completed service:\n";
$sample = DB::table('services')
    ->whereNotNull('completed_at')
    ->orderBy('completed_at', 'desc')
    ->first();

echo "   Code: {$sample->code}\n";
echo "   Workshop UUID: {$sample->workshop_uuid}\n";
echo "   Status: {$sample->status}\n";
echo "   Completed At: {$sample->completed_at}\n\n";

// 3. Check admin user and workshop
echo "3️⃣ Checking admin user...\n";
$admin = DB::table('users')
    ->join('model_has_roles', 'users.id', '=', 'model_has_roles.model_uuid')
    ->join('roles', 'model_has_roles.role_id', '=', 'roles.id')
    ->where('roles.name', 'admin')
    ->where('roles.guard_name', 'sanctum')
    ->select('users.id', 'users.name', 'users.username')
    ->first();

if (!$admin) {
    exit("❌ No admin user found!\n");
}

echo "   Admin: {$admin->name} ({$admin->username})\n";

$employment = DB::table('employments')
    ->where('user_uuid', $admin->id)
    ->first();

if (!$employment) {
    exit("❌ Admin has no employment record!\n");
}

echo "   Workshop UUID: {$employment->workshop_uuid}\n\n";

// 4. Check if there's a match
echo "4️⃣ Checking if sample service belongs to admin's workshop...\n";
if ($sample->workshop_uuid === $employment->workshop_uuid) {
    echo "   ✅ MATCH! Service IS in admin's workshop\n\n";
} else {
    echo "   ❌ MISMATCH!\n";
    echo "   Service workshop: {$sample->workshop_uuid}\n";
    echo "   Admin workshop: {$employment->workshop_uuid}\n";
    echo "   This is why history is empty - workshop UUID mismatch!\n\n";
}

// 5. Simulate the actual API query for "this week"
echo "5️⃣ Simulating API query (this week)...\n";
$now = new DateTime();
$monday = (clone $now)->modify('Monday this week');
$sunday = (clone $monday)->modify('+6 days');

echo "   Date range: {$monday->format('Y-m-d')} to {$sunday->format('Y-m-d')}\n";

$query = DB::table('services')
    ->whereNotNull('completed_at')
    ->where('workshop_uuid', $employment->workshop_uuid)
    ->whereDate('completed_at', '>=', $monday->format('Y-m-d'))
    ->whereDate('completed_at', '<=', $sunday->format('Y-m-d'));

$count = $query->count();
echo "   Result count: {$count}\n\n";

if ($count > 0) {
    echo "✅ Query returns data! Issue is in frontend.\n";
    $results = $query->get(['code', 'status', 'completed_at']);
    foreach ($results as $r) {
        echo "     - {$r->code} ({$r->status}) completed at {$r->completed_at}\n";
    }
} else {
    echo "❌ Query returns EMPTY!\n";

    // Check if services exist but outside date range
    $allForWorkshop = DB::table('services')
        ->whereNotNull('completed_at')
        ->where('workshop_uuid', $employment->workshop_uuid)
        ->get(['code', 'completed_at']);

    if ($allForWorkshop->isEmpty()) {
        echo "   No completed services for this workshop at all.\n";
    } else {
        echo "   Completed services for this workshop (all time):\n";
        foreach ($allForWorkshop as $s) {
            echo "     - {$s->code} completed at {$s->completed_at}\n";
        }
        echo "\n   ⚠️ Services exist but are outside 'this week' date range!\n";
    }
}

echo "\n=== END DEBUG ===\n";

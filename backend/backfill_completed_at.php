<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

// Update all 'lunas' services that don't have completed_at
$updated = DB::table('services')
    ->where('status', 'lunas')
    ->whereNull('completed_at')
    ->update(['completed_at' => DB::raw('updated_at')]);

echo "✅ Updated {$updated} services with completed_at timestamp\n";

// Also update 'completed' services
$updated2 = DB::table('services')
    ->where('status', 'completed')
    ->whereNull('completed_at')
    ->update(['completed_at' => DB::raw('updated_at')]);

echo "✅ Updated {$updated2} completed services with completed_at timestamp\n";

echo "\n🎉 Backfill complete!\n";

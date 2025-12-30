<?php

use App\Models\Service;

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);

$kernel->bootstrap();

$services = Service::whereIn('status', ['in_progress', 'on_process', 'waiting_payment', 'accepted'])
    ->orderBy('created_at', 'desc')
    ->limit(10)
    ->get();

echo "Found " . $services->count() . " services with process-like status.\n";

foreach ($services as $s) {
    echo "ID: {$s->id} | Status: {$s->status} | Scheduled: {$s->scheduled_date} | Workshop: {$s->workshop_uuid} | Type: {$s->type}\n";
}

echo "\nChecking API Filter Logic Simulation:\n";
// Simulate the query coming from the controller
$stringStatus = 'in_progress,on_process,accepted,menunggu pembayaran,waiting_payment';
$statuses = explode(',', $stringStatus);
$count = Service::whereIn('status', $statuses)->count();
echo "Querying whereIn(['" . implode("','", $statuses) . "']) found: $count records.\n";

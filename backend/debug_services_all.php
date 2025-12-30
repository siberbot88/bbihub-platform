<?php

use App\Models\Service;

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);

$kernel->bootstrap();

echo "Counts by Status:\n";
$counts = Service::groupBy('status')->selectRaw('status, count(*) as count')->pluck('count', 'status');
print_r($counts);

echo "\nLast 10 Services:\n";
$services = Service::orderBy('created_at', 'desc')->limit(10)->get();
foreach ($services as $s) {
    echo "ID: {$s->id} | Status: '{$s->status}' | Scheduled: {$s->scheduled_date}\n";
}

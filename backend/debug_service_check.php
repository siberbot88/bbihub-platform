<?php

use App\Models\Service;

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$service = Service::whereHas('customer', function ($q) {
    $q->where('name', 'like', '%Mohammad Bayu Rizki%');
})
    ->get(['id', 'status', 'acceptance_status', 'scheduled_date', 'type', 'workshop_uuid']);

echo json_encode($service->toArray(), JSON_PRETTY_PRINT);

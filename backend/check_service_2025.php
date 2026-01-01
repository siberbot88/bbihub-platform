<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Service;
use App\Models\Transaction;

echo "Checking Data for 2025...\n";
$services2025 = Service::whereYear('created_at', 2025)->count();
echo "Total Services 2025: " . $services2025 . "\n";

$transactions2025 = Transaction::whereYear('created_at', 2025)->count();
echo "Total Transactions 2025: " . $transactions2025 . "\n";

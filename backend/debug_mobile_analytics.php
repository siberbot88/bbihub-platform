<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Workshop;
use App\Models\Transaction;

echo "=== Testing Analytics Data for Mobile ===\n\n";

// Get first workshop for testing
$workshop = Workshop::first();
if (!$workshop) {
    die("No workshop found\n");
}

echo "Workshop: {$workshop->name}\n";
echo "UUID: {$workshop->id}\n\n";

// Check transactions
$transactions = Transaction::where('workshop_uuid', $workshop->id)
    ->where('status', 'success')
    ->get();

echo "Total Successful Transactions: " . $transactions->count() . "\n";

if ($transactions->count() > 0) {
    echo "\nSample Transactions:\n";
    foreach ($transactions->take(5) as $tx) {
        echo "- {$tx->created_at->format('Y-m-d')}: Rp " . number_format($tx->amount) . "\n";
    }

    // Group by month
    echo "\nTransactions by Month:\n";
    $byMonth = $transactions->groupBy(function ($tx) {
        return $tx->created_at->format('Y-m');
    });

    foreach ($byMonth as $month => $txs) {
        $total = $txs->sum('amount');
        echo "- $month: " . $txs->count() . " transactions, Rp " . number_format($total) . "\n";
    }
}

// Check services
echo "\n=== Services ===\n";
$services = \App\Models\Service::where('workshop_uuid', $workshop->id)->get();
echo "Total Services: " . $services->count() . "\n";

if ($services->count() > 0) {
    $serviceTypes = $services->groupBy('name');
    echo "\nService Types:\n";
    foreach ($serviceTypes->take(5) as $name => $svcs) {
        echo "- $name: " . $svcs->count() . " times\n";
    }
}

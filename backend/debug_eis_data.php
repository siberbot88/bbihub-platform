<?php

use App\Models\Transaction;
use Illuminate\Support\Facades\DB;

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "--- DEBUG EIS SEGMENTATION DATA ---\n";

// 1. Count Total Success Transactions
$totalSuccess = Transaction::where('status', 'success')->count();
echo "Total 'success' transactions in DB: $totalSuccess\n";

// 2. Count Unique Customers with Success Transactions (The Logic used in EisService)
$uniqueCustomers = Transaction::where('status', 'success')
    ->whereNotNull('customer_uuid')
    ->distinct('customer_uuid')
    ->count('customer_uuid');

echo "Unique Customers (with 'success' status): $uniqueCustomers\n";

// 3. Show the Raw Data causing the count
$rfmRaw = Transaction::select(
    'customer_uuid',
    DB::raw('MAX(created_at) as last_trx'),
    DB::raw('COUNT(id) as freq'),
    DB::raw('SUM(amount) as monetary')
)
    ->whereNotNull('customer_uuid')
    ->where('status', 'success')
    ->groupBy('customer_uuid')
    ->get();

echo "Rows returned by EisService query: " . $rfmRaw->count() . "\n";
echo "\n--- DETAILS OF 5 CUSTOMERS ---\n";
foreach ($rfmRaw as $row) {
    echo "Customer: {$row->customer_uuid} | Freq: {$row->freq} | Last: {$row->last_trx}\n";
}

echo "\n--- CHECKING FOR 'HIDDEN' TRANSACTIONS ---\n";
// Check if maybe status is 'Success' (capital S) or something else
$otherStatuses = Transaction::select('status', DB::raw('count(*) as total'))
    ->groupBy('status')
    ->get();

echo "Transaction Status Breakdown:\n";
foreach ($otherStatuses as $stat) {
    echo " - '{$stat->status}': {$stat->total}\n";
}

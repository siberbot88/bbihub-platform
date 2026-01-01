<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Transaction;
use App\Models\Service;
use App\Models\Workshop;
use Carbon\Carbon;

echo "Checking Data Availability for 2025...\n";

// 1. Check Transactions
$trxCount = Transaction::where('status', 'success')
    ->whereYear('created_at', 2025)
    ->count();

$trxTotal = Transaction::where('status', 'success')
    ->whereYear('created_at', 2025)
    ->sum('amount');

echo "Transactions (2025) [Success]: $trxCount\n";
echo "Total Revenue (2025): " . number_format($trxTotal) . "\n";

// 2. Check First and Last Transaction Date in 2025
$firstTrx = Transaction::where('status', 'success')->whereYear('created_at', 2025)->orderBy('created_at')->first();
$lastTrx = Transaction::where('status', 'success')->whereYear('created_at', 2025)->orderByDesc('created_at')->first();

if ($firstTrx) {
    echo "First Transaction: " . $firstTrx->created_at . "\n";
    echo "Last Transaction: " . $lastTrx->created_at . "\n";
} else {
    echo "No transactions found for 2025 dates.\n";
}

// 3. Check CLV Data Query Logic
$clvQueryUsers = Transaction::select('customer_uuid')
    ->where('status', 'success')
    ->whereYear('created_at', 2025)
    ->groupBy('customer_uuid')
    ->get()
    ->count();
echo "Unique Customers (CLV Query) for 2025: $clvQueryUsers\n";

// 4. Check Market Gap Logic (Services)
$serviceCount = Service::whereYear('created_at', 2025)->count();
echo "Services Created in 2025: $serviceCount\n";

// 5. Check Service -> Workshop Join (Demand)
$demandCheck = Service::join('workshops', 'services.workshop_uuid', '=', 'workshops.id')
    ->whereYear('services.created_at', 2025)
    ->count();
echo "Service Demand (Joined) 2025: $demandCheck\n";

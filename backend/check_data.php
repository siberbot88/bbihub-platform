<?php

use App\Models\Transaction;
use Illuminate\Support\Facades\DB;

echo "Transaction counts by year:\n";
$counts = Transaction::select(DB::raw('YEAR(created_at) as year'), DB::raw('count(*) as total'))
    ->groupBy('year')
    ->get();

foreach ($counts as $c) {
    echo "Year {$c->year}: {$c->total} transactions\n";
}

echo "\nChecking Owner Subscription counts by year:\n";
$subs = \App\Models\OwnerSubscription::select(DB::raw('YEAR(created_at) as year'), DB::raw('count(*) as total'))
    ->groupBy('year')
    ->get();

foreach ($subs as $s) {
    echo "Year {$s->year}: {$s->total} subscriptions\n";
}

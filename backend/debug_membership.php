<?php

use App\Models\Workshop;

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$workshopName = 'Surabaya Auto Mandiri';
$workshop = Workshop::where('name', $workshopName)->with(['owner.ownerSubscription'])->first();

if (!$workshop) {
    echo "Workshop '$workshopName' not found.\n";
    exit;
}

echo "Workshop: " . $workshop->name . " (ID: " . $workshop->id . ")\n";
echo "Owner UUID: " . $workshop->user_uuid . "\n";

$owner = $workshop->owner;
if (!$owner) {
    echo "Owner is NULL! Check user_uuid.\n";
} else {
    echo "Owner: " . $owner->name . " (ID: " . $owner->id . ")\n";
    $sub = $owner->ownerSubscription;
    if (!$sub) {
        echo "Owner Subscription is NULL!\n";
        // Check raw query
        $rawSub = \DB::table('owner_subscriptions')->where('user_id', $owner->id)->get();
        echo "Raw Subscription Check (count): " . $rawSub->count() . "\n";
        echo json_encode($rawSub, JSON_PRETTY_PRINT);
    } else {
        echo "Subscription ID: " . $sub->id . "\n";
        echo "Status: " . $sub->status . "\n";
        echo "Plan Type: " . $sub->plan_type . "\n";
    }
}

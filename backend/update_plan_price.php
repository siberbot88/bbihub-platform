<?php

use App\Models\SubscriptionPlan;
use Illuminate\Support\Facades\Log;

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$plan = SubscriptionPlan::where('code', 'bbi_hub_plus')->first();

if ($plan) {
    echo "Old Price: Yearly " . number_format((float) $plan->price_yearly) . ", Monthly " . number_format((float) $plan->price_monthly) . "\n";

    $plan->price_monthly = 120000;
    $plan->price_yearly = 1440000;
    $plan->save();

    echo "New Price: Yearly " . number_format((float) $plan->price_yearly) . ", Monthly " . number_format((float) $plan->price_monthly) . "\n";
    echo "Successfully updated subscription plan price.\n";
} else {
    echo "Plan 'bbi_hub_plus' not found.\n";
}

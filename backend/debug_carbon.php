<?php

use Carbon\Carbon;

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$timezone = config('app.timezone');
echo "Timezone: " . $timezone . "\n";

$dateTo = '2025-12-31';
$endOfDay = Carbon::parse($dateTo)->endOfDay();
echo "DateTo Input: " . $dateTo . "\n";
echo "EndOfDay: " . $endOfDay->toDateTimeString() . "\n";
echo "EndOfDay (UTC): " . $endOfDay->setTimezone('UTC')->toDateTimeString() . "\n";

// Check against service date
$serviceDate = '2025-12-31 20:17:32'; // From screenshot
echo "Service Date: " . $serviceDate . "\n";

if ($serviceDate <= $endOfDay->toDateTimeString()) {
    echo "Service IS included in Filter.\n";
} else {
    echo "Service IS EXCLUDED from Filter.\n";
}

<?php

use App\Models\Workshop;
use App\Models\Service;
use Illuminate\Support\Facades\DB;

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "--- DEBUG MARKET GAP (SURABAYA) ---\n";

$city = 'Surabaya';

// 1. Supply (Workshops)
$supply = Workshop::where('city', $city)->count();
echo "Supply (Workshops in $city): $supply\n";

// 2. Demand (Services)
// Logic from EisService: join workshops on service.workshop_uuid
$demand = Service::join('workshops', 'services.workshop_uuid', '=', 'workshops.id')
    ->where('workshops.city', $city)
    ->count();

echo "Demand (Services in $city): $demand\n";

if ($supply > 0) {
    $gap = ($demand / $supply) * 100;
    echo "Gap Score: ($demand / $supply) * 100 = $gap%\n";
} else {
    echo "Gap Score: Infinity (Supply 0)\n";
}

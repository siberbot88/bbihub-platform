<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

// Valid Indonesian cities
$cities = [
    'Jakarta',
    'Surabaya',
    'Bandung',
    'Medan',
    'Semarang',
    'Malang',
    'Yogyakarta',
    'Denpasar',
    'Makassar',
    'Palembang',
    'Tangerang',
    'Bekasi',
    'Depok',
    'Bogor',
    'Batam',
];

echo "Updating all workshops to use Indonesian cities...\n";

$workshops = App\Models\Workshop::all();
$count = 0;

foreach ($workshops as $workshop) {
    // Assign city randomly
    $city = $cities[array_rand($cities)];
    $workshop->update(['city' => $city]);
    $count++;

    if ($count % 50 == 0) {
        echo "Updated {$count} workshops...\n";
    }
}

echo "✅ Updated {$count} workshops with Indonesian cities.\n";

// Clear cache
Illuminate\Support\Facades\Cache::forget('eis_market_gap_v2');
Illuminate\Support\Facades\Cache::forget('workshop_cities');

echo "✅ Cache cleared.\n";

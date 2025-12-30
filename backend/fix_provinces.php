<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

// City -> Province mapping for Indonesia
$cityProvince = [
    'Jakarta' => 'DKI Jakarta',
    'Surabaya' => 'Jawa Timur',
    'Bandung' => 'Jawa Barat',
    'Medan' => 'Sumatera Utara',
    'Semarang' => 'Jawa Tengah',
    'Malang' => 'Jawa Timur',
    'Yogyakarta' => 'DI Yogyakarta',
    'Denpasar' => 'Bali',
    'Makassar' => 'Sulawesi Selatan',
    'Palembang' => 'Sumatera Selatan',
    'Tangerang' => 'Banten',
    'Bekasi' => 'Jawa Barat',
    'Depok' => 'Jawa Barat',
    'Bogor' => 'Jawa Barat',
    'Batam' => 'Kepulauan Riau',
];

echo "Fixing workshop provinces to match Indonesian cities...\n";

$workshops = App\Models\Workshop::all();
$count = 0;

foreach ($workshops as $workshop) {
    // Get correct province based on city
    $province = $cityProvince[$workshop->city] ?? 'Jawa Timur'; // Default fallback

    $workshop->update(['province' => $province]);
    $count++;

    if ($count % 50 == 0) {
        echo "Updated {$count} workshops...\n";
    }
}

echo "✅ Updated {$count} workshops with correct Indonesian provinces.\n";

// Clear cache
Illuminate\Support\Facades\Cache::forget('eis_market_gap_v2');
Illuminate\Support\Facades\Cache::forget('workshop_cities');

echo "✅ Cache cleared.\n";

<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Services\EisService;
use Illuminate\Support\Facades\Log;

echo "=== EIS Charts Debug ===\n\n";

$eisService = app(EisService::class);
$year = 2026;

echo "Testing for Year: $year\n\n";

// 1. CLV Analysis
echo "1. CLV Analysis:\n";
$clvData = $eisService->getClvAnalysis($year, true);
echo "   Scatter Count: " . count($clvData['scatter'] ?? []) . "\n";
echo "   Scatter Data:\n";
print_r($clvData['scatter'] ?? []);
echo "\n";

// 2. Market Gap
echo "2. Market Gap Analysis:\n";
$marketGap = $eisService->getMarketGapAnalysis($year, true);
echo "   Market Gap Count: " . count($marketGap) . "\n";
echo "   Market Gap Data:\n";
print_r($marketGap);
echo "\n";

// 3. City Stats (for Map)
echo "3. City Stats (for Map):\n";
$cityStats = $eisService->getCityMarketStats($year);
echo "   City Stats Count: " . count($cityStats) . "\n";
echo "   City Stats Data:\n";
print_r($cityStats);
echo "\n";

// 4. Check if data is being JSON encoded correctly
echo "4. JSON Encoding Test:\n";
echo "   CLV JSON: " . json_encode($clvData['scatter'] ?? []) . "\n";
echo "   Map JSON: " . json_encode($cityStats) . "\n";

echo "\n=== Debug Complete ===\n";

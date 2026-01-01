<?php

// Quick test for workshop detail data

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Services\EisService;

$eisService = app(EisService::class);

// Get first workshop from top workshops
$topWorkshops = $eisService->getTopWorkshops(1, 2026);
if (empty($topWorkshops)) {
    die("No workshops found\n");
}

$workshopId = $topWorkshops[0]['id'];
echo "Testing Workshop: {$topWorkshops[0]['name']} (ID: $workshopId)\n\n";

$detail = $eisService->getWorkshopDetail($workshopId);

echo "=== Workshop Detail ===\n";
echo "Name: {$detail['name']}\n";
echo "Owner: {$detail['owner_name']}\n";
echo "Total Revenue: Rp " . number_format($detail['total_revenue']) . "\n";
echo "Rating: {$detail['rating']}\n";
echo "\n=== Revenue Trend (6 months) ===\n";
print_r($detail['revenue_trend']);
echo "\n=== Top Services ===\n";
print_r($detail['top_services']);

<?php

// Test API endpoint that mobile is calling

$ch = curl_init();

// Get first owner user
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$owner = \App\Models\User::where('role', 'owner')->first();
if (!$owner) {
    die("No owner user found\n");
}

// Create token for testing
$token = $owner->createToken('test-token')->plainTextToken;

echo "Testing Mobile Analytics Endpoint\n";
echo "Owner: {$owner->name}\n";
echo "Token: " . substr($token, 0, 20) . "...\n\n";

// Test endpoint mobile is calling
$url = 'http://localhost:8000/api/v1/owners/analytics/report?period_type=yearly&date=2025-01-01';

echo "Calling: $url\n\n";

curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $token,
    'Accept: application/json',
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

echo "HTTP Code: $httpCode\n";
echo "Response:\n";
echo json_encode(json_decode($response), JSON_PRETTY_PRINT) . "\n";

curl_close($ch);

// Cleanup token
\Laravel\Sanctum\PersonalAccessToken::where('tokenable_id', $owner->id)->delete();

<?php

require __DIR__ . '/vendor/autoload.php';
$app = require __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$userId = '9df33230-0386-4443-aa2d-045376518177'; // Found in earlier logs/tinker steps or I can query one.
// Actually let's just query a known user.
$user = \App\Models\User::whereHas('workshop')->first();

if (!$user) {
    echo "No owner user found.\n";
    exit;
}

echo "Testing with User ID: " . $user->id . "\n";
echo "User Name: " . $user->name . "\n";

// Mock Request
$request = \Illuminate\Http\Request::create('/api/owner/analytics/report', 'GET', [
    'period_type' => 'yearly',
    'date' => '2025-01-01'
]);
$request->setUserResolver(function () use ($user) {
    return $user;
});

$controller = new \App\Http\Controllers\Api\Owner\AnalyticsController();

try {
    $response = $controller->report($request);
    echo "Response Status: " . $response->getStatusCode() . "\n";
    $content = json_decode($response->getContent(), true);

    if (isset($content['data'])) {
        echo "Revenue: " . $content['data']['revenue_this_period'] . "\n";
        echo "Jobs: " . $content['data']['jobs_done'] . "\n";
    } else {
        echo "No data in response: " . substr($response->getContent(), 0, 200) . "\n";
    }

    // Check log file
    if (file_exists(storage_path('logs/debug_manual.log'))) {
        echo "\nLog file created! Content:\n";
        echo file_get_contents(storage_path('logs/debug_manual.log'));
    } else {
        echo "\nLog file NOT created.\n";
    }

} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString();
}

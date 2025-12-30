<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "Running Workshop Group By Query...\n";

try {
    $results = \App\Models\Workshop::select('city', \Illuminate\Support\Facades\DB::raw('count(*) as total_workshops'))
        ->groupBy('city')
        ->get();

    echo "Raw Results:\n";
    foreach ($results as $row) {
        echo "City: [{$row->city}] - Count: {$row->total_workshops}\n";
    }

    $plucked = $results->pluck('total_workshops', 'city');
    echo "\nPlucked Results:\n";
    print_r($plucked->toArray());

} catch (\Exception $e) {
    echo "Error: " . $e->getMessage();
}

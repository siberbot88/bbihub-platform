<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$workshops = \App\Models\Workshop::select('id', 'name', 'city')->get();

echo "Total Workshops: " . $workshops->count() . "\n";
echo "Workshops by City:\n";

$byCity = $workshops->groupBy('city');
foreach ($byCity as $city => $group) {
    echo "City: [" . ($city ?? 'NULL') . "] - Count: " . $group->count() . "\n";
    foreach ($group as $w) {
        echo "  - " . $w->name . " (" . $w->id . ")\n";
    }
}

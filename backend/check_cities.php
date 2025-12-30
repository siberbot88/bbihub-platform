<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "Current Workshop Cities:\n";
echo "========================\n";

$workshops = App\Models\Workshop::select('id', 'name', 'city')->get();

foreach ($workshops as $w) {
    echo "{$w->name} -> {$w->city}\n";
}

echo "\nTotal: " . $workshops->count() . " workshops\n";

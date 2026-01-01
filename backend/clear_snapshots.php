<?php

use App\Models\EisSnapshot;

echo "Deleting 2025 snapshots...\n";
$deleted = EisSnapshot::where('year', 2025)->delete();
echo "Deleted {$deleted} snapshots.\n";

// Also clear cache just in case
\Illuminate\Support\Facades\Cache::flush();
echo "Cache flushed.\n";

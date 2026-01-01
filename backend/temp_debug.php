try {
$t = \App\Models\Transaction::where('status', 'success')
->whereBetween('created_at', ['2025-11-01', '2025-11-30'])
->first();

if (!$t) {
echo "No success transactions found for Nov 2025.\n";
exit;
}

$w = $t->workshop_uuid;
echo "Workshop UUID: $w\n";

$sum = \App\Models\Transaction::where('workshop_uuid', $w)
->where('status', 'success')
->whereBetween('created_at', ['2025-11-01', '2025-11-30'])
->sum('amount');

echo "Manual Revenue Sum (Nov): " . number_format($sum, 2) . "\n";

$stat = \App\Models\WorkshopStatistic::where('workshop_uuid', $w)
->where('period_date', '2025-11-01')
->first();

if ($stat) {
echo "Stored Statistic (Nov):\n";
echo "Revenue: " . $stat->revenue . "\n";
echo "Jobs: " . $stat->jobs_count . "\n";
echo "Updated At: " . $stat->updated_at . "\n";
} else {
echo "No WorkshopStatistic record found for this workshop/period.\n";
}

} catch (\Exception $e) {
echo "Error: " . $e->getMessage();
}
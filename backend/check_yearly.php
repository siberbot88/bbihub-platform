try {
$t = \App\Models\Transaction::where('status', 'success')->first();
if (!$t) { die("No success transactions found.\n"); }

$w = $t->workshop_uuid;
echo "Workshop UUID: $w\n";

// Check specific yearly record
$stat = \App\Models\WorkshopStatistic::where('workshop_uuid', $w)
->where('period_type', 'yearly')
->where('period_date', '2025-01-01')
->first();

if ($stat) {
echo "✅ Yearly Stat Found (2025):\n";
echo "Revenue: " . number_format($stat->revenue) . "\n";
echo "Jobs: " . $stat->jobs_count . "\n";
} else {
echo "❌ No Yearly Stat Found for 2025-01-01\n";

// Check if ANY yearly stats exist
$anyYearly = \App\Models\WorkshopStatistic::where('period_type', 'yearly')->count();
echo "Total Yearly Stats in DB: $anyYearly\n";
}

} catch (\Exception $e) {
echo "Error: " . $e->getMessage();
}
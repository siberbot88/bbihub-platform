<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Workshop;
use App\Models\Transaction;
use App\Models\Service;
use App\Models\WorkshopStatistic;
use Carbon\Carbon;

echo "=== Re-Aggregating 2025 Yearly Data ===\n\n";

$workshops = Workshop::all();

foreach ($workshops as $workshop) {
    echo "Workshop: {$workshop->name}\n";

    $year = 2025;
    $startDate = Carbon::create($year, 1, 1)->startOfYear();
    $endDate = Carbon::create($year, 12, 31)->endOfYear();

    // Get real data
    $revenue = Transaction::where('workshop_uuid', $workshop->id)
        ->whereIn('status', ['success', 'paid'])
        ->whereBetween('created_at', [$startDate, $endDate])
        ->sum('amount');

    $jobs = Service::where('workshop_uuid', $workshop->id)
        ->where('status', 'completed')
        ->whereBetween('created_at', [$startDate, $endDate])
        ->count();

    echo "- Revenue: Rp " . number_format($revenue) . "\n";
    echo "- Jobs: $jobs\n";

    if ($revenue > 0 || $jobs > 0) {
        // Monthly breakdown
        $monthlyData = [];
        for ($m = 1; $m <= 12; $m++) {
            $monthStart = Carbon::create($year, $m, 1)->startOfMonth();
            $monthEnd = Carbon::create($year, $m, 1)->endOfMonth();

            $monthRev = Transaction::where('workshop_uuid', $workshop->id)
                ->whereIn('status', ['success', 'paid'])
                ->whereBetween('created_at', [$monthStart, $monthEnd])
                ->sum('amount');

            $monthJobs = Service::where('workshop_uuid', $workshop->id)
                ->where('status', 'completed')
                ->whereBetween('created_at', [$monthStart, $monthEnd])
                ->count();

            if ($monthRev > 0 || $monthJobs > 0) {
                $monthKey = $monthStart->format('Y-m');
                $monthlyData[$monthKey] = [
                    'revenue' => $monthRev,
                    'jobs' => $monthJobs
                ];
            }
        }

        // Service breakdown
        $serviceBreakdown = Service::where('workshop_uuid', $workshop->id)
            ->where('status', 'completed')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->select('name', \DB::raw('count(*) as count'))
            ->groupBy('name')
            ->pluck('count', 'name')
            ->toArray();

        // Update or create
        WorkshopStatistic::updateOrCreate(
            [
                'workshop_uuid' => $workshop->id,
                'period_type' => 'yearly',
                'period_date' => $startDate->toDateString()
            ],
            [
                'total_revenue' => $revenue,
                'jobs_completed' => $jobs,
                'metadata' => [
                    'monthly_breakdown' => $monthlyData,
                    'service_breakdown' => $serviceBreakdown,
                    'aggregated_at' => now()->toDateTimeString()
                ]
            ]
        );

        echo "✅ Updated yearly stat for 2025\n";
    } else {
        echo "⚠️  No data to aggregate\n";
    }

    echo "\n";
}

echo "=== Done! ===\n";

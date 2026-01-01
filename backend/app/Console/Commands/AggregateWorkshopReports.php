<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class AggregateWorkshopReports extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'reports:aggregate {--month= : Format YYYY-MM} {--backfill : Process last 12 months}';
    protected $description = 'Aggregate workshop statistics for monthly reports';

    public function handle()
    {
        $backfill = $this->option('backfill');
        $monthParam = $this->option('month');

        $monthsToProcess = [];

        if ($backfill) {
            $current = \Carbon\Carbon::now()->subMonth()->startOfMonth();
            for ($i = 0; $i < 12; $i++) {
                $monthsToProcess[] = $current->copy();
                $current->subMonth();
            }
        } elseif ($monthParam) {
            $monthsToProcess[] = \Carbon\Carbon::parse($monthParam)->startOfMonth();
        } else {
            // Default: Previous month
            $monthsToProcess[] = \Carbon\Carbon::now()->subMonth()->startOfMonth();
        }

        $workshops = \App\Models\Workshop::all();
        $bar = $this->output->createProgressBar($workshops->count() * count($monthsToProcess));

        foreach ($workshops as $workshop) {
            foreach ($monthsToProcess as $month) {
                $this->processWorkshopMonth($workshop, $month);
                $bar->advance();
            }

            // Also process Yearly Stats for the year of the month being processed
            $yearsProcessed = [];
            foreach ($monthsToProcess as $month) {
                $year = $month->year;
                if (!in_array($year, $yearsProcessed)) {
                    $this->processWorkshopYear($workshop, $year);
                    $yearsProcessed[] = $year;
                }
            }
        }

        $bar->finish();
        $this->info("\nAggregation completed.");
    }

    private function processWorkshopMonth($workshop, $month)
    {
        $start = $month->copy()->startOfMonth();
        $end = $month->copy()->endOfMonth();

        // 1. Revenue
        $revenue = \App\Models\Transaction::where('workshop_uuid', $workshop->id)
            ->whereIn('status', ['success', 'paid'])
            ->whereBetween('created_at', [$start, $end])
            ->sum('amount');

        // 2. Jobs
        $jobsCount = \App\Models\Service::where('workshop_uuid', $workshop->id)
            ->where('status', 'completed')
            ->whereBetween('created_at', [$start, $end])
            ->count();

        // 3. Active Employees (Snapshot logic: currently just count active now as proxy, or created before end of month)
        // Better: Count employees created before end of month and not deleted? 
        // For MVP: Count all employees associated with workshop at that time
        $activeEmployees = \App\Models\Employment::where('workshop_uuid', $workshop->id)
            ->whereDate('created_at', '<=', $end)
            ->count();

        // 4. Metadata (Service Breakdown)
        $serviceBreakdown = \App\Models\Service::where('workshop_uuid', $workshop->id)
            ->whereBetween('created_at', [$start, $end])
            ->select('name', \Illuminate\Support\Facades\DB::raw('count(*) as count'))
            ->groupBy('name')
            ->pluck('count', 'name')
            ->toArray();

        // 5. Occupancy Rate
        $activeServices = \App\Models\Service::where('workshop_uuid', $workshop->id)
            ->whereIn('status', ['in progress', 'pending', 'accepted'])
            ->whereBetween('created_at', [$start, $end]) // Approximation for history? Or just snapshot. 
            // For history, "Average Occupancy" is hard. Let's use a simplified metric:
            // "Jobs Done" vs "Capacity" (Jobs / 30 days / 10 slots).
            // Or just store the calculated activeServices value if that's what we want.
            // Let's stick to the controller logic:
            ->count();
        $capacity = 20;
        $occupancyRate = min(100, round(($activeServices / $capacity) * 100));

        // 6. Top Mechanics
        $topMechanics = \App\Models\Service::where('workshop_uuid', $workshop->id)
            ->where('status', 'completed')
            ->whereNotNull('mechanic_uuid')
            ->whereBetween('created_at', [$start, $end])
            ->select('mechanic_uuid', \Illuminate\Support\Facades\DB::raw('count(*) as jobs_count'))
            ->groupBy('mechanic_uuid')
            ->orderByDesc('jobs_count')
            ->limit(5)
            ->with(['mechanic.user'])
            ->get()
            ->map(function ($item) {
                $user = $item->mechanic->user ?? null;
                return [
                    'name' => $user ? $user->name : 'Unknown',
                    'photo_url' => $user ? $user->photo_url : null,
                    'jobs_count' => $item->jobs_count,
                    'rating' => 5.0,
                    'efficiency' => '95%',
                ];
            })->toArray();

        // 7. Daily Trend (for charts)
        $dailyTrend = [];
        $period = new \DatePeriod($start, new \DateInterval('P1D'), $end);
        foreach ($period as $dt) {
            $carbonDt = \Carbon\Carbon::instance($dt);
            $dateKey = $carbonDt->format('Y-m-d');
            $dayStart = $carbonDt->copy()->startOfDay();
            $dayEnd = $carbonDt->copy()->endOfDay();

            $rev = \App\Models\Transaction::where('workshop_uuid', $workshop->id)
                ->whereIn('status', ['success', 'paid'])
                ->whereBetween('created_at', [$dayStart, $dayEnd])
                ->sum('amount');

            $jobs = \App\Models\Service::where('workshop_uuid', $workshop->id)
                ->where('status', 'completed')
                ->whereBetween('created_at', [$dayStart, $dayEnd])
                ->count();

            $dailyTrend[$dateKey] = ['revenue' => $rev, 'jobs' => $jobs];
        }

        \App\Models\WorkshopStatistic::updateOrCreate(
            [
                'workshop_uuid' => $workshop->id,
                'period_type' => 'monthly',
                'period_date' => $start->toDateString(),
            ],
            [
                'revenue' => $revenue,
                'jobs_count' => $jobsCount,
                'active_employees_count' => $activeEmployees,
                'metadata' => json_encode([
                    'service_breakdown' => $serviceBreakdown,
                    'occupancy_rate' => $occupancyRate,
                    'top_mechanics' => $topMechanics,
                    'daily_trend' => $dailyTrend
                ]),
            ]
        );
    }

    private function processWorkshopYear($workshop, $year)
    {
        $start = \Carbon\Carbon::createFromDate($year, 1, 1)->startOfYear();
        $end = \Carbon\Carbon::createFromDate($year, 12, 31)->endOfYear();

        // 1. Revenue
        $revenue = \App\Models\Transaction::where('workshop_uuid', $workshop->id)
            ->whereIn('status', ['success', 'paid'])
            ->whereBetween('created_at', [$start, $end])
            ->sum('amount');

        // 2. Jobs
        $jobsCount = \App\Models\Service::where('workshop_uuid', $workshop->id)
            ->where('status', 'completed')
            ->whereBetween('created_at', [$start, $end])
            ->count();

        // 3. Active Employees
        $activeEmployees = \App\Models\Employment::where('workshop_uuid', $workshop->id)
            ->whereDate('created_at', '<=', $end)
            ->count();

        // 4. Metadata (Service Breakdown) - Top 5 for year
        $serviceBreakdown = \App\Models\Service::where('workshop_uuid', $workshop->id)
            ->whereBetween('created_at', [$start, $end])
            ->select('name', \Illuminate\Support\Facades\DB::raw('count(*) as count'))
            ->groupBy('name')
            ->limit(10)
            ->pluck('count', 'name')
            ->toArray();

        // 5. Monthly Trend (for charts) - Aggregated from transactions directly or monthly stats
        // Let's aggregate from transactions to be safe
        $monthlyTrend = [];
        // Initialize all 12 months with 0
        for ($i = 1; $i <= 12; $i++) {
            $monthStart = \Carbon\Carbon::createFromDate($year, $i, 1)->startOfMonth();
            $key = $monthStart->format('Y-m');
            $monthlyTrend[$key] = ['revenue' => 0, 'jobs' => 0];
        }

        $trendData = \App\Models\Transaction::where('workshop_uuid', $workshop->id)
            ->whereIn('status', ['success', 'paid'])
            ->whereBetween('created_at', [$start, $end])
            ->selectRaw("DATE_FORMAT(created_at, '%Y-%m') as m, sum(amount) as revenue")
            ->groupBy('m')
            ->pluck('revenue', 'm');

        $jobsTrend = \App\Models\Service::where('workshop_uuid', $workshop->id)
            ->where('status', 'completed')
            ->whereBetween('created_at', [$start, $end])
            ->selectRaw("DATE_FORMAT(created_at, '%Y-%m') as m, count(*) as count")
            ->groupBy('m')
            ->pluck('count', 'm');

        foreach ($monthlyTrend as $key => $val) {
            $monthlyTrend[$key]['revenue'] = (float) ($trendData[$key] ?? 0);
            $monthlyTrend[$key]['jobs'] = (int) ($jobsTrend[$key] ?? 0);
        }

        // 6. Top Mechanics (Yearly)
        $topMechanics = \App\Models\Service::where('workshop_uuid', $workshop->id)
            ->where('status', 'completed')
            ->whereNotNull('mechanic_uuid')
            ->whereBetween('created_at', [$start, $end])
            ->select('mechanic_uuid', \Illuminate\Support\Facades\DB::raw('count(*) as jobs_count'))
            ->groupBy('mechanic_uuid')
            ->orderByDesc('jobs_count')
            ->limit(5)
            ->with(['mechanic.user'])
            ->get()
            ->map(function ($item) {
                $user = $item->mechanic->user ?? null;
                return [
                    'name' => $user ? $user->name : 'Unknown',
                    'photo_url' => $user ? $user->photo_url : null,
                    'jobs_count' => $item->jobs_count,
                    'rating' => 5.0,
                    'efficiency' => '95%',
                ];
            })->toArray();

        \App\Models\WorkshopStatistic::updateOrCreate(
            [
                'workshop_uuid' => $workshop->id,
                'period_type' => 'yearly',
                'period_date' => $start->toDateString(),
            ],
            [
                'revenue' => $revenue,
                'jobs_count' => $jobsCount,
                'active_employees_count' => $activeEmployees,
                'metadata' => json_encode([
                    'service_breakdown' => $serviceBreakdown,
                    'occupancy_rate' => 0, // Less relevant for Yearly
                    'top_mechanics' => $topMechanics,
                    'daily_trend' => $monthlyTrend // Actually monthly trend
                ]),
            ]
        );
    }
}

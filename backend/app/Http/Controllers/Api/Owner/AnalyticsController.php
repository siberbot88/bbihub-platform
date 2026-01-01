<?php

namespace App\Http\Controllers\Api\Owner;

use App\Http\Controllers\Controller;
use App\Models\Service;
use App\Models\Transaction;
use App\Models\Workshop;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AnalyticsController extends Controller
{
    public function report(Request $request)
    {
        $user = $request->user();

        // Robust Workshop Resolution
        $workshopUuid = $user->workshop_uuid
            ?? $user->workshop()->value('id')
            ?? $user->employment()->value('workshop_uuid');

        // DEBUG: Force Log to file
        $debugInfo = "Time: " . now() . "\nUser: " . ($user->id ?? 'N/A') . "\nResolved UUID: " . ($workshopUuid ?? 'NULL') . "\nRequest: " . json_encode($request->all()) . "\n-----------------\n";
        file_put_contents(storage_path('logs/debug_manual.log'), $debugInfo, FILE_APPEND);

        Log::error('ANALYTICS_RESOLVED_UUID', ['uuid' => $workshopUuid]);

        if (!$user || !$workshopUuid) {
            return response()->json(['success' => false, 'message' => 'Workshop not found'], 404);
        }

        Log::info("Analytics Resolution", [
            'user_id' => $user->id,
            'resolved_workshop_uuid' => $workshopUuid
        ]);

        $now = Carbon::now();
        $periodType = $request->input('period_type', 'monthly'); // monthly, yearly
        $dateParam = $request->input('date', $now->toDateString());
        $targetDate = Carbon::parse($dateParam);

        // 1. Determine Date Range
        if ($periodType === 'yearly') {
            $startDate = $targetDate->copy()->startOfYear();
            $endDate = $targetDate->copy()->endOfYear();
        } else {
            // Default to monthly
            $startDate = $targetDate->copy()->startOfMonth();
            $endDate = $targetDate->copy()->endOfMonth();
        }

        // 2. Aggregate KPI (Real Data)
        // Revenue (Paid/Success Transactions)
        $revenue = Transaction::where('workshop_uuid', $workshopUuid)
            ->whereIn('status', ['success', 'paid'])
            ->whereBetween('created_at', [$startDate, $endDate])
            ->sum('amount');

        // Jobs Done (Completed Services)
        $jobsDone = Service::where('workshop_uuid', $workshopUuid)
            ->where('status', 'completed')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->count();

        // Occupancy (Active Services vs Capacity - Simplified for now)
        // Assumption: Capacity is fixed or derived from Mechanic count * slots per day
        // For MVP: Active Services count
        $activeServices = Service::where('workshop_uuid', $workshopUuid)
            ->whereIn('status', ['in progress', 'pending', 'accepted'])
            ->count();

        // Simple occupancy proxy: (Active / 10) * 100. 10 is dummy capacity.
        // Ideally fetch from Workshop settings.
        $capacity = 20;
        $occupancyRate = min(100, round(($activeServices / $capacity) * 100));

        // Rating
        $avgRating = $user->workshop->rating ?? 0;

        // 3. Trend Data (Revenue & Jobs per Day for the period)
        // 3. Trend Data

        // --- HISTORICAL DATA CHECK ---
        // If we are looking for a past month, check if we have aggregated stats
        $isCurrentMonth = $startDate->isCurrentMonth() && $startDate->isCurrentYear();

        if (!$isCurrentMonth) {
            $stats = \App\Models\WorkshopStatistic::where('workshop_uuid', $workshopUuid)
                ->where('period_type', $periodType)
                ->where('period_date', $startDate->toDateString())
                ->first();

            if ($stats) {
                // Return cached data
                $meta = $stats->metadata ?? []; // JSON casted to array by model
                $serviceBreakdownArray = $meta['service_breakdown'] ?? [];
                $topMechanics = $meta['top_mechanics'] ?? [];
                $occupancyRate = $meta['occupancy_rate'] ?? 0;

                // Ensure service_breakdown is object, not array
                $serviceBreakdown = is_array($serviceBreakdownArray) && !empty($serviceBreakdownArray)
                    ? (object) $serviceBreakdownArray
                    : new \stdClass();

                // Reconstruct breakdown trend from meta['daily_trend']
                $dailyTrend = $meta['daily_trend'] ?? [];
                $labels = [];
                $revTrend = [];
                $jobsTrend = [];

                foreach ($dailyTrend as $dt => $vals) {
                    $d = Carbon::parse($dt);
                    $labels[] = $d->format('d');
                    $revTrend[] = (float) ($vals['revenue'] ?? 0);
                    $jobsTrend[] = (int) ($vals['jobs'] ?? 0);
                }

                // Trend Data Structure
                $cachedTrend = [
                    'labels' => $labels,
                    'revenue' => $revTrend,
                    'jobs' => $jobsTrend
                ];

                // Generate Forecast Structure for UI compatibility
                // Even for history, UI might expect this field to verify graph rendering
                $forecast = [];
                $lastDate = Carbon::parse($startDate)->endOfMonth(); // or period end
                for ($i = 1; $i <= 7; $i++) {
                    $forecast[] = [
                        'date' => $lastDate->copy()->addDays($i)->format('Y-m-d'),
                        'value' => 0 // Flat line for history
                    ];
                }

                return response()->json([
                    'success' => true,
                    'data' => [
                        'revenue_this_period' => (int) $stats->revenue,
                        'jobs_done' => (int) $stats->jobs_count,
                        'occupancy_rate' => $occupancyRate,
                        'avg_rating' => (float) $avgRating,
                        'revenue_growth_text' => '-', // hard to calc without prev month here easily
                        'jobs_growth_text' => '-',
                        'occupancy_growth_text' => '-',
                        'rating_growth_text' => '-',
                        'trend_labels' => $cachedTrend['labels'],
                        'revenue_trend' => $cachedTrend['revenue'],
                        'jobs_trend' => $cachedTrend['jobs'],
                        'forecast_revenue' => $forecast, // Use generated forecast
                        'top_mechanics' => $topMechanics,
                        'service_breakdown' => $serviceBreakdown,
                        'peak_hour_labels' => ['08', '10', '12', '14', '16'], // Dummy
                        'peak_hour_bars' => [2, 5, 8, 4, 3],
                        'avg_queue_bars' => [1, 2, 1, 3, 2, 5, 4],
                        'avg_queue' => $stats->active_employees_count, // using as proxy? Or just 0
                        'efficiency' => 85,
                        'peak_range' => '-'
                    ]
                ]);
            }
        }
        // -----------------------------

        $trendData = $this->getTrendData($workshopUuid, $startDate, $endDate, $periodType);

        // 4. ML Forecast (Call Python Service)
        $forecast = [];
        try {
            $mlUrl = config('services.ml_service.url') ?? 'http://127.0.0.1:5000';
            $apiKey = config('services.ml_service.key') ?? env('ML_API_KEY');

            Log::info('AnalyticsController: Calling ML Service', [
                'url' => "{$mlUrl}/predict/workshop-revenue",
                'workshop_uuid' => $workshopUuid,
                'days' => 7
            ]);

            // Note: Without ->async(), this returns Illuminate\Http\Client\Response directly
            /** @var \Illuminate\Http\Client\Response $response */
            $response = Http::withHeaders(['X-API-Key' => $apiKey])
                ->timeout(10) // 10 second timeout
                ->get("{$mlUrl}/predict/workshop-revenue", [
                    'workshop_uuid' => $workshopUuid,
                    'days' => 7
                ]);

            if ($response->successful()) {
                $json = $response->json();
                if ($json['success'] ?? false) {
                    $forecastData = $json['data']['forecast'] ?? [];
                    if (!empty($forecastData)) {
                        $forecast = $forecastData;
                        Log::info('AnalyticsController: ML Forecast retrieved successfully', [
                            'count' => count($forecast)
                        ]);
                    } else {
                        Log::warning('AnalyticsController: ML Service returned empty forecast data');
                    }
                } else {
                    Log::warning('AnalyticsController: ML Service returned success=false', [
                        'response' => $json
                    ]);
                }
            } else {
                Log::warning("ML Service returned error", [
                    'status' => $response->status(),
                    'body' => $response->body()
                ]);
            }
        } catch (\Exception $e) {
            Log::warning("ML Forecast failed", [
                'error' => $e->getMessage(),
                'workshop_uuid' => $workshopUuid
            ]);
        }

        // Fallback: Generate dummy forecast if empty
        // This ensures mobile app always has data to render (even if all zeros)
        if (empty($forecast)) {
            Log::info('AnalyticsController: Generating fallback forecast (zeros)');
            $forecast = [];
            // Use end of period for forecast start if period is past
            $baseDate = $endDate->isPast() ? $endDate->copy() : Carbon::now();

            for ($i = 1; $i <= 7; $i++) {
                $forecast[] = [
                    'date' => $baseDate->copy()->addDays($i)->format('Y-m-d'),
                    'value' => 0
                ];
            }
        }

        Log::info('AnalyticsController: Final Forecast', [
            'count' => count($forecast),
            'first_item' => $forecast[0] ?? null
        ]);

        // 5. Service Breakdown
        $serviceBreakdownCollection = Service::where('workshop_uuid', $workshopUuid)
            ->whereBetween('created_at', [$startDate, $endDate])
            ->select('name', DB::raw('count(*) as count'))
            ->groupBy('name')
            ->pluck('count', 'name');

        // Convert to object (not array) for JSON serialization
        $serviceBreakdown = (object) $serviceBreakdownCollection->toArray();

        return response()->json([
            'success' => true,
            'data' => [
                'revenue_this_period' => (int) $revenue,
                'jobs_done' => $jobsDone,
                'occupancy_rate' => $occupancyRate,
                'avg_rating' => (float) $avgRating,

                // Growth (Mock for now, or compare with prev period)
                'revenue_growth_text' => '+5%',
                'jobs_growth_text' => '+2%',
                'occupancy_growth_text' => '0%',
                'rating_growth_text' => '0.0',

                'trend_labels' => $trendData['labels'],
                'revenue_trend' => $trendData['revenue'],
                'jobs_trend' => $trendData['jobs'],

                'forecast_revenue' => $forecast, // New Field
                'top_mechanics' => array_values($this->getTopMechanics($workshopUuid, $startDate, $endDate)->toArray()),

                'service_breakdown' => $serviceBreakdown,

                // Dummy Peak Hour & Queue for UI compatibility
                'peak_hour_labels' => ['08', '10', '12', '14', '16'],
                'peak_hour_bars' => [2, 5, 8, 4, 3],
                'avg_queue_bars' => [1, 2, 1, 3, 2, 5, 4],
                'avg_queue' => $activeServices, // Current queue
                'efficiency' => 85,
                'peak_range' => '10:00 - 14:00'
            ]
        ]);
    }

    private function getTrendData($workshopUuid, $start, $end, $periodType)
    {
        $dateFormat = $periodType === 'yearly' ? '%Y-%m' : '%Y-%m-%d';
        $groupBy = $periodType === 'yearly' ? 'month_date' : 'date';

        // Group by Date/Month
        $revenueTrend = Transaction::where('workshop_uuid', $workshopUuid)
            ->whereIn('status', ['success', 'paid'])
            ->whereBetween('created_at', [$start, $end])
            ->select(DB::raw("DATE_FORMAT(created_at, '$dateFormat') as $groupBy"), DB::raw('sum(amount) as total'))
            ->groupBy($groupBy)
            ->pluck('total', $groupBy);

        $jobsTrend = Service::where('workshop_uuid', $workshopUuid)
            ->where('status', 'completed')
            ->whereBetween('created_at', [$start, $end])
            ->select(DB::raw("DATE_FORMAT(created_at, '$dateFormat') as $groupBy"), DB::raw('count(*) as count'))
            ->groupBy($groupBy)
            ->pluck('count', $groupBy);

        // Fill gaps
        $labels = [];
        $revenueValues = [];
        $jobsValues = [];

        if ($periodType === 'yearly') {
            // Iterate 12 months
            $current = $start->copy();
            for ($i = 0; $i < 12; $i++) {
                $key = $current->format('Y-m');
                $labels[] = $current->format('M'); // Jan, Feb
                $revenueValues[] = (int) ($revenueTrend[$key] ?? 0);
                $jobsValues[] = (int) ($jobsTrend[$key] ?? 0);
                $current->addMonth();
            }
        } else {
            // Daily iteration
            $period = new \DatePeriod($start, new \DateInterval('P1D'), $end);
            foreach ($period as $dt) {
                $dateKey = $dt->format('Y-m-d');
                $labels[] = $dt->format('d'); // 01, 02
                $revenueValues[] = (int) ($revenueTrend[$dateKey] ?? 0);
                $jobsValues[] = (int) ($jobsTrend[$dateKey] ?? 0);
            }
        }

        return [
            'labels' => $labels,
            'revenue' => $revenueValues,
            'jobs' => $jobsValues
        ];
    }

    private function getTopMechanics($workshopUuid, $start, $end)
    {
        // 1. Get Services grouped by mechanic (Employment ID)
        $top = Service::where('workshop_uuid', $workshopUuid)
            ->where('status', 'completed')
            ->whereNotNull('mechanic_uuid')
            ->whereBetween('created_at', [$start, $end])
            ->select('mechanic_uuid', DB::raw('count(*) as jobs_count'))
            ->groupBy('mechanic_uuid')
            ->orderByDesc('jobs_count')
            ->limit(5)
            ->with(['mechanic.user']) // mechanic() returns Employment, which has user()
            ->get();

        return $top->map(function ($item) {
            $user = $item->mechanic->user ?? null;
            return [
                'name' => $user ? $user->name : 'Unknown',
                'photo_url' => $user ? $user->photo_url : null,
                'jobs_count' => $item->jobs_count,
                'rating' => 5.0, // Placeholder, implementing real rating requires aggregation from reviews
                'efficiency' => '95%', // Placeholder
            ];
        });
    }
}

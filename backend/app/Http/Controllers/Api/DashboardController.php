<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Service;
use App\Models\Transaction;
use App\Models\Employment;
use App\Models\Customer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DashboardController extends Controller
{
    /**
     * GET /api/v1/admins/dashboard
     * Flutter-compatible dashboard endpoint
     */
    public function index(Request $request)
    {
        $user = $request->user();
        if (!$user->employment) {
            return response()->json(['message' => 'Admin tidak memiliki workshop.'], 403);
        }

        $workshopId = $request->query('workshop_uuid') ?? $user->employment->workshop_uuid;
        $today = Carbon::today();

        // Base query for this workshop
        $baseQuery = Service::where('workshop_uuid', $workshopId);

        // Services Today (scheduled_date = today)
        $servicesToday = (clone $baseQuery)
            ->whereDate('scheduled_date', $today)
            ->count();

        // Needs Assignment (accepted but no mechanic assigned yet)
        $needsAssignment = (clone $baseQuery)
            ->where('acceptance_status', 'accepted')
            ->where('status', 'pending')
            ->whereNull('mechanic_uuid')
            ->count();

        // In Progress
        $inProgress = (clone $baseQuery)
            ->where('status', 'in progress')
            ->count();

        // Completed Today
        $completed = (clone $baseQuery)
            ->whereDate('completed_at', $today)
            ->whereIn('status', ['completed', 'lunas'])
            ->count();

        // Trend Weekly (last 7 days)
        $trendWeekly = collect();
        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::today()->subDays($i);
            $count = (clone $baseQuery)
                ->whereDate('scheduled_date', $date)
                ->count();
            $trendWeekly->push([
                'date' => $date->format('D'), // Mon, Tue, etc.
                'total' => $count,
            ]);
        }

        // Trend Monthly (last 6 months)
        $trendMonthly = collect();
        for ($i = 5; $i >= 0; $i--) {
            $monthStart = Carbon::now()->subMonths($i)->startOfMonth();
            $monthEnd = Carbon::now()->subMonths($i)->endOfMonth();
            $count = (clone $baseQuery)
                ->whereBetween('scheduled_date', [$monthStart, $monthEnd])
                ->count();
            $trendMonthly->push([
                'date' => $monthStart->format('M'), // Jan, Feb, etc.
                'month' => $monthStart->format('Y-m'),
                'total' => $count,
            ]);
        }

        // Top Services (by category_service)
        $topServices = (clone $baseQuery)
            ->selectRaw('category_service, COUNT(*) as count')
            ->whereNotNull('category_service')
            ->groupBy('category_service')
            ->orderByDesc('count')
            ->limit(5)
            ->get()
            ->map(fn($s) => [
                'category_service' => $s->category_service,
                'count' => $s->count,
            ]);

        // === MECHANIC STATS ===
        // ✅ OPTIMIZED: Single aggregated query to avoid N+1 problem
        $mechanicStats = DB::table('employments as e')
            ->join('users as u', 'e.user_uuid', '=', 'u.id')
            ->leftJoin('services as s', function ($join) use ($workshopId) {
                $join->on('e.id', '=', 's.mechanic_uuid')
                    ->where('s.workshop_uuid', '=', $workshopId);
            })
            ->join('model_has_roles as mhr', 'mhr.model_id', '=', 'u.id')
            ->join('roles as r', 'mhr.role_id', '=', 'r.id')
            ->where('e.workshop_uuid', $workshopId)
            ->where('r.name', 'mechanic')
            ->where('r.guard_name', 'sanctum')
            ->select([
                'e.id',
                'u.name',
                DB::raw('COALESCE(e.specialist, "mechanic") as role'),
                DB::raw('COUNT(CASE WHEN s.status IN ("completed", "lunas") THEN 1 END) as completed_jobs'),
                DB::raw('COUNT(CASE WHEN s.status = "in progress" THEN 1 END) as active_jobs'),
            ])
            ->groupBy('e.id', 'u.name', 'e.specialist')
            ->orderByDesc('completed_jobs')
            ->limit(5)
            ->get()
            ->map(fn($stat) => [
                'id' => $stat->id,
                'name' => $stat->name ?? 'Unknown',
                'role' => $stat->role,
                'completed_jobs' => (int) $stat->completed_jobs,
                'active_jobs' => (int) $stat->active_jobs,
            ]);

        // === CUSTOMER STATS ===
        // Customers don't have workshop_uuid, so derive from services
        $totalCustomers = (clone $baseQuery)
            ->distinct('customer_uuid')
            ->count('customer_uuid');

        $newCustomersThisMonth = (clone $baseQuery)
            ->whereMonth('created_at', Carbon::now()->month)
            ->whereYear('created_at', Carbon::now()->year)
            ->distinct('customer_uuid')
            ->count('customer_uuid');

        // Active customers = customers with services in last 30 days
        $activeCustomers = (clone $baseQuery)
            ->where('scheduled_date', '>=', Carbon::now()->subDays(30))
            ->distinct('customer_uuid')
            ->count('customer_uuid');

        return response()->json([
            'data' => [
                'services_today' => $servicesToday,
                'needs_assignment' => $needsAssignment,
                'in_progress' => $inProgress,
                'completed' => $completed,
                'trend' => $trendWeekly, // Weekly (default for backward compatibility)
                'trend_weekly' => $trendWeekly,
                'trend_monthly' => $trendMonthly,
                'top_services' => $topServices,
                'mechanic_stats' => $mechanicStats,
                'customer_stats' => [
                    'total' => $totalCustomers,
                    'new_this_month' => $newCustomersThisMonth,
                    'active' => $activeCustomers,
                ],
            ],
        ]);
    }

    /**
     * GET /api/v1/admins/dashboard/stats
     * Filter by date_from & date_to (default: start of month - now)
     */
    public function getStats(Request $request)
    {
        $user = $request->user();
        if (!$user->employment) {
            return response()->json(['message' => 'Admin tidak memiliki workshop.'], 403);
        }
        $workshopId = $user->employment->workshop_uuid;

        // Date Range
        $rawFrom = $request->input('date_from');
        $rawTo = $request->input('date_to');

        // Parse with explicit error handling/logging
        try {
            $dateFrom = $rawFrom
                ? Carbon::parse($rawFrom)->startOfDay()
                : Carbon::now()->startOfMonth();

            $dateTo = $rawTo
                ? Carbon::parse($rawTo)->endOfDay()
                : Carbon::now()->endOfDay();

            \Illuminate\Support\Facades\Log::info("Dashboard Stats Filter: ", [
                'raw_from' => $rawFrom,
                'raw_to' => $rawTo,
                'parsed_from' => $dateFrom->toDateTimeString(),
                'parsed_to' => $dateTo->toDateTimeString(),
                'workshop_id' => $workshopId
            ]);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error("Dashboard Date Parse Error: " . $e->getMessage());
            return response()->json(['message' => 'Invalid date format'], 400);
        }

        // 1. SERVICES STATS
        $servicesQuery = Service::where('workshop_uuid', $workshopId)
            ->whereBetween('created_at', [$dateFrom, $dateTo]);

        $totalServices = (clone $servicesQuery)->count();

        // Group by status
        $servicesByStatus = (clone $servicesQuery)
            ->select('status', DB::raw('count(*) as count'))
            ->groupBy('status')
            ->pluck('count', 'status')
            ->toArray();


        // Acceptance Status
        $acceptanceStats = (clone $servicesQuery)
            ->select('acceptance_status', DB::raw('count(*) as count'))
            ->groupBy('acceptance_status')
            ->pluck('count', 'acceptance_status')
            ->toArray();

        // [Feature Upgrade] Service Trend (Daily) for Chart
        // Group by scheduled_date or created_at. Let's use created_at (Date)
        $serviceTrend = (clone $servicesQuery)
            ->select(DB::raw('DATE(created_at) as date'), DB::raw('count(*) as total'))
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // [Feature Upgrade] Service Type Breakdown (Booking vs Walk-in)
        $typeBreakdown = (clone $servicesQuery)
            ->select('type', DB::raw('count(*) as count'))
            ->whereNotNull('type')
            ->groupBy('type')
            ->pluck('count', 'type')
            ->toArray();

        // [Feature Upgrade] Most Frequent Services (Top 5)
        // Group by 'category_service' (or 'name' if consistent)
        $topServices = (clone $servicesQuery)
            ->select('category_service', DB::raw('count(*) as count'))
            ->whereNotNull('category_service')
            ->groupBy('category_service')
            ->orderByDesc('count')
            ->limit(5)
            ->get();

        // Needs Assignment (same logic as quick stats)
        $needsAssignment = (clone $servicesQuery)
            ->where('acceptance_status', 'accepted')
            ->where('status', 'pending')
            ->whereNull('mechanic_uuid')
            ->count();

        // 3. MECHANIC PERFORMANCE
        // ✅ OPTIMIZED: Single aggregated query to avoid N+1 problem
        $mechanicStats = DB::table('employments as e')
            ->join('users as u', 'e.user_uuid', '=', 'u.id')
            ->leftJoin('services as s', function ($join) use ($workshopId, $dateFrom, $dateTo) {
                $join->on('e.id', '=', 's.mechanic_uuid')
                    ->where('s.workshop_uuid', '=', $workshopId)
                    ->whereBetween('s.created_at', [$dateFrom, $dateTo]);
            })
            ->join('model_has_roles as mhr', 'mhr.model_id', '=', 'u.id')
            ->join('roles as r', 'mhr.role_id', '=', 'r.id')
            ->where('e.workshop_uuid', $workshopId)
            ->where('r.name', 'mechanic')
            ->where('r.guard_name', 'sanctum')
            ->select([
                'u.name',
                DB::raw('COUNT(CASE WHEN s.status = "completed" THEN 1 END) as completed_services'),
                DB::raw('COUNT(CASE WHEN s.status IN ("in progress", "pending") THEN 1 END) as active_services'),
            ])
            ->groupBy('u.name')
            ->orderByDesc('completed_services')
            ->get()
            ->map(fn($stat) => [
                'name' => $stat->name,
                'completed_services' => (int) $stat->completed_services,
                'active_services' => (int) $stat->active_services,
            ]);


        // 4. CUSTOMER INSIGHTS
        // Total customers who had service in this periode
        $totalCustomersServed = (clone $servicesQuery)
            ->distinct('customer_uuid')
            ->count('customer_uuid');


        return response()->json([
            'period' => [
                'from' => $dateFrom->toDateString(),
                'to' => $dateTo->toDateString(),
            ],
            'services' => [
                'total' => $totalServices,
                'needs_assignment' => $needsAssignment,
                'status_breakdown' => $servicesByStatus,
                'acceptance_breakdown' => $acceptanceStats,
                'type_breakdown' => $typeBreakdown, // New for Type Pie Chart
                'trend' => $serviceTrend, // New for Chart
                'top_services' => $topServices, // New for Top List
            ],
            // Revenue removed as per request
            'mechanics' => $mechanicStats,
            'customers' => [
                'served_count' => $totalCustomersServed,
            ]
        ]);
    }
}

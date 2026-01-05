<?php

namespace App\Services;

use App\Models\Employment;
use App\Models\Service;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;

class StaffPerformanceService
{
    /**
     * Get performance metrics for all staff in a workshop
     */
    public function getStaffPerformance(string $workshopUuid, string $range = 'month', array $filters = []): array
    {
        // 1. Get all employees for this workshop with their user data
        $employees = Employment::where('workshop_uuid', $workshopUuid)
            ->with('user')
            ->get();

        // 2. Calculate date range
        [$startDate, $endDate] = $this->calculateDateRange($range, $filters);

        // 3. Calculate metrics for each staff
        $performanceData = $employees->map(function ($employee) use ($startDate, $endDate) {
            if (!$employee->user) {
                return null;
            }

            return $this->calculateMetrics($employee, $startDate, $endDate);
        })->filter()->values();

        return [
            'data' => $performanceData,
            'meta' => [
                'range' => $range,
                'period' => $this->getPeriodLabel($range, $startDate),
                'total_staff' => $performanceData->count(),
            ]
        ];
    }

    /**
     * Get performance metrics for a specific staff member
     */
    public function getIndividualPerformance(string $workshopUuid, string $userId, string $range = 'month'): ?array
    {
        $employee = Employment::where('workshop_uuid', $workshopUuid)
            ->where('user_uuid', $userId)
            ->with('user')
            ->first();

        if (!$employee || !$employee->user) {
            return null;
        }

        [$startDate, $endDate] = $this->calculateDateRange($range);
        $metrics = $this->calculateMetrics($employee, $startDate, $endDate);

        // Add more detailed data for individual view if needed
        // For example, list of completed jobs in this period
        $completedJobs = Service::where('mechanic_uuid', $employee->id)
            ->where('status', 'completed')
            ->whereBetween('completed_at', [$startDate, $endDate])
            ->orderByDesc('completed_at')
            ->limit(10)
            ->get()
            ->map(function ($service) {
                return [
                    'id' => $service->id,
                    'code' => $service->code,
                    'name' => $service->name,
                    'price' => (float) $service->price,
                    'completed_at' => $service->completed_at,
                ];
            });

        $metrics['completed_jobs'] = $completedJobs;

        return $metrics;
    }

    /**
     * Calculate metrics for an employment within a date range
     */
    private function calculateMetrics(Employment $employment, Carbon $startDate, Carbon $endDate): array
    {
        $user = $employment->user;

        // Get services assigned to this employment (mechanic) within date range
        // Use mechanic_uuid which references employment.id

        // Completed jobs
        $completedServices = Service::where('mechanic_uuid', $employment->id)
            ->where('status', 'completed')
            ->whereBetween('completed_at', [$startDate, $endDate])
            ->get();

        // Active jobs (pending, in progress, accept) - currently active
        $activeServices = Service::where('mechanic_uuid', $employment->id)
            ->whereIn('status', ['pending', 'in progress', 'accept'])
            ->get();

        $totalRevenue = $completedServices->sum('price');

        return [
            'staff_id' => $user->id,
            'staff_name' => $user->name,
            'role' => $employment->jobdesk ?? 'Staff',
            'photo_url' => $user->photo,
            'metrics' => [
                'total_jobs_completed' => $completedServices->count(),
                'total_revenue' => (float) $totalRevenue,
                'active_jobs' => $activeServices->count(),
                'average_revenue_per_job' => $completedServices->count() > 0
                    ? round($totalRevenue / $completedServices->count(), 2)
                    : 0,
            ],
        ];
    }

    /**
     * Calculate start and end dates based on range
     */
    private function calculateDateRange(string $range, array $filters = []): array
    {
        $now = Carbon::now();

        switch ($range) {
            case 'today':
                return [
                    $now->copy()->startOfDay(),
                    $now->copy()->endOfDay()
                ];
            case 'week':
                return [
                    $now->copy()->startOfWeek(),
                    $now->copy()->endOfWeek()
                ];
            case 'month':
                if (isset($filters['month']) && isset($filters['year'])) {
                    $date = Carbon::createFromDate($filters['year'], $filters['month'], 1);
                    return [
                        $date->copy()->startOfMonth(),
                        $date->copy()->endOfMonth()
                    ];
                }
                return [
                    $now->copy()->startOfMonth(),
                    $now->copy()->endOfMonth()
                ];
            default:
                return [
                    $now->copy()->startOfMonth(),
                    $now->copy()->endOfMonth()
                ];
        }
    }

    private function getPeriodLabel(string $range, Carbon $startDate): string
    {
        if ($range === 'today') {
            return $startDate->format('d M Y');
        }
        if ($range === 'week') {
            return $startDate->format('d M') . ' - ' . $startDate->copy()->endOfWeek()->format('d M Y');
        }
        return $startDate->format('F Y');
    }
}

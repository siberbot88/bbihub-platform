<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Traits\ApiResponseTrait;
use App\Models\Employment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminEmployeeController extends Controller
{
    use ApiResponseTrait;

    /**
     * Get mechanic performance stats (Dashboard).
     * 
     * GET /api/v1/admins/mechanics/performance?range=today|week|month
     */
    public function getMechanicPerformance(Request $request): JsonResponse
    {
        $user = $request->user();
        $workshopId = $user->employment?->workshop_uuid;

        if (!$workshopId) {
            return $this->errorResponse('User tidak terdaftar di bengkel manapun', 403);
        }

        $range = $request->input('range', 'today');
        $startDate = match ($range) {
            'week' => now()->startOfWeek(),
            'month' => now()->startOfMonth(),
            default => now()->startOfDay(), // today
        };
        $endDate = now()->endOfDay();

        $mechanics = Employment::query()
            ->where('workshop_uuid', $workshopId)
            ->whereHas('user.roles', function ($q) {
                $q->where('name', 'mechanic');
            })
            ->whereDoesntHave('user.roles', function ($q) {
                $q->whereIn('name', ['admin', 'owner']);
            })
            ->with(['user:id,name,email,photo'])
            ->get()
            ->map(function ($mechanic) use ($startDate, $endDate) {
                // 1. Jobs Done (Completed Services in range)
                $services = \App\Models\Service::where('mechanic_uuid', $mechanic->id)
                    ->where('status', 'completed')
                    ->whereBetween('completed_at', [$startDate, $endDate])
                    ->get();

                $jobsCount = $services->count();

                // 2. Avg Service Time (Hours)
                $totalSeconds = 0;
                $countTime = 0;
                foreach ($services as $srv) {
                    if ($srv->accepted_at && $srv->completed_at) {
                        $diff = $srv->completed_at->diffInSeconds($srv->accepted_at);
                        $totalSeconds += $diff;
                        $countTime++;
                    }
                }
                $avgHours = $countTime > 0 ? round(($totalSeconds / $countTime) / 3600, 1) : 0;

                // 3. Rating (From Feedback of transactions in range)
                // Filter feedback by submission date in range
                $avgRating = \App\Models\Feedback::whereHas('transaction', function ($q) use ($mechanic) {
                    $q->where('mechanic_uuid', $mechanic->id);
                })
                    ->whereBetween('submitted_at', [$startDate, $endDate])
                    ->avg('rating');

                return [
                    'id' => $mechanic->id, // Mechanic ID (T0001 style not in DB, using UUID or code?) Employment has no code?
                    // Generate pseudo-ID or use code if exists. User model might not have code.
                    // Employment doesn't have code in default migration.
                    // Let's use a substring of UUID or just "MECH"
                    'display_id' => 'MECH-' . substr($mechanic->id, 0, 4),
                    'name' => $mechanic->user->name,
                    'role' => 'Technician', // Static for now, or fetch from somewhere
                    'rating' => (float) ($avgRating ?? 0),
                    'jobs_today' => $jobsCount, // Key matches expected UI label concept
                    'avg_hours' => $avgHours,
                    'avatar' => $mechanic->user->photo_url ?? 'https://ui-avatars.com/api/?name=' . urlencode($mechanic->user->name),
                ];
            })
            // Sort by jobs count desc
            ->sortByDesc('jobs_today')
            ->values();

        return $this->successResponse('Data performa mekanik', $mechanics);
    }

    /**
     * Get list of mechanics for assignment (with active service count).
     * 
     * GET /api/v1/admins/mechanics
     */
    public function getMechanics(Request $request): JsonResponse
    {
        $user = $request->user();
        $workshopId = $user->employment?->workshop_uuid;

        if (!$workshopId) {
            return $this->errorResponse('User tidak terdaftar di bengkel manapun', 403);
        }

        // Get mechanics in this workshop with counts of active services
        $mechanics = Employment::query()
            ->where('workshop_uuid', $workshopId)
            ->whereHas('user.roles', function ($q) {
                $q->where('name', 'mechanic');
            })
            ->whereDoesntHave('user.roles', function ($q) {
                $q->whereIn('name', ['admin', 'owner']);
            })
            ->with(['user:id,name,email,photo']) // Load minimal user data
            ->withCount([
                'services as active_services_count' => function ($q) {
                    $q->where('status', 'in progress');
                }
            ])
            ->get()
            ->map(function ($mechanic) {
                // Calculate slots
                $maxSlots = 5;
                $currentActive = $mechanic->active_services_count;
                $availableSlots = max(0, $maxSlots - $currentActive);

                return [
                    'id' => $mechanic->id,
                    'user_id' => $mechanic->user_uuid,
                    'name' => $mechanic->user->name,
                    'email' => $mechanic->user->email,
                    'photo_url' => $mechanic->user->photo_url, // Accessor from User model
                    'active_services_count' => $currentActive,
                    'max_slots' => $maxSlots,
                    'available_slots' => $availableSlots,
                    'is_available' => $availableSlots > 0,
                ];
            });

        return $this->successResponse('Data mekanik berhasil diambil', $mechanics);
    }
}

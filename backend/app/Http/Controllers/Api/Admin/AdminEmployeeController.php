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

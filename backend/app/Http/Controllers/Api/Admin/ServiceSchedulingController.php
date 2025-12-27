<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\AcceptServiceRequest;
use App\Http\Requests\Admin\RejectServiceRequest;
use App\Http\Requests\Admin\StoreWalkInServiceRequest;
use App\Http\Traits\ApiResponseTrait;
use App\Services\AdminServiceManager;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

/**
 * Service Scheduling Controller
 * 
 * Handles pending services (booking) for admin.
 */
class ServiceSchedulingController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private AdminServiceManager $serviceManager
    ) {
    }

    /**
     * Get scheduled services (pending bookings) grouped by date.
     * 
     * GET /api/v1/admin/services/schedule?date=2025-12-25&page=1
     */
    public function index(Request $request): JsonResponse
    {
        try {
            // Get admin's workshop
            $user = $request->user();
            $workshopId = $user->employment?->workshop_uuid;

            if (!$workshopId) {
                return $this->errorResponse(
                    'User tidak terdaftar sebagai admin bengkel',
                    403
                );
            }

            // Parse date filter
            $date = $request->has('date')
                ? Carbon::parse($request->date)
                : null;

            $perPage = $request->input('per_page', 15);
            $type = $request->input('type');

            $result = $this->serviceManager->getScheduledServices($workshopId, $date, $perPage, $type);

            return $this->successResponse(
                'Data berhasil diambil',
                [
                    'grouped_services' => $result['grouped_services'],
                    'pagination' => $result['pagination']
                ]
            );
        } catch (\Exception $e) {
            Log::error('Get scheduled services failed', [
                'error' => $e->getMessage(),
                'user_id' => $request->user()->id
            ]);

            return $this->errorResponse(
                'Terjadi kesalahan saat mengambil data',
                500
            );
        }
    }

    /**
     * Accept service and assign mechanic.
     * 
     * POST /api/v1/admin/services/{id}/accept
     */
    public function accept(string $id, AcceptServiceRequest $request): JsonResponse
    {
        try {
            $user = $request->user();
            $workshopId = $user->employment?->workshop_uuid;

            if (!$workshopId) {
                return $this->errorResponse(
                    'User tidak terdaftar sebagai admin bengkel',
                    403
                );
            }

            $service = $this->serviceManager->acceptService(
                $id,
                $request->mechanic_uuid,
                $user
            );

            return $this->successResponse(
                'Service berhasil diterima dan ditugaskan ke mekanik',
                $service
            );
        } catch (\Exception $e) {
            Log::error('Accept service failed', [
                'service_id' => $id,
                'error' => $e->getMessage(),
                'user_id' => $request->user()->id
            ]);

            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Reject service with reason.
     * 
     * POST /api/v1/admin/services/{id}/reject
     */
    public function reject(string $id, RejectServiceRequest $request): JsonResponse
    {
        try {
            $user = $request->user();

            $service = $this->serviceManager->rejectService(
                $id,
                $request->reason,
                $request->reason_description,
                $user
            );

            return $this->successResponse(
                'Service berhasil ditolak',
                $service
            );
        } catch (\Exception $e) {
            Log::error('Reject service failed', [
                'service_id' => $id,
                'error' => $e->getMessage(),
                'user_id' => $request->user()->id
            ]);

            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Create walk-in service.
     * 
     * POST /api/v1/admin/services/walk-in
     */
    public function storeWalkIn(StoreWalkInServiceRequest $request): JsonResponse
    {
        try {
            $user = $request->user();
            $workshopId = $user->employment?->workshop_uuid;

            if (!$workshopId) {
                return $this->errorResponse(
                    'User tidak terdaftar sebagai admin bengkel',
                    403
                );
            }

            // Merge workshop_uuid into data
            $data = array_merge($request->validated(), [
                'workshop_uuid' => $workshopId,
            ]);

            $service = $this->serviceManager->createWalkInService($data, $user);

            return $this->successResponse(
                'Walk-in service berhasil dibuat',
                $service,
                201
            );
        } catch (\Exception $e) {
            Log::error('Create walk-in service failed', [
                'error' => $e->getMessage(),
                'user_id' => $request->user()->id
            ]);

            return $this->errorResponse(
                'Gagal membuat walk-in service: ' . $e->getMessage(),
                400
            );
        }
    }
}

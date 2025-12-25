<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\CreateInvoiceRequest;
use App\Http\Traits\ApiResponseTrait;
use App\Services\AdminServiceManager;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

/**
 * Service Logging Controller
 * 
 * Handles in-progress and completed services.
 */
class ServiceLoggingController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private AdminServiceManager $serviceManager
    ) {
    }

    /**
     * Get active (in-progress) services.
     * 
     * GET /api/v1/admin/services/active?page=1
     */
    public function index(Request $request): JsonResponse
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

            $perPage = $request->input('per_page', 15);
            $services = $this->serviceManager->getActiveServices($workshopId, $perPage);

            return $this->successResponse(
                'Data berhasil diambil',
                [
                    'services' => $services->items(),
                    'pagination' => [
                        'current_page' => $services->currentPage(),
                        'per_page' => $services->perPage(),
                        'total' => $services->total(),
                        'last_page' => $services->lastPage(),
                    ]
                ]
            );
        } catch (\Exception $e) {
            Log::error('Get active services failed', [
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
     * Mark service as completed.
     * 
     * PATCH /api/v1/admin/services/{id}/complete
     */
    public function complete(string $id, Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            $service = $this->serviceManager->completeService($id, $user);

            return $this->successResponse(
                'Service berhasil diselesaikan',
                $service
            );
        } catch (\Exception $e) {
            Log::error('Complete service failed', [
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
     * Create invoice for service.
     * 
     * POST /api/v1/admin/services/{id}/invoice
     */
    public function createInvoice(string $id, CreateInvoiceRequest $request): JsonResponse
    {
        try {
            $user = $request->user();

            $transaction = $this->serviceManager->createServiceInvoice(
                $id,
                $request->items,
                $user
            );

            return $this->successResponse(
                'Invoice berhasil dibuat',
                [
                    'transaction_id' => $transaction->id,
                    'invoice_code' => $transaction->invoice_code,
                    'service_id' => $id,
                    'total' => $transaction->total,
                    'items' => $transaction->items,
                    'status' => $transaction->status,
                    // TODO: Add Midtrans payment_url here
                ],
                201
            );
        } catch (\Exception $e) {
            Log::error('Create invoice failed', [
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
     * Get invoice by service ID.
     * 
     * GET /api/v1/admin/services/{id}/invoice
     */
    public function getInvoice(string $id, Request $request): JsonResponse
    {
        try {
            $invoice = $this->serviceManager->getServiceInvoice($id);

            if (!$invoice) {
                return $this->errorResponse(
                    'Invoice tidak ditemukan',
                    404
                );
            }

            return $this->successResponse(
                'Invoice berhasil diambil',
                $invoice
            );
        } catch (\Exception $e) {
            Log::error('Get invoice failed', [
                'service_id' => $id,
                'error' => $e->getMessage(),
                'user_id' => $request->user()->id
            ]);

            return $this->errorResponse(
                'Terjadi kesalahan saat mengambil invoice',
                500
            );
        }
    }
}

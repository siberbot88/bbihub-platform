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

            $invoice = $this->serviceManager->createInvoice(
                $id,
                $request->items,
                $user,
                $request->tax,
                $request->discount,
                $request->notes
            );

            return $this->successResponse(
                'Invoice berhasil dibuat',
                [
                    'invoice_id' => $invoice->id,
                    'invoice_code' => $invoice->invoice_code,
                    'service_id' => $id,
                    'subtotal' => $invoice->subtotal,
                    'tax' => $invoice->tax,
                    'discount' => $invoice->discount,
                    'total' => $invoice->total,
                    'items' => $invoice->items,
                    'status' => $invoice->status,
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

    /**
     * Process cash payment for on-site service invoices.
     * 
     * POST /api/v1/admin/invoices/{id}/cash-payment
     */
    public function processCashPayment(string $id, Request $request): JsonResponse
    {
        $request->validate([
            'amount_paid' => ['required', 'numeric', 'min:0'],
        ]);

        try {
            $user = $request->user();
            $invoice = \App\Models\Invoice::find($id);

            if (!$invoice) {
                return $this->errorResponse('Invoice tidak ditemukan', 404);
            }

            if ($invoice->status === 'paid') {
                return $this->errorResponse('Invoice sudah dibayar', 400);
            }

            $amountPaid = $request->amount_paid;
            $change = $amountPaid - $invoice->total;

            if ($change < 0) {
                return $this->errorResponse('Jumlah pembayaran kurang', 400);
            }

            // Update invoice status
            $invoice->update([
                'status' => 'paid',
                'sent_at' => $invoice->sent_at ?? now(),
            ]);

            // Update Service status to 'lunas' and set completed_at if not already set
            if ($invoice->service_uuid) {
                \App\Models\Service::where('id', $invoice->service_uuid)->update([
                    'status' => 'lunas',
                    'completed_at' => \DB::raw('COALESCE(completed_at, NOW())'), // Set if null
                ]);
            }

            // Create Transaction record for payment tracking
            // Get mechanic info from service for accountability
            $service = \App\Models\Service::find($invoice->service_uuid);

            $transaction = \App\Models\Transaction::create([
                'id' => (string) \Illuminate\Support\Str::uuid(),
                'invoice_uuid' => $invoice->id,
                'service_uuid' => $invoice->service_uuid,
                'customer_uuid' => $invoice->customer_uuid,
                'workshop_uuid' => $invoice->workshop_uuid,
                'admin_uuid' => $user->id,
                'mechanic_uuid' => $service?->mechanic_uuid, // Track mechanic for accountability
                'status' => 'success',
                'amount' => $invoice->total,
                'payment_method' => 'cash',
            ]);

            return $this->successResponse(
                'Pembayaran berhasil diproses',
                [
                    'invoice' => $invoice,
                    'transaction' => $transaction,
                    'amount_paid' => $amountPaid,
                    'change' => $change,
                ]
            );
        } catch (\Exception $e) {
            Log::error('Process cash payment failed', [
                'invoice_id' => $id,
                'error' => $e->getMessage(),
            ]);

            return $this->errorResponse(
                'Gagal memproses pembayaran: ' . $e->getMessage(),
                500
            );
        }
    }
}

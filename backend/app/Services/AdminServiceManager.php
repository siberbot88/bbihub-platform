<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Models\Customer;
use App\Models\Service;
use App\Models\Transaction;
use App\Models\Vehicle;
use App\Repositories\ServiceRepository;
use App\Repositories\TransactionRepository;
use Carbon\Carbon;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Admin Service Manager
 * 
 * Handles business logic for admin service management.
 * Follows Service Layer pattern for clean architecture.
 */
class AdminServiceManager
{
    public function __construct(
        private ServiceRepository $serviceRepo,
        private TransactionRepository $transactionRepo
    ) {
    }

    /**
     * Get scheduled services (pending) grouped by date.
     * 
     * @param string $workshopId
     * @param Carbon|null $date
     * @param int $perPage
     * @return array
     */
    public function getScheduledServices(
        string $workshopId,
        ?Carbon $date = null,
        int $perPage = 15
    ): array {
        $services = $this->serviceRepo->getPendingServices($workshopId, $date, $perPage);

        // Group services by date
        $grouped = $services->getCollection()->groupBy(function ($service) {
            return $service->scheduled_date->format('Y-m-d');
        });

        return [
            'grouped_services' => $grouped,
            'pagination' => [
                'current_page' => $services->currentPage(),
                'per_page' => $services->perPage(),
                'total' => $services->total(),
                'last_page' => $services->lastPage(),
            ]
        ];
    }

    /**
     * Get active (in-progress) services for service logging.
     * 
     * @param string $workshopId
     * @param int $perPage
     * @return LengthAwarePaginator
     */
    public function getActiveServices(string $workshopId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->serviceRepo->getInProgressServices($workshopId, $perPage);
    }

    /**
     * Accept service and assign to mechanic.
     * 
     * @param string $serviceId
     * @param string $mechanicId
     * @param string $adminId Admin who accepted
     * @return Service
     * @throws \Exception
     */
    public function acceptService(string $serviceId, string $mechanicId, string $adminId): Service
    {
        try {
            $service = $this->serviceRepo->acceptService($serviceId, $mechanicId);

            // Audit log
            AuditLog::log(
                event: 'service_accepted',
                user: $adminId,
                auditable: $service,
                old_values: ['acceptance_status' => 'pending', 'status' => 'pending'],
                new_values: ['acceptance_status' => 'accepted', 'status' => 'in progress', 'mechanic_uuid' => $mechanicId]
            );

            return $service;
        } catch (\Exception $e) {
            throw new \Exception('Gagal menerima service: ' . $e->getMessage());
        }
    }

    /**
     * Reject service with reason.
     * 
     * @param string $serviceId
     * @param string $reason
     * @param string $description
     * @param string $adminId
     * @return Service
     * @throws \Exception
     */
    public function rejectService(
        string $serviceId,
        string $reason,
        string $description,
        string $adminId
    ): Service {
        try {
            $service = $this->serviceRepo->rejectService($serviceId, $reason, $description);

            // Audit log
            AuditLog::log(
                event: 'service_rejected',
                user: $adminId,
                auditable: $service,
                old_values: ['acceptance_status' => 'pending'],
                new_values: ['acceptance_status' => 'decline', 'reason' => $reason]
            );

            // TODO: Send notification to customer about rejection

            return $service;
        } catch (\Exception $e) {
            throw new \Exception('Gagal menolak service: ' . $e->getMessage());
        }
    }

    /**
     * Complete service (mark as done).
     * 
     * @param string $serviceId
     * @param string $adminId
     * @return Service
     * @throws \Exception
     */
    public function completeService(string $serviceId, string $adminId): Service
    {
        try {
            $service = $this->serviceRepo->updateStatus($serviceId, 'completed');

            // Audit log
            AuditLog::log(
                event: 'service_completed',
                user: $adminId,
                auditable: $service,
                old_values: ['status' => 'in progress'],
                new_values: ['status' => 'completed', 'completed_at' => now()]
            );

            return $service;
        } catch (\Exception $e) {
            throw new \Exception('Gagal menyelesaikan service: ' . $e->getMessage());
        }
    }

    /**
     * Create walk-in service with customer and vehicle data.
     * 
     * @param array $data
     * @param string $adminId
     * @return Service
     * @throws \Exception
     */
    public function createWalkInService(array $data, string $adminId): Service
    {
        return DB::transaction(function () use ($data, $adminId) {
            // 1. Create or find customer
            $customer = Customer::firstOrCreate(
                ['phone' => $data['customer_phone']],
                [
                    'id' => Str::uuid(),
                    'name' => $data['customer_name'],
                    'email' => $data['customer_email'] ?? null,
                ]
            );

            // 2. Create or find vehicle
            $vehicle = Vehicle::firstOrCreate(
                [
                    'customer_uuid' => $customer->id,
                    'plate_number' => strtoupper($data['vehicle_plate'])
                ],
                [
                    'id' => Str::uuid(),
                    'brand' => $data['vehicle_brand'],
                    'model' => $data['vehicle_model'],
                    'year' => $data['vehicle_year'] ?? null,
                    'type' => $data['vehicle_type'] ?? 'matic',
                    'category' => $data['vehicle_category'] ?? 'motor',
                ]
            );

            // 3. Create service
            $service = $this->serviceRepo->createWalkInService([
                'workshop_uuid' => $data['workshop_uuid'],
                'customer_uuid' => $customer->id,
                'vehicle_uuid' => $vehicle->id,
                'service_name' => $data['service_name'],
                'service_description' => $data['service_description'] ?? '',
                'scheduled_date' => $data['scheduled_date'] ?? now(),
            ]);

            // Audit log
            AuditLog::log(
                event: 'walk_in_service_created',
                user: $adminId,
                auditable: $service
            );

            return $service;
        });
    }

    /**
     * Create invoice for completed service.
     * 
     * @param string $serviceId
     * @param array $items
     * @param string $adminId
     * @return Transaction
     * @throws \Exception
     */
    public function createServiceInvoice(
        string $serviceId,
        array $items,
        string $adminId
    ): Transaction {
        try {
            // Validate service is completed
            $service = $this->serviceRepo->findById($serviceId);

            if (!$service) {
                throw new \Exception('Service tidak ditemukan');
            }

            if ($service->status !== 'completed') {
                throw new \Exception('Service harus completed sebelum bisa membuat invoice');
            }

            // Check if invoice already exists
            if ($service->transaction) {
                throw new \Exception('Invoice sudah dibuat untuk service ini');
            }

            // Create invoice
            $transaction = $this->transactionRepo->createInvoice($serviceId, $adminId, $items);

            // Audit log
            AuditLog::log(
                event: 'invoice_created',
                user: $adminId,
                auditable: $transaction
            );

            // TODO: Integrate with Midtrans to get payment URL
            // TODO: Send notification to customer with payment link

            return $transaction;
        } catch (\Exception $e) {
            throw new \Exception('Gagal membuat invoice: ' . $e->getMessage());
        }
    }

    /**
     * Get invoice details by service ID.
     * 
     * @param string $serviceId
     * @return Transaction|null
     */
    public function getServiceInvoice(string $serviceId): ?Transaction
    {
        return $this->transactionRepo->getInvoiceByService($serviceId);
    }
}

<?php

namespace App\Services;

use App\Events\ServiceBookingReceived;
use App\Events\ServiceStatusChanged;
use App\Models\AuditLog;
use App\Models\Customer;
use App\Models\Service;
use App\Models\Transaction;
use App\Models\User;
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
        private TransactionRepository $transactionRepo,
        private ServiceLogger $logger
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
        int $perPage = 15,
        ?string $type = null,
        ?string $dateFrom = null,
        ?string $dateTo = null
    ): array {
        $services = $this->serviceRepo->getPendingServices($workshopId, $date, $perPage, $type, $dateFrom, $dateTo);

        // Group services by date
        $grouped = collect($services->items())->groupBy(function ($service) {
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
    public function getActiveServices(
        string $workshopId,
        int $perPage = 15,
        ?string $dateFrom = null,
        ?string $dateTo = null
    ): LengthAwarePaginator {
        return $this->serviceRepo->getInProgressServices($workshopId, $perPage, $dateFrom, $dateTo);
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
    public function acceptService(string $serviceId, ?string $mechanicId, ?User $admin = null): Service
    {
        try {
            $service = $this->serviceRepo->acceptService($serviceId, $mechanicId);

            // Audit log
            AuditLog::log(
                event: 'service_accepted',
                user: $admin,
                auditable: $service,
                oldValues: ['acceptance_status' => 'pending', 'status' => 'pending'],
                newValues: ['acceptance_status' => 'accepted', 'status' => 'in progress', 'mechanic_uuid' => $mechanicId]
            );

            // Dispatch event for notification
            event(new ServiceStatusChanged($service, 'pending', 'in progress'));

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
        ?User $admin = null
    ): Service {
        try {
            $service = $this->serviceRepo->rejectService($serviceId, $reason, $description);

            // Audit log
            AuditLog::log(
                event: 'service_rejected',
                user: $admin,
                auditable: $service,
                oldValues: ['acceptance_status' => 'pending'],
                newValues: ['acceptance_status' => 'decline', 'reason' => $reason]
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
    public function completeService(string $serviceId, ?User $admin = null): Service
    {
        try {
            $service = $this->serviceRepo->updateStatus($serviceId, 'completed');

            // Use ServiceLogger
            $this->logger->logCompletion($service, $admin);

            // Audit log
            AuditLog::log(
                event: 'service_completed',
                user: $admin,
                auditable: $service,
                oldValues: ['status' => 'in progress'],
                newValues: ['status' => 'completed', 'completed_at' => now()]
            );

            // Dispatch event for notification
            event(new ServiceStatusChanged($service, 'in progress', 'completed'));

            return $service;
        } catch (\Exception $e) {
            throw new \Exception('Gagal menyelesaikan service: ' . $e->getMessage());
        }
    }

    /**
     * Create walk-in service with customer and vehicle data.
     * 
     * @param array $data
     * @param User|null $admin
     * @return Service
     * @throws \Exception
     */
    public function createWalkInService(array $data, ?User $admin = null): Service
    {
        return DB::transaction(function () use ($data, $admin) {
            // 1. Create or find customer
            $customer = Customer::firstOrCreate(
                ['phone' => $data['customer_phone']],
                [
                    'id' => Str::uuid(),
                    'code' => 'CUST-' . strtoupper(Str::random(8)),
                    'name' => $data['customer_name'],
                    'email' => $data['customer_email'] ?? '', // Default empty for walk-in
                    'address' => $data['customer_address'] ?? '', // Default empty for walk-in
                ]
            );

            // 2. Create or update vehicle (since we have more details now)
            $vehicle = Vehicle::updateOrCreate(
                [
                    'customer_uuid' => $customer->id,
                    'plate_number' => strtoupper($data['vehicle_plate'])
                ],
                [
                    'id' => Str::uuid(), // Only used if creating
                    'code' => 'VEH-' . strtoupper(Str::random(5)),
                    'name' => $data['vehicle_brand'] . ' ' . $data['vehicle_model'], // Auto-generate from brand + model
                    'brand' => $data['vehicle_brand'],
                    'model' => $data['vehicle_model'],
                    'year' => $data['vehicle_year'], // Required now
                    'color' => $data['vehicle_color'], // New field
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
                'estimated_time' => $data['estimated_time'] ?? now()->addHours(2), // Default 2 hours from now
                // 'image_path' => $imagePath, // REMOVED: Managed by Spatie
            ]);

            // 4. Handle Image Upload (Spatie Media Library)
            if (isset($data['image']) && $data['image'] instanceof \Illuminate\Http\UploadedFile) {
                \Illuminate\Support\Facades\Log::info('Uploading image for service', ['service_id' => $service->id]);
                $service->addMedia($data['image'])
                    ->toMediaCollection('service_image');

                // Refresh relations to include the new media
                $service->load('media');
            } else {
                \Illuminate\Support\Facades\Log::info('No image uploaded for service', ['data_image_set' => isset($data['image'])]);
            }

            // Audit log
            AuditLog::log(
                event: 'walk_in_service_created',
                user: $admin,
                auditable: $service
            );

            // Dispatch event for notification (new booking)
            event(new ServiceBookingReceived($service));

            return $service;
        });
    }

    /**
     * Create invoice for completed service with new Invoice system.
     * 
     * @param string $serviceId
     * @param array $items
     * @param User|null $admin
     * @param float|null $tax
     * @param float|null $discount
     * @param string|null $notes
     * @return \App\Models\Invoice
     * @throws \Exception
     */
    public function createInvoice(
        string $serviceId,
        array $items,
        ?User $admin = null,
        ?float $tax = null,
        ?float $discount = null,
        ?string $notes = null
    ): \App\Models\Invoice {
        return DB::transaction(function () use ($serviceId, $items, $admin, $tax, $discount, $notes) {
            $service = $this->serviceRepo->findById($serviceId);

            if (!$service) {
                throw new \Exception('Service tidak ditemukan');
            }

            if ($service->status !== 'completed') {
                throw new \Exception('Service harus selesai sebelum membuat invoice');
            }

            $existingInvoice = \App\Models\Invoice::where('service_uuid', $serviceId)->first();
            if ($existingInvoice) {
                throw new \Exception('Invoice sudah dibuat');
            }

            // Generate invoice code
            $lastInvoice = \App\Models\Invoice::whereDate('created_at', today())
                ->orderBy('invoice_code', 'desc')->lockForUpdate()->first();

            $nextNum = 1;
            if ($lastInvoice && preg_match('/^INV-\d{8}-(\d{5})$/', $lastInvoice->invoice_code, $matches)) {
                $nextNum = (int) $matches[1] + 1;
            }

            $invoiceCode = 'INV-' . date('Ymd') . '-' . str_pad((string) $nextNum, 5, '0', STR_PAD_LEFT);

            // Calculate amounts
            $subtotal = 0;
            foreach ($items as $item) {
                $subtotal += $item['quantity'] * $item['unit_price'];
            }

            $taxAmount = $tax ?? 0;
            $discountAmount = $discount ?? 0;
            $total = $subtotal + $taxAmount - $discountAmount;

            // Create Invoice
            $invoice = \App\Models\Invoice::create([
                'id' => (string) Str::uuid(),
                'invoice_code' => $invoiceCode,
                'service_uuid' => $service->id,
                'workshop_uuid' => $service->workshop_uuid,
                'customer_uuid' => $service->customer_uuid,
                'created_by' => $admin?->id,
                'subtotal' => $subtotal,
                'tax' => $taxAmount,
                'discount' => $discountAmount,
                'total' => $total,
                'status' => 'draft',
                'notes' => $notes,
            ]);

            // Create Invoice Items
            foreach ($items as $item) {
                \App\Models\InvoiceItem::create([
                    'id' => (string) Str::uuid(),
                    'invoice_uuid' => $invoice->id,
                    'type' => $item['type'],
                    'name' => $item['name'],
                    'description' => $item['description'] ?? null,
                    'quantity' => $item['quantity'],
                    'unit_price' => $item['unit_price'],
                    'subtotal' => $item['quantity'] * $item['unit_price'],
                ]);
            }

            // Update status based on service type
            if ($service->type === 'booking') {
                $invoice->update(['status' => 'sent', 'sent_at' => now()]);
            }

            // Use ServiceLogger
            $this->logger->logInvoiceCreation($service, $invoice->id, $admin);

            AuditLog::log(event: 'invoice_created', user: $admin, auditable: $invoice);

            return $invoice->load('items');
        });
    }

    /**
     * @deprecated Use createInvoice instead
     * Create invoice for completed service.
     * 
     * @param string $serviceId
     * @param array $items
     * @param User|null $admin
     * @return Transaction
     * @throws \Exception
     */
    public function createServiceInvoice(
        string $serviceId,
        array $items,
        ?User $admin = null
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
            $transaction = $this->transactionRepo->createInvoice($serviceId, $admin?->id, $items);

            // Audit log
            AuditLog::log(
                event: 'invoice_created',
                user: $admin,
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
     * @return \App\Models\Invoice|null
     */
    public function getServiceInvoice(string $serviceId): ?\App\Models\Invoice
    {
        return \App\Models\Invoice::where('service_uuid', $serviceId)
            ->with(['items', 'service.vehicle', 'customer', 'workshop'])
            ->first();
    }
}

<?php

namespace App\Repositories;

use App\Models\Service;
use Carbon\Carbon;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

/**
 * Service Repository
 * 
 * Handles all database operations for services.
 * Follows Repository pattern for clean architecture.
 */
class ServiceRepository
{
    /**
     * Get pending services grouped by date for scheduling view.
     * 
     * @param string $workshopId
     * @param Carbon|null $date Filter by specific date
     * @param int $perPage
     * @return LengthAwarePaginator
     */
    public function getPendingServices(
        string $workshopId,
        ?Carbon $date = null,
        int $perPage = 15,
        ?string $type = null,
        ?string $dateFrom = null,
        ?string $dateTo = null
    ): LengthAwarePaginator {
        $query = Service::with(['customer', 'vehicle'])
            ->where('workshop_uuid', $workshopId)
            ->where('status', 'pending') // Show all pending services (Accepted or Not)
            ->orderBy('scheduled_date', 'asc')
            ->orderBy('created_at', 'asc');

        // Filter by specific date if provided
        if ($date) {
            $query->whereDate('scheduled_date', $date);
        }

        // Filter by date range if provided
        // Filter by date range if provided
        if ($dateFrom && $dateTo) {
            $query->whereBetween('scheduled_date', [
                Carbon::parse($dateFrom)->startOfDay(),
                Carbon::parse($dateTo)->endOfDay()
            ]);
        } elseif ($dateFrom) {
            $query->whereDate('scheduled_date', '>=', $dateFrom);
        } elseif ($dateTo) {
            $query->whereDate('scheduled_date', '<=', $dateTo);
        }

        // Filter by type if provided
        if ($type) {
            // Map frontend 'ditempat' to database 'on-site'
            if ($type === 'ditempat') {
                $type = 'on-site';
            }
            $query->where('type', $type);

            // Refinement: Booking must have acceptance_status 'pending'
            if ($type === 'booking') {
                $query->where(function ($q) {
                    $q->where('acceptance_status', 'pending')
                        ->orWhereNull('acceptance_status');
                });
            }
        }

        return $query->paginate($perPage);
    }

    /**
     * Get in-progress services for service logging view.
     * 
     * @param string $workshopId
     * @param int $perPage
     * @return LengthAwarePaginator
     */
    public function getInProgressServices(
        string $workshopId,
        int $perPage = 15,
        ?string $dateFrom = null,
        ?string $dateTo = null
    ): LengthAwarePaginator {
        $query = Service::with(['customer', 'vehicle', 'mechanic.user', 'invoice.items'])
            ->where('workshop_uuid', $workshopId)
            ->where('acceptance_status', 'accepted')
            ->whereIn('status', ['in progress', 'completed']) // Include completed for billing processing
            ->orderBy('accepted_at', 'desc');

        if ($dateFrom && $dateTo) {
            $query->whereBetween('scheduled_date', [
                Carbon::parse($dateFrom)->startOfDay(),
                Carbon::parse($dateTo)->endOfDay()
            ]);
        } elseif ($dateFrom) {
            $query->whereDate('scheduled_date', '>=', $dateFrom);
        } elseif ($dateTo) {
            $query->whereDate('scheduled_date', '<=', $dateTo);
        }

        return $query->paginate($perPage);
    }

    /**
     * Get completed services.
     * 
     * @param string $workshopId
     * @param int $perPage
     * @return LengthAwarePaginator
     */
    public function getCompletedServices(
        string $workshopId,
        int $perPage = 15
    ): LengthAwarePaginator {
        return Service::with(['customer', 'vehicle', 'mechanic.user', 'transaction'])
            ->where('workshop_uuid', $workshopId)
            ->where('status', 'completed')
            ->orderBy('completed_at', 'desc')
            ->paginate($perPage);
    }

    /**
     * Find service by ID with relationships.
     * 
     * @param string $serviceId
     * @return Service|null
     */
    public function findById(string $serviceId): ?Service
    {
        return Service::with(['customer', 'vehicle', 'mechanic.user', 'workshop', 'transaction'])
            ->find($serviceId);
    }

    /**
     * Accept service and assign to mechanic.
     * 
     * @param string $serviceId
     * @param string $mechanicId
     * @return Service
     */
    public function acceptService(string $serviceId, ?string $mechanicId): Service
    {
        return DB::transaction(function () use ($serviceId, $mechanicId) {
            $service = Service::lockForUpdate()->findOrFail($serviceId);

            $service->update([
                'acceptance_status' => 'accepted',
                'status' => $mechanicId ? 'in progress' : 'pending',
                'mechanic_uuid' => $mechanicId,
                'accepted_at' => now(),
            ]);

            return $service->load(['customer', 'vehicle', 'mechanic.user']);
        });
    }

    /**
     * Reject service with reason.
     * 
     * @param string $serviceId
     * @param string $reason
     * @param string $description
     * @return Service
     */
    public function rejectService(
        string $serviceId,
        string $reason,
        string $description
    ): Service {
        return DB::transaction(function () use ($serviceId, $reason, $description) {
            $service = Service::lockForUpdate()->findOrFail($serviceId);

            $service->update([
                'acceptance_status' => 'decline',
                'status' => 'pending', // Keep as pending for records
                'reason' => $reason,
                'reason_description' => $description,
            ]);

            return $service->load(['customer', 'vehicle']);
        });
    }

    /**
     * Update service status.
     * 
     * @param string $serviceId
     * @param string $status
     * @return Service
     */
    public function updateStatus(string $serviceId, string $status): Service
    {
        $service = Service::findOrFail($serviceId);

        $updateData = ['status' => $status];

        // Auto-set completed_at when status is completed
        if ($status === 'completed') {
            $updateData['completed_at'] = now();
        }

        $service->update($updateData);

        return $service->load(['customer', 'vehicle', 'mechanic.user']);
    }

    /**
     * Create walk-in (on-site) service.
     * 
     * @param array $data
     * @return Service
     */
    public function createWalkInService(array $data): Service
    {
        return DB::transaction(function () use ($data) {
            // Generate service code
            $lastService = Service::orderBy('code', 'desc')->lockForUpdate()->first();
            $nextNum = 1;

            if ($lastService && preg_match('/^SVC(\d{5})$/', $lastService->code, $matches)) {
                $nextNum = (int) $matches[1] + 1;
            }

            $code = 'SVC' . str_pad((string) $nextNum, 5, '0', STR_PAD_LEFT);

            // Create service with type 'on-site'
            $service = Service::create([
                'code' => $code,
                'workshop_uuid' => $data['workshop_uuid'],
                'customer_uuid' => $data['customer_uuid'],
                'vehicle_uuid' => $data['vehicle_uuid'],
                'name' => $data['service_name'],
                'description' => $data['service_description'] ?? '',
                'scheduled_date' => $data['scheduled_date'] ?? now(),
                'estimated_time' => $data['estimated_time'] ?? now()->addHours(2),
                'type' => 'on-site', // Auto on-site for walk-in
                'acceptance_status' => 'accepted', // Auto-accepted for walk-in/on-site
                'status' => 'pending',
                'image_path' => $data['image_path'] ?? null,
            ]);

            return $service->load(['customer', 'vehicle']);
        });
    }

    /**
     * Check if workshop owns this service.
     * 
     * @param string $serviceId
     * @param string $workshopId
     * @return bool
     */
    public function workshopOwnsService(string $serviceId, string $workshopId): bool
    {
        return Service::where('id', $serviceId)
            ->where('workshop_uuid', $workshopId)
            ->exists();
    }
}

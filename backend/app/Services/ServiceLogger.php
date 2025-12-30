<?php

namespace App\Services;

use App\Models\Service;
use App\Models\ServiceLog;
use App\Models\User;
use Illuminate\Support\Str;

/**
 * ServiceLogger
 * 
 * Centralized service to manage ServiceLog creation
 * for consistent audit trails and service state tracking.
 */
class ServiceLogger
{
    /**
     * Log service creation.
     */
    public function logCreation(Service $service, ?User $user = null): ServiceLog
    {
        return $this->createLog(
            service: $service,
            status: 'pending',
            notes: 'Service baru dibuat',
            user: $user
        );
    }

    /**
     * Log service acceptance by admin.
     */
    public function logAcceptance(Service $service, ?User $admin = null): ServiceLog
    {
        return $this->createLog(
            service: $service,
            status: 'accepted',
            notes: 'Service diterima oleh admin' . ($admin ? ': ' . $admin->name : ''),
            user: $admin
        );
    }

    /**
     * Log service rejection by admin.
     */
    public function logRejection(Service $service, string $reason, ?User $admin = null): ServiceLog
    {
        return $this->createLog(
            service: $service,
            status: 'rejected',
            notes: 'Service ditolak: ' . $reason,
            user: $admin
        );
    }

    /**
     * Log mechanic assignment.
     */
    public function logMechanicAssignment(Service $service, string $mechanicId, ?User $admin = null): ServiceLog
    {
        $mechanic = User::find($mechanicId);

        return $this->createLog(
            service: $service,
            status: 'in_progress',
            notes: 'Mekanik ditugaskan: ' . ($mechanic?->name ?? 'Unknown'),
            mechanicId: $mechanicId,
            user: $admin
        );
    }

    /**
     * Log service completion.
     */
    public function logCompletion(Service $service, ?User $admin = null): ServiceLog
    {
        return $this->createLog(
            service: $service,
            status: 'completed',
            notes: 'Service telah diselesaikan',
            user: $admin
        );
    }

    /**
     * Log invoice creation.
     */
    public function logInvoiceCreation(Service $service, string $invoiceId, ?User $admin = null): ServiceLog
    {
        $invoice = \App\Models\Invoice::find($invoiceId);

        return $this->createLog(
            service: $service,
            status: 'completed', // Status service tetap completed
            notes: 'Invoice dibuat: ' . ($invoice?->invoice_code ?? $invoiceId),
            transactionId: null, // FIX: Don't store invoice_id in transaction_uuid FK column
            user: $admin
        );
    }

    /**
     * Log payment received.
     */
    public function logPayment(Service $service, string $invoiceId, string $paymentMethod, ?User $admin = null): ServiceLog
    {
        return $this->createLog(
            service: $service,
            status: 'completed',
            notes: "Pembayaran diterima via {$paymentMethod}",
            transactionId: $invoiceId,
            user: $admin
        );
    }

    /**
     * Log service cancellation.
     */
    public function logCancellation(Service $service, string $reason, ?User $user = null): ServiceLog
    {
        return $this->createLog(
            service: $service,
            status: 'rejected', // Use 'rejected' for cancelled
            notes: 'Service dibatalkan: ' . $reason,
            user: $user
        );
    }

    /**
     * Create a service log entry.
     * 
     * @param Service $service
     * @param string $status
     * @param string $notes
     * @param string|null $mechanicId
     * @param string|null $transactionId
     * @param User|null $user User who performed the action
     * @return ServiceLog
     */
    private function createLog(
        Service $service,
        string $status,
        string $notes,
        ?string $mechanicId = null,
        ?string $transactionId = null,
        ?User $user = null
    ): ServiceLog {
        try {
            return ServiceLog::create([
                'id' => (string) Str::uuid(),
                'service_uuid' => $service->id,
                'mechanic_uuid' => $mechanicId ?? $service->mechanic_uuid,
                'transaction_uuid' => $transactionId,
                'status' => $status,
                'notes' => $notes,
            ]);
        } catch (\Illuminate\Database\QueryException $e) {
            // Check for Integrity Constraint Violation (Foreign Key) on mechanic_uuid
            // Code 23000 is for integrity constraint violation
            if ($e->getCode() === '23000' && Str::contains($e->getMessage(), 'mechanic_uuid')) {
                \Illuminate\Support\Facades\Log::warning('ServiceLog mechanic_uuid constraint failed, retrying with null', [
                    'service_id' => $service->id,
                    'invalid_mechanic_uuid' => $mechanicId ?? $service->mechanic_uuid
                ]);

                return ServiceLog::create([
                    'id' => (string) Str::uuid(),
                    'service_uuid' => $service->id,
                    'mechanic_uuid' => null, // Fallback to null
                    'transaction_uuid' => $transactionId,
                    'status' => $status,
                    'notes' => $notes,
                ]);
            }
            throw $e;
        }
    }
}

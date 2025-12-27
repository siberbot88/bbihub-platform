<?php

namespace App\Listeners;

use App\Events\ServiceBookingReceived;
use App\Events\ServiceStatusChanged;
use App\Models\Employment;
use Illuminate\Support\Facades\Notification;
use App\Notifications\ServiceNotification;

class SendServiceNotification
{
    /**
     * Handle ServiceBookingReceived event.
     */
    public function handleBookingReceived(ServiceBookingReceived $event): void
    {
        $service = $event->service;

        // Get all admins of the workshop
        $admins = Employment::where('workshop_uuid', $service->workshop_uuid)
            ->where('status', 'active')
            ->whereHas('user', function ($q) {
                $q->whereHas('roles', function ($r) {
                    $r->where('name', 'admin');
                });
            })
            ->with('user')
            ->get();

        foreach ($admins as $admin) {
            if ($admin->user) {
                $admin->user->notify(new ServiceNotification(
                    type: 'booking_received',
                    title: 'Booking Baru',
                    message: "Booking baru dari {$service->customer->name} - {$service->name}",
                    data: [
                        'service_id' => $service->id,
                        'service_code' => $service->code,
                        'customer_name' => $service->customer->name,
                        'scheduled_date' => $service->scheduled_date->format('Y-m-d'),
                    ]
                ));
            }
        }
    }

    /**
     * Handle ServiceStatusChanged event.
     */
    public function handleStatusChanged(ServiceStatusChanged $event): void
    {
        $service = $event->service;
        $oldStatus = $event->oldStatus;
        $newStatus = $event->newStatus;

        // Get all admins of the workshop
        $admins = Employment::where('workshop_uuid', $service->workshop_uuid)
            ->where('status', 'active')
            ->whereHas('user', function ($q) {
                $q->whereHas('roles', function ($r) {
                    $r->where('name', 'admin');
                });
            })
            ->with('user')
            ->get();

        $statusMessages = [
            'in progress' => 'Service sedang dikerjakan',
            'completed' => 'Service telah selesai',
            'menunggu pembayaran' => 'Menunggu pembayaran dari customer',
            'lunas' => 'Pembayaran telah lunas',
        ];

        $message = $statusMessages[$newStatus] ?? "Status berubah menjadi {$newStatus}";

        foreach ($admins as $admin) {
            if ($admin->user) {
                $admin->user->notify(new ServiceNotification(
                    type: 'status_changed',
                    title: 'Status Service Berubah',
                    message: "{$service->code} - {$message}",
                    data: [
                        'service_id' => $service->id,
                        'service_code' => $service->code,
                        'old_status' => $oldStatus,
                        'new_status' => $newStatus,
                        'customer_name' => $service->customer->name,
                    ]
                ));
            }
        }
    }
}

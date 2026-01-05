<?php

namespace App\Notifications;

use App\Models\Workshop;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Notification;

class WorkshopPendingNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(public Workshop $workshop)
    {
    }

    public function via($notifiable): array
    {
        return ['database', 'broadcast'];
    }

    public function toDatabase($notifiable): array
    {
        return [
            'type' => 'workshop_verification',
            'workshop_id' => $this->workshop->id,
            'workshop_name' => $this->workshop->name,
            'workshop_code' => $this->workshop->code,
            'message' => "Bengkel {$this->workshop->name} memerlukan verifikasi",
            'url' => route('admin.workshops.show', $this->workshop->id),
        ];
    }

    public function toBroadcast($notifiable): array
    {
        return [
            'type' => 'workshop_verification',
            'workshop_id' => $this->workshop->id,
            'workshop_name' => $this->workshop->name,
            'message' => "Bengkel {$this->workshop->name} memerlukan verifikasi",
        ];
    }
}

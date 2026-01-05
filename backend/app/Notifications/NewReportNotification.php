<?php

namespace App\Notifications;

use App\Models\Report;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Notification;

class NewReportNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(public Report $report)
    {
    }

    public function via($notifiable): array
    {
        return ['database', 'broadcast'];
    }

    public function toDatabase($notifiable): array
    {
        $workshop = $this->report->workshop;

        return [
            'type' => 'new_report',
            'report_id' => $this->report->id,
            'report_type' => $this->report->report_type,
            'workshop_name' => $workshop?->name ?? 'Unknown',
            'message' => "Laporan baru dari bengkel {$workshop?->name}",
            'url' => route('admin.reports'),
        ];
    }

    public function toBroadcast($notifiable): array
    {
        $workshop = $this->report->workshop;

        return [
            'type' => 'new_report',
            'report_id' => $this->report->id,
            'workshop_name' => $workshop?->name ?? 'Unknown',
            'message' => "Laporan baru dari bengkel {$workshop?->name}",
        ];
    }
}

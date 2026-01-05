<?php

namespace App\Observers;

use App\Models\Report;
use App\Models\User;
use App\Notifications\NewReportNotification;

class ReportObserver
{
    public function created(Report $report): void
    {
        $this->notifyAdmins($report);
    }

    protected function notifyAdmins(Report $report): void
    {
        $admins = User::role('superadmin', 'web')->get();

        foreach ($admins as $admin) {
            $admin->notify(new NewReportNotification($report));
        }
    }
}

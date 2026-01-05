<?php

namespace App\Observers;

use App\Models\Workshop;
use App\Models\User;
use App\Notifications\WorkshopPendingNotification;

class WorkshopObserver
{
    public function created(Workshop $workshop): void
    {
        if ($workshop->status === 'pending') {
            $this->notifyAdmins($workshop);
        }
    }

    public function updated(Workshop $workshop): void
    {
        if ($workshop->wasChanged('status') && $workshop->status === 'pending') {
            $this->notifyAdmins($workshop);
        }
    }

    protected function notifyAdmins(Workshop $workshop): void
    {
        $admins = User::role('superadmin', 'web')->get();

        foreach ($admins as $admin) {
            $admin->notify(new WorkshopPendingNotification($workshop));
        }
    }
}

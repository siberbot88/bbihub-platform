<?php

namespace App\Events;

use App\Models\Service;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ServiceBookingReceived
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public Service $service
    ) {
    }
}

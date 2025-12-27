<?php

namespace App\Notifications;

use App\Services\FcmService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Notification;

class ServiceNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(
        public string $type,
        public string $title,
        public string $message,
        public array $data = []
    ) {
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via(object $notifiable): array
    {
        $channels = ['database'];

        // Add FCM if user has token
        if ($notifiable->fcm_token) {
            $channels[] = \App\Channels\FcmChannel::class;
        }

        return $channels;
    }

    /**
     * Send FCM push notification
     */
    public function toFcm(object $notifiable): void
    {
        $fcm = app(FcmService::class);

        $fcm->sendToDevice(
            fcmToken: $notifiable->fcm_token,
            title: $this->title,
            body: $this->message,
            data: array_merge($this->data, ['type' => $this->type])
        );
    }

    /**
     * Get the array representation of the notification for database.
     */
    public function toArray(object $notifiable): array
    {
        return [
            'type' => $this->type,
            'title' => $this->title,
            'message' => $this->message,
            'data' => $this->data,
            'created_at' => now()->toIso8601String(),
        ];
    }
}

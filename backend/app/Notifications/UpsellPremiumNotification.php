<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;
use Illuminate\Support\Str;

class UpsellPremiumNotification extends Notification
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct()
    {
        //
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['database'];
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            'id' => Str::uuid(),
            'title' => 'Penawaran Eksklusif BBI Hub Premium 🚀',
            'message' => 'Selamat! Aktivitas bengkel Anda luar biasa. Kami mengundang Anda untuk mencoba fitur Premium (Manajemen Stok & Keuangan) untuk meningkatkan omzet bisnis Anda.',
            'type' => 'upsell_offer',
            'icon' => 'star',
            'color' => 'indigo',
            'link' => '/owner/subscription/upgrade',
            'created_at' => now()
        ];
    }
}

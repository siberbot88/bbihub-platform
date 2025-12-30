<?php

namespace App\Channels;

use Illuminate\Notifications\Notification;

class FcmChannel
{
    /**
     * Send the given notification.
     *
     * @param  mixed  $notifiable
     * @param  \Illuminate\Notifications\Notification  $notification
     * @return void
     */
    public function send($notifiable, Notification $notification)
    {
        // Check if notification has toFcm method
        if (!method_exists($notification, 'toFcm')) {
            return;
        }

        // Call the toFcm method on the notification class
        $notification->toFcm($notifiable);
    }
}

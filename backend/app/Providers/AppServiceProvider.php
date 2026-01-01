<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        \Illuminate\Validation\Rules\Password::defaults(function () {
            return \Illuminate\Validation\Rules\Password::min(8)
                ->mixedCase()
                ->numbers()
                ->symbols()
                ->uncompromised();
        });

        // Use API route for Email Verification
        \Illuminate\Auth\Notifications\VerifyEmail::createUrlUsing(function (object $notifiable) {
            return \Illuminate\Support\Facades\URL::temporarySignedRoute(
                'api.verification.verify',
                \Illuminate\Support\Carbon::now()->addMinutes(config('auth.verification.expire', 60)),
                [
                    'id' => $notifiable->getKey(),
                    'hash' => sha1($notifiable->getEmailForVerification()),
                ]
            );
        });
    }
}

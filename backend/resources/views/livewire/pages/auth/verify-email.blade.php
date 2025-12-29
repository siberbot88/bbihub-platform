<?php

use App\Livewire\Actions\Logout;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Session;
use Livewire\Attributes\Layout;
use Livewire\Volt\Component;

new #[Layout('layouts.guest')] class extends Component {
    public string $message = '';
    public string $messageType = 'info';

    /**
     * Check if email is verified and redirect if so
     */
    public function checkVerification(): void
    {
        // Refresh user from database to get latest email_verified_at
        Auth::user()->refresh();

        if (Auth::user()->hasVerifiedEmail()) {
            $this->message = 'Email verified! Redirecting to dashboard...';
            $this->messageType = 'success';

            $this->redirectIntended(default: route('admin.dashboard', absolute: false), navigate: true);
            return;
        }

        $this->message = 'Email not yet verified. Please check your inbox and click the verification link.';
        $this->messageType = 'warning';
    }

    /**
     * Send an email verification notification to the user.
     */
    public function sendVerification(): void
    {
        if (Auth::user()->hasVerifiedEmail()) {
            $this->redirectIntended(default: route('admin.dashboard', absolute: false), navigate: true);

            return;
        }

        Auth::user()->sendEmailVerificationNotification();

        Session::flash('status', 'verification-link-sent');
    }

    /**
     * Log the current user out of the application.
     */
    public function logout(Logout $logout): void
    {
        $logout();

        $this->redirect('/', navigate: true);
    }
}; ?>

<div wire:poll.10s="checkVerification">
    <div class="mb-4 text-sm text-gray-600">
        {{ __('Thanks for signing up! Before getting started, could you verify your email address by clicking on the link we just emailed to you? If you didn\'t receive the email, we will gladly send you another.') }}
    </div>

    @if (session('status') == 'verification-link-sent')
        <div class="mb-4 font-medium text-sm text-green-600">
            {{ __('A new verification link has been sent to the email address you provided during registration.') }}
        </div>
    @endif

    @if ($message)
        <div
            class="mb-4 font-medium text-sm {{ $messageType === 'success' ? 'text-green-600' : ($messageType === 'warning' ? 'text-yellow-600' : 'text-blue-600') }}">
            {{ $message }}
        </div>
    @endif

    <div class="mt-4 flex flex-col sm:flex-row items-center justify-between gap-3">
        <div class="flex gap-2">
            <x-primary-button wire:click="checkVerification" wire:loading.attr="disabled">
                <span wire:loading.remove wire:target="checkVerification">{{ __('Check Email Verification') }}</span>
                <span wire:loading wire:target="checkVerification">{{ __('Checking...') }}</span>
            </x-primary-button>

            <x-secondary-button wire:click="sendVerification" wire:loading.attr="disabled">
                <span wire:loading.remove wire:target="sendVerification">{{ __('Resend Email') }}</span>
                <span wire:loading wire:target="sendVerification">{{ __('Sending...') }}</span>
            </x-secondary-button>
        </div>

        <button wire:click="logout" type="button"
            class="underline text-sm text-gray-600 hover:text-gray-900 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
            {{ __('Log Out') }}
        </button>
    </div>

    <div class="mt-3 text-xs text-gray-500 italic">
        {{ __('This page automatically checks for verification every 10 seconds') }}
    </div>
</div>
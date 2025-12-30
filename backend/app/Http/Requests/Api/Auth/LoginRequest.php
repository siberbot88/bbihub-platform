<?php

namespace App\Http\Requests\Api\Auth;

use App\Models\User;
use Illuminate\Auth\Events\Lockout;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class LoginRequest extends FormRequest
{
    private const ALLOWED_LOGIN_ROLES = ['owner', 'admin'];
    private const MAX_LOGIN_ATTEMPTS = 5;
    private const DECAY_SECONDS = 60;

    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'login' => ['required', 'string'], // Can be either email or username
            'password' => ['required', 'string'],
            'remember' => ['sometimes', 'boolean'], // Optional remember me parameter
        ];
    }

    /**
     * Coba untuk mengotentikasi kredensial request.
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function authenticate(): void
    {
        $this->ensureIsNotRateLimited();

        $login = $this->input('login');

        // Determine if login input is email or username
        $fieldType = filter_var($login, FILTER_VALIDATE_EMAIL) ? 'email' : 'username';

        /** @var User|null $user */
        $user = User::where($fieldType, $login)->first();

        if (!$user || !Hash::check($this->input('password'), $user->password)) {
            RateLimiter::hit($this->throttleKey(), self::DECAY_SECONDS);

            throw ValidationException::withMessages([
                'login' => 'Username/Email atau password salah.',
            ]);
        }

        if (!$user->hasAnyRole(self::ALLOWED_LOGIN_ROLES, 'sanctum')) {
            throw ValidationException::withMessages([
                'login' => 'Akun Anda tidak memiliki izin untuk mengakses aplikasi ini.',
            ]);
        }

        $this->setUserResolver(function () use ($user) {
            return $user;
        });

        RateLimiter::clear($this->throttleKey());
    }

    /**
     * Pastikan request login tidak di-rate limited.
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function ensureIsNotRateLimited(): void
    {
        if (!RateLimiter::tooManyAttempts($this->throttleKey(), self::MAX_LOGIN_ATTEMPTS)) {
            return;
        }

        event(new Lockout($this));

        $seconds = RateLimiter::availableIn($this->throttleKey());

        throw ValidationException::withMessages([
            'login' => 'Terlalu banyak percobaan login. Coba lagi dalam ' . $seconds . ' detik.',
        ]);
    }

    /**
     * Dapatkan throttle key untuk request ini.
     */
    public function throttleKey(): string
    {
        $login = Str::lower((string) $this->input('login'));
        return 'login:' . sha1($login . '|' . $this->ip());
    }
}

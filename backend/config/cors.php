<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Here you may configure your settings for cross-origin resource sharing
    | or "CORS". This determines what cross-origin operations may execute
    | in web browsers. You are free to adjust these settings as needed.
    |
    | To learn more: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
    |
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
        // Production Frontend URLs
        env('FRONTEND_URL', 'https://bbihub.com'),

        // Development/Local URLs
        'http://localhost:3000',
        'http://localhost:8000',
        'http://127.0.0.1:3000',
        'http://127.0.0.1:8000',

        // Mobile App (allow any origin since mobile uses Bearer token, not cookies)
        // Uncomment jika ingin allow all origins untuk mobile
        // '*', 
    ],

    'allowed_origins_patterns' => [
        // Allow subdomains in production (e.g., dev.bbihub.com, staging.bbihub.com)
        // '/^https:\/\/([a-z0-9-]+\.)?bbihub\.com$/',
    ],

    'allowed_headers' => ['*'],

    'exposed_headers' => [
        'Authorization',
        'X-Total-Count',
        'X-Page-Count',
    ],

    'max_age' => 0,

    'supports_credentials' => false, // Set to true if using cookies for auth (web dashboard)

];

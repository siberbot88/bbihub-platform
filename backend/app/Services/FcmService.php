<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

/**
 * Firebase Cloud Messaging Service (V1 API)
 * 
 * Modern FCM implementation using OAuth 2.0
 */
class FcmService
{
    private string $projectId;
    private string $serviceAccountPath;

    public function __construct()
    {
        $this->projectId = config('services.fcm.project_id');
        $this->serviceAccountPath = config('services.fcm.service_account_path');
    }

    /**
     * Send push notification to single device (V1 API)
     * 
     * @param string $fcmToken
     * @param string $title
     * @param string $body
     * @param array $data
     * @return bool
     */
    public function sendToDevice(
        string $fcmToken,
        string $title,
        string $body,
        array $data = []
    ): bool {
        try {
            $accessToken = $this->getAccessToken();

            if (!$accessToken) {
                Log::error('Failed to get FCM access token');
                return false;
            }

            $url = "https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send";

            /** @var \Illuminate\Http\Client\Response $response */
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
            ])->post($url, [
                        'message' => [
                            'token' => $fcmToken,
                            'notification' => [
                                'title' => $title,
                                'body' => $body,
                            ],
                            'data' => $data,
                            'android' => [
                                'priority' => 'high',
                                'notification' => [
                                    'sound' => 'default',
                                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                                ],
                            ],
                            'apns' => [
                                'payload' => [
                                    'aps' => [
                                        'sound' => 'default',
                                        'badge' => 1,
                                    ],
                                ],
                            ],
                        ],
                    ]);

            if ($response->successful()) {
                Log::info('FCM V1 notification sent successfully', [
                    'token' => substr($fcmToken, 0, 20) . '...',
                    'title' => $title,
                ]);
                return true;
            }

            Log::error('FCM V1 notification failed', [
                'status' => $response->status(),
                'body' => $response->json(),
            ]);

            return false;
        } catch (\Exception $e) {
            Log::error('FCM V1 exception', [
                'error' => $e->getMessage(),
            ]);

            return false;
        }
    }

    /**
     * Send to multiple devices
     */
    public function sendToMultipleDevices(
        array $fcmTokens,
        string $title,
        string $body,
        array $data = []
    ): int {
        $successCount = 0;

        foreach ($fcmTokens as $token) {
            if ($this->sendToDevice($token, $title, $body, $data)) {
                $successCount++;
            }
        }

        return $successCount;
    }

    /**
     * Get OAuth 2.0 access token from service account
     */
    private function getAccessToken(): ?string
    {
        try {
            $serviceAccountJson = Storage::get($this->serviceAccountPath);

            if (!$serviceAccountJson) {
                Log::error('Service account JSON not found', [
                    'path' => $this->serviceAccountPath
                ]);
                return null;
            }

            $serviceAccount = json_decode($serviceAccountJson, true);

            // Create JWT
            $now = time();
            $jwtHeader = base64_encode(json_encode([
                'alg' => 'RS256',
                'typ' => 'JWT',
            ]));

            $jwtClaimSet = base64_encode(json_encode([
                'iss' => $serviceAccount['client_email'],
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
                'aud' => 'https://oauth2.googleapis.com/token',
                'exp' => $now + 3600,
                'iat' => $now,
            ]));

            $jwtSignature = '';
            $signatureInput = $jwtHeader . '.' . $jwtClaimSet;

            openssl_sign(
                $signatureInput,
                $jwtSignature,
                $serviceAccount['private_key'],
                'SHA256'
            );

            $jwt = $signatureInput . '.' . base64_encode($jwtSignature);

            // Exchange JWT for access token
            /** @var \Illuminate\Http\Client\Response $response */
            $response = Http::asForm()->post('https://oauth2.googleapis.com/token', [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ]);

            if ($response->successful()) {
                return $response->json('access_token');
            }

            Log::error('Failed to get access token', [
                'response' => $response->json(),
            ]);

            return null;
        } catch (\Exception $e) {
            Log::error('Access token generation failed', [
                'error' => $e->getMessage(),
            ]);

            return null;
        }
    }
}

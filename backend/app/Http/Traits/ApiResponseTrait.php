<?php

namespace App\Http\Traits;

use Illuminate\Http\JsonResponse;

/**
 * Trait untuk menstandardisasi respon API JSON
 * 
 * ⚠️ SECURITY NOTES:
 * 1. NEVER pass raw user input directly to these methods
 * 2. ALWAYS validate and sanitize data before passing to response
 * 3. DO NOT expose sensitive data (passwords, tokens, internal IDs)
 * 4. Use generic error messages (don't expose stack traces in production)
 * 5. Data passed here should already be filtered/validated
 */
trait ApiResponseTrait
{
    /**
     * Respon sukses terstandardisasi.
     *
     * @param string $message Generic success message
     * @param mixed $data Sanitized/validated data only
     * @param int $code HTTP status code
     * @return \Illuminate\Http\JsonResponse
     */
    protected function successResponse(string $message, $data = null, int $code = 200): JsonResponse
    {
        return response()->json([
            'message' => $message,
            'data' => $data,
        ], $code);
    }

    /**
     * Respon error terstandardisasi.
     *
     * @param string $message Pesan error utama.
     * @param int $code Kode status HTTP.
     * @param mixed $errors Detail error (bisa string atau array, opsional).
     * @return \Illuminate\Http\JsonResponse
     */
    protected function errorResponse(string $message, int $code = 400, $errors = null): JsonResponse
    {
        $response = [
            'message' => $message,
        ];

        if ($errors) {
            $errorKey = is_array($errors) ? 'errors' : 'error';
            $response[$errorKey] = $errors;
        }

        return response()->json($response, $code);
    }
}

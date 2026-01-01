<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\OwnerSubscription;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class MidtransWebhookController extends Controller
{
    public function handle(Request $request)
    {
        Log::info('Midtrans Webhook Received', $request->all());

        $payload = $request->all();
        $orderId = $payload['order_id'];
        $statusCode = $payload['status_code'];
        $grossAmount = $payload['gross_amount'];
        $signatureKey = $payload['signature_key'];
        $transactionStatus = $payload['transaction_status'];
        $paymentType = $payload['payment_type'] ?? null;
        $transactionId = $payload['transaction_id'] ?? null;
        // Fraud status is optional
        $fraudStatus = $payload['fraud_status'] ?? null;

        // Verify Signature
        $serverKey = config('midtrans.server_key');
        $mySignature = hash('sha512', $orderId . $statusCode . $grossAmount . $serverKey);

        if ($mySignature !== $signatureKey) {
            Log::warning("Midtrans Invalid Signature: $orderId");
            return response()->json(['message' => 'Invalid signature'], 403);
        }

        // Find Subscription
        // Order ID format: SUBS-{user_uuid}-{timestamp} OR we might store it in order_id column
        // In OwnerSubscriptionService we generated orderId. 
        // We should query by order_id column.
        $subscription = OwnerSubscription::where('order_id', $orderId)->first();

        if ($subscription) {
            // ==========================================
            // LOGIC 1: OWNER SUBSCRIPTION
            // ==========================================

            // 🎁 TRIAL ACTIVATION LOGIC
            // Detect trial orders (starts with 'TRIAL-' or has gross_amount = 0)
            $isTrial = str_starts_with($orderId, 'TRIAL-') || (int) $grossAmount === 0;

            if ($isTrial && ($transactionStatus === 'settlement' || $transactionStatus === 'capture')) {
                // Activate trial for user
                $user = $subscription->user;
                if ($user) {
                    $user->update([
                        'trial_used' => true,
                        'trial_ends_at' => now()->addDays(7),
                    ]);
                    Log::info("Trial activated for user {$user->id}, order: $orderId");
                }
            }

            // Current status logic
            $newStatus = null;

            if ($transactionStatus == 'capture') {
                if ($fraudStatus == 'challenge') {
                    $newStatus = 'pending'; // Challenge by FDS
                } else {
                    $newStatus = 'active'; // Success
                }
            } else if ($transactionStatus == 'settlement') {
                $newStatus = 'active'; // Success
            } else if ($transactionStatus == 'pending') {
                $newStatus = 'pending';
            } else if ($transactionStatus == 'deny') {
                $newStatus = 'cancelled';
            } else if ($transactionStatus == 'expire') {
                $newStatus = 'expired';
            } else if ($transactionStatus == 'cancel') {
                $newStatus = 'cancelled';
            }

            if ($newStatus) {
                $subscription->status = $newStatus;
                $subscription->transaction_id = $transactionId;
                $subscription->payment_type = $paymentType;
                $subscription->gross_amount = $grossAmount;
                // $subscription->pdf_url = ... (Midtrans doesn't send PDF URL in webhook directly usually, but maybe we can construct it or ignore)

                $subscription->save();
                Log::info("Subscription $orderId updated to $newStatus");
            }

        } else {
            // ==========================================
            // LOGIC 2: SERVICE TRANSACTION (Demo Form / Mobile App)
            // ==========================================

            // Format: {UUID}-{TIMESTAMP} 
            // We strip the last part to get the UUID
            $trxUuid = \Illuminate\Support\Str::beforeLast($orderId, '-');
            $transaction = \App\Models\Transaction::find($trxUuid);

            if (!$transaction) {
                Log::error("Transaction/Subscription not found for Order ID: $orderId");
                return response()->json(['message' => 'Transaction not found'], 404);
            }

            $newStatus = null;
            if ($transactionStatus == 'capture') {
                if ($fraudStatus == 'challenge') {
                    $newStatus = 'pending';
                } else {
                    $newStatus = 'paid';
                }
            } else if ($transactionStatus == 'settlement') {
                $newStatus = 'paid';
            } else if ($transactionStatus == 'pending') {
                $newStatus = 'pending';
            } else if ($transactionStatus == 'deny') {
                $newStatus = 'cancelled';
            } else if ($transactionStatus == 'expire') {
                $newStatus = 'cancelled';
            } else if ($transactionStatus == 'cancel') {
                $newStatus = 'cancelled';
            }

            if ($newStatus) {
                try {
                    // Map Midtrans payment_type to DB ENUM ['QRIS', 'Cash', 'Bank']
                    // Midtrans types: bank_transfer, qris, gopay, cstore, etc.
                    $mappedPaymentMethod = null;
                    if ($paymentType === 'qris' || $paymentType === 'gopay') {
                        $mappedPaymentMethod = 'QRIS'; // Simplify E-Wallet to QRIS or null if strict
                    } elseif (str_contains($paymentType, 'bank') || str_contains($paymentType, 'va') || $paymentType === 'echannel') {
                        $mappedPaymentMethod = 'Bank';
                    } else {
                        // Default fallback or null
                        $mappedPaymentMethod = null;
                    }

                    // Map Midtrans Status to DB Enum ['pending', 'process', 'success']
                    $finalStatus = $newStatus;
                    if (in_array($newStatus, ['cancelled', 'expired', 'deny'])) {
                        $finalStatus = 'pending'; // Fallback for failed/cancelled transactions
                    } elseif ($newStatus === 'paid') {
                        $finalStatus = 'success';
                    }

                    $transaction->update([
                        'status' => $finalStatus,
                        'payment_method' => $mappedPaymentMethod
                    ]);

                    // If success (paid), ensure service is completed
                    if ($finalStatus === 'success' && $transaction->service) {
                        $transaction->service->update(['status' => 'completed']);
                    }

                    Log::info("Transaction $trxUuid updated to $newStatus via Webhook");
                } catch (\Exception $e) {
                    Log::error("Failed to update transaction via webhook: " . $e->getMessage());
                    return response()->json(['message' => 'Internal Server Error'], 500);
                }
            }
        }

        return response()->json(['message' => 'Webhook processed']);
    }
}

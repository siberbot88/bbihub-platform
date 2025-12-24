<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\TransactionResource;
use App\Models\AuditLog;
use App\Models\Transaction;
use App\Services\TransactionService;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class TransactionController extends Controller
{
    public function __construct(
        protected TransactionService $transactionService
    ) {
    }

    // POST /api/v1/transactions
    public function store(Request $request)
    {
        $data = $request->validate([
            'service_uuid' => 'required|string|exists:services,id',
            'payment_method' => 'nullable|string',
        ]);

        try {
            $trx = $this->transactionService->createTransaction($data, $request->user());

            // Audit log - transaction created
            AuditLog::log(
                event: 'transaction_created',
                user: $request->user(),
                auditable: $trx,
                newValues: [
                    'service_id' => $trx->service_id,
                    'amount' => $trx->amount,
                    'status' => $trx->status
                ]
            );

            return (new TransactionResource($trx->load(['service', 'items'])))
                ->response()
                ->setStatusCode(201);

        } catch (ValidationException $e) {
            return response()->json([
                'message' => $e->getMessage(),
                'errors' => $e->errors(),
            ], 422);
        }
    }


    // GET /api/v1/transactions/{transaction}
    public function show(Transaction $transaction)
    {
        $this->authorize('view', $transaction);

        return new TransactionResource(
            $transaction->load([
                'service.customer',
                'service.vehicle',
                'service.workshop',
                'items',
                'mechanic.user',
                'invoice',
            ])
        );
    }

    public function update(Request $request, Transaction $transaction)
    {
        $this->authorize('update', $transaction);

        $data = $request->validate([
            'payment_method' => 'nullable|in:QRIS,Cash,Bank',
            'amount' => 'nullable|numeric|min:0',
            'notes' => 'nullable|string',
        ]);

        $updated = $this->transactionService->updateTransaction($transaction, $data);

        return new TransactionResource(
            $updated->fresh()->load(['items', 'service'])
        );
    }


    // PATCH /api/v1/transactions/{transaction}/status
    public function updateStatus(Request $request, Transaction $transaction)
    {
        $this->authorize('update', $transaction);

        $data = $request->validate([
            'status' => 'required|in:pending,process,success',
        ]);

        try {
            $oldStatus = $transaction->status;
            $updated = $this->transactionService->updateStatus($transaction, $data['status']);

            // Audit log - status changed
            AuditLog::log(
                event: 'transaction_status_changed',
                user: $request->user(),
                auditable: $updated,
                oldValues: ['status' => $oldStatus],
                newValues: ['status' => $updated->status]
            );

            return new TransactionResource(
                $updated->fresh()->load(['items', 'service'])
            );

        } catch (ValidationException $e) {
            return response()->json([
                'message' => $e->getMessage(),
                'errors' => $e->errors(),
            ], 422);
        }
    }

    // POST /api/v1/transactions/{transaction}/finalize
    public function finalize(Transaction $transaction)
    {
        $this->authorize('update', $transaction);

        try {
            $updated = $this->transactionService->finalizeTransaction($transaction);

            // Audit log - finalized
            AuditLog::log(
                event: 'transaction_finalized',
                user: auth()->user(),
                auditable: $updated,
                newValues: ['status' => $updated->status]
            );

            return new TransactionResource(
                $updated->fresh()->load(['items', 'service'])
            );

        } catch (ValidationException $e) {
            return response()->json([
                'message' => $e->getMessage(),
                'errors' => $e->errors(),
            ], 422);
        }
    }

    /**
     * POST /api/v1/transactions/{transaction}/apply-voucher
     * Apply voucher to transaction
     */
    public function applyVoucher(Request $request, Transaction $transaction)
    {
        $this->authorize('update', $transaction);

        $data = $request->validate([
            'voucher_code' => 'required|string',
        ]);

        // Find voucher
        $voucher = \App\Models\Voucher::where('code_voucher', $data['voucher_code'])
            ->where('workshop_uuid', $transaction->workshop_uuid)
            ->first();

        if (!$voucher) {
            return response()->json([
                'message' => 'Voucher tidak ditemukan.',
            ], 422);
        }

        // Validate status
        if ($voucher->status !== 'active') {
            return response()->json([
                'message' => 'Voucher tidak aktif atau sudah kadaluarsa.',
            ], 422);
        }

        // Validate quota
        if ($voucher->quota <= 0) {
            return response()->json([
                'message' => 'Kuota voucher sudah habis.',
            ], 422);
        }

        // Validate minimum transaction
        $transactionAmount = $transaction->items()->sum('subtotal');
        if ($transactionAmount < $voucher->min_transaction) {
            return response()->json([
                'message' => 'Minimum transaksi Rp ' . number_format($voucher->min_transaction, 0, ',', '.'),
            ], 422);
        }

        // Calculate discount
        // Logic: <= 100 is Percentage, > 100 is Fixed
        $val = $voucher->discount_value;
        if ($val <= 100) {
            $discountAmount = $transactionAmount * ($val / 100);
        } else {
            $discountAmount = min($val, $transactionAmount);
        }

        // Apply voucher
        $transaction->update([
            'voucher_uuid' => $voucher->id,
            'discount_amount' => $discountAmount,
            'amount' => max(0, $transactionAmount - $discountAmount),
        ]);

        // Decrement quota
        $voucher->decrement('quota');

        return response()->json([
            'message' => 'Voucher berhasil diterapkan.',
            'data' => [
                'voucher' => [
                    'code' => $voucher->code_voucher,
                    'title' => $voucher->title,
                ],
                'original_amount' => $transactionAmount,
                'discount_amount' => $discountAmount,
                'final_amount' => $transactionAmount - $discountAmount,
            ],
        ], 200);
    }

    /**
     * POST /api/v1/transactions/{transaction}/snap-token
     * Generate Midtrans Snap Token
     */
    public function getSnapToken(Transaction $transaction)
    {
        $this->authorize('view', $transaction);

        try {
            // Ensure transaction is loaded with necessary relations
            $transaction->load(['service.customer', 'service.workshop', 'items']);

            // Calculate total amount (ensure at least 1)
            $amount = max(1, (int) $transaction->amount);

            // Prepare customer details
            $customer = $transaction->service->customer;
            $customerName = $customer ? $customer->name : 'Walk-in Customer';
            $customerEmail = $customer ? $customer->email : 'customer@example.com';
            $customerPhone = $customer ? $customer->phone_number : '081234567890';

            // Prepare item details for Midtrans (optional but good for detail)
            $itemDetails = [];
            foreach ($transaction->items as $item) {
                $itemDetails[] = [
                    'id' => $item->id,
                    'price' => (int) $item->price,
                    'quantity' => $item->quantity,
                    'name' => substr($item->name, 0, 50), // Midtrans char limit
                ];
            }

            // Add negative item for discount if any
            if ($transaction->discount_amount > 0) {
                $itemDetails[] = [
                    'id' => 'DISCOUNT',
                    'price' => -((int) $transaction->discount_amount),
                    'quantity' => 1,
                    'name' => 'Voucher Discount',
                ];
            }

            $params = [
                'transaction_details' => [
                    'order_id' => $transaction->id . '-' . time(), // Unique ID per attempt
                    'gross_amount' => $amount,
                ],
                'customer_details' => [
                    'first_name' => $customerName,
                    'email' => $customerEmail,
                    'phone' => $customerPhone,
                ],
                'item_details' => $itemDetails,
            ];

            $midtransService = new \App\Services\MidtransService();
            // Assuming createSnapToken returns string directly based on MidtransService definition
            $snapToken = $midtransService->createSnapToken($params);

            return response()->json([
                'snap_token' => $snapToken,
                'redirect_url' => 'https://app.sandbox.midtrans.com/snap/v2/vtweb/' . $snapToken,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Gagal membuat token pembayaran: ' . $e->getMessage(),
            ], 500);
        }
    }
}

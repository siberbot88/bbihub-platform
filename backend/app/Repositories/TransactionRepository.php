<?php

namespace App\Repositories;

use App\Models\Transaction;
use App\Models\TransactionItem;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Transaction Repository
 * 
 * Handles transaction and invoice operations.
 */
class TransactionRepository
{
    /**
     * Create invoice/transaction for service.
     * 
     * @param string $serviceId
     * @param string $userId User who created invoice (admin)
     * @param array $items Array of items [name, type, price, quantity]
     * @return Transaction
     */
    public function createInvoice(string $serviceId, string $userId, array $items): Transaction
    {
        return DB::transaction(function () use ($serviceId, $userId, $items) {
            // Calculate total
            $total = collect($items)->sum(function ($item) {
                return $item['price'] * $item['quantity'];
            });

            // Generate invoice code
            $lastTransaction = Transaction::orderBy('invoice_code', 'desc')
                ->lockForUpdate()
                ->first();

            $nextNum = 1;
            if ($lastTransaction && preg_match('/^INV(\d{6})$/', $lastTransaction->invoice_code, $matches)) {
                $nextNum = (int) $matches[1] + 1;
            }

            $invoiceCode = 'INV' . str_pad((string) $nextNum, 6, '0', STR_PAD_LEFT);

            // Create transaction
            $transaction = Transaction::create([
                'id' => Str::uuid(),
                'service_uuid' => $serviceId,
                'user_uuid' => $userId,
                'invoice_code' => $invoiceCode,
                'total' => $total,
                'status' => 'menunggu pembayaran', // Waiting for payment
                'payment_method' => null, // Will be set by Midtrans callback
            ]);

            // Create transaction items
            foreach ($items as $item) {
                TransactionItem::create([
                    'id' => Str::uuid(),
                    'transaction_uuid' => $transaction->id,
                    'service_uuid' => $serviceId,
                    'name' => $item['name'],
                    'type' => $item['type'], // 'jasa' or 'sparepart'
                    'price' => $item['price'],
                    'quantity' => $item['quantity'],
                    'subtotal' => $item['price'] * $item['quantity'],
                ]);
            }

            // Update service status to 'menunggu pembayaran'
            DB::table('services')
                ->where('id', $serviceId)
                ->update(['status' => 'menunggu pembayaran']);

            return $transaction->load('items');
        });
    }

    /**
     * Get invoice by service ID.
     * 
     * @param string $serviceId
     * @return Transaction|null
     */
    public function getInvoiceByService(string $serviceId): ?Transaction
    {
        return Transaction::with(['items', 'service.customer', 'service.vehicle'])
            ->where('service_uuid', $serviceId)
            ->first();
    }

    /**
     * Update transaction status (e.g., after Midtrans callback).
     * 
     * @param string $transactionId
     * @param string $status
     * @param string|null $paymentMethod
     * @return Transaction
     */
    public function updateTransactionStatus(
        string $transactionId,
        string $status,
        ?string $paymentMethod = null
    ): Transaction {
        $transaction = Transaction::findOrFail($transactionId);

        $updateData = ['status' => $status];

        if ($paymentMethod) {
            $updateData['payment_method'] = $paymentMethod;
        }

        $transaction->update($updateData);

        // If paid (lunas), update service status to 'lunas'
        if ($status === 'lunas') {
            DB::table('services')
                ->where('id', $transaction->service_uuid)
                ->update(['status' => 'lunas']);
        }

        return $transaction->load('items');
    }
}

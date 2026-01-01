<?php

namespace Database\Seeders;

use App\Models\Employment;
use App\Models\Invoice;
use App\Models\InvoiceItem;
use App\Models\Service;
use App\Models\Transaction;
use Database\Seeders\Helpers\IndonesianDataHelper;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class InvoiceTransactionSeeder extends Seeder
{
    /**
     * Create invoices and transactions for COMPLETED services only
     * - Invoice items sum to invoice total
     * - Transaction amount matches invoice total
     * - Realistic payment status distribution
     */
    public function run(): void
    {
        // Get only COMPLETED services
        $completedServices = Service::where('status', 'completed')
            ->with(['workshop', 'customer', 'mechanic'])
            ->get();

        if ($completedServices->isEmpty()) {
            $this->command->warn('No completed services found! Run ServiceSeeder first.');
            return;
        }

        $totalInvoices = 0;
        $totalTransactions = 0;
        $invoiceCode = 1;

        foreach ($completedServices as $service) {
            // Get an admin from the workshop to be creator
            $admin = Employment::where('workshop_uuid', $service->workshop_uuid)
                ->whereHas('user')
                ->where('status', 'active')
                ->inRandomOrder()
                ->first();

            if (!$admin) {
                continue; // Skip if no admin available
            }

            // 1. CREATE INVOICE
            $invoiceId = Str::uuid()->toString();
            $invoiceCodeStr = 'INV-' . date('Ymd', strtotime($service->completed_at)) . '-' . str_pad($invoiceCode++, 4, '0', STR_PAD_LEFT);

            // Determine invoice status based on when it was completed
            // Most completed services should have paid invoices
            $invoiceStatus = $this->determineInvoiceStatus();

            $invoice = [
                'id' => $invoiceId,
                'invoice_code' => $invoiceCodeStr,
                'service_uuid' => $service->id,
                'workshop_uuid' => $service->workshop_uuid,
                'customer_uuid' => $service->customer_uuid,
                'created_by' => $admin->user_uuid,
                'subtotal' => 0, // Will calculate below
                'tax' => 0,
                'discount' => 0,
                'total' => 0,
                'status' => $invoiceStatus,
                'sent_at' => $invoiceStatus !== 'draft' ? $service->completed_at : null,
                'notes' => $invoiceStatus === 'paid' ? 'Pembayaran diterima dengan baik' : null,
                'created_at' => $service->completed_at,
                'updated_at' => now(),
                'deleted_at' => null,
            ];

            // 2. CREATE INVOICE ITEMS (2-5 items per invoice)
            $numItems = rand(2, 5);
            $subtotal = 0;
            $invoiceItems = [];

            for ($i = 0; $i < $numItems; $i++) {
                // Mix of service labor and parts
                if (rand(1, 100) <= 60) {
                    // 60% service labor
                    $laborServices = IndonesianDataHelper::laborServices();
                    $labor = $laborServices[array_rand($laborServices)];

                    $itemId = Str::uuid()->toString();
                    $quantity = 1;
                    $unitPrice = $labor['price'];
                    $itemSubtotal = $quantity * $unitPrice;

                    $invoiceItems[] = [
                        'id' => $itemId,
                        'invoice_uuid' => $invoiceId,
                        'type' => 'service',
                        'name' => $labor['name'],
                        'description' => "Service untuk {$service->category_service}",
                        'quantity' => $quantity,
                        'unit_price' => $unitPrice,
                        'subtotal' => $itemSubtotal,
                        'created_at' => $service->completed_at,
                        'updated_at' => now(),
                    ];
                } else {
                    // 40% parts
                    $parts = IndonesianDataHelper::serviceParts();
                    $part = $parts[array_rand($parts)];

                    $itemId = Str::uuid()->toString();
                    $quantity = rand(1, 3);
                    $unitPrice = rand($part['price_min'], $part['price_max']);
                    $itemSubtotal = $quantity * $unitPrice;

                    $invoiceItems[] = [
                        'id' => $itemId,
                        'invoice_uuid' => $invoiceId,
                        'type' => 'part',
                        'name' => $part['name'],
                        'description' => "Spare part " . $part['name'],
                        'quantity' => $quantity,
                        'unit_price' => $unitPrice,
                        'subtotal' => $itemSubtotal,
                        'created_at' => $service->completed_at,
                        'updated_at' => now(),
                    ];
                }

                $subtotal += $itemSubtotal;
            }

            // 3. CALCULATE INVOICE TOTALS
            $tax = round($subtotal * 0.11, 2); // PPN 11%
            $discount = 0; // No discount for demo (vouchers handled separately)
            $total = $subtotal + $tax - $discount;

            $invoice['subtotal'] = $subtotal;
            $invoice['tax'] = $tax;
            $invoice['discount'] = $discount;
            $invoice['total'] = $total;

            // Insert invoice
            DB::table('invoices')->insert($invoice);

            // Insert invoice items
            DB::table('invoice_items')->insert($invoiceItems);

            $totalInvoices++;

            // 4. CREATE TRANSACTION (for paid/sent invoices)
            if ($invoiceStatus === 'paid' || $invoiceStatus === 'sent') {
                $transactionId = Str::uuid()->toString();

                // Transaction status distribution
                if ($invoiceStatus === 'paid') {
                    // 80% success, 15% process, 5% pending
                    $txStatusRand = rand(1, 100);
                    if ($txStatusRand <= 80) {
                        $txStatus = 'success';
                    } elseif ($txStatusRand <= 95) {
                        $txStatus = 'process';
                    } else {
                        $txStatus = 'pending';
                    }
                } else {
                    // Sent but not paid yet
                    $txStatus = 'pending';
                }

                // Payment method distribution: 50% Cash, 30% QRIS, 20% Bank
                $paymentMethodRand = rand(1, 100);
                if ($paymentMethodRand <= 50) {
                    $paymentMethod = 'Cash';
                } elseif ($paymentMethodRand <= 80) {
                    $paymentMethod = 'QRIS';
                } else {
                    $paymentMethod = 'Bank';
                }

                $transaction = [
                    'id' => $transactionId,
                    'service_uuid' => $service->id,
                    'customer_uuid' => $service->customer_uuid,
                    'workshop_uuid' => $service->workshop_uuid,
                    'mechanic_uuid' => $service->mechanic_uuid,
                    'admin_uuid' => $admin->user_uuid,
                    'invoice_uuid' => $invoiceId,
                    'amount' => $total,
                    'payment_method' => $txStatus !== 'pending' ? $paymentMethod : null,
                    'status' => $txStatus,
                    'created_at' => $service->completed_at,
                    'updated_at' => $txStatus === 'success' ? $service->completed_at : now(),
                ];

                DB::table('transactions')->insert($transaction);
                $totalTransactions++;
            }
        }

        $this->command->info("✓ Created {$totalInvoices} invoices");
        $this->command->info("✓ Created {$totalTransactions} transactions");
        $this->command->info("  → Financial integrity maintained (invoice total = transaction amount)");

        $this->showFinancialStats();
    }

    /**
     * Determine invoice status distribution
     * Most should be paid since services are completed
     */
    private function determineInvoiceStatus(): string
    {
        $rand = rand(1, 100);

        if ($rand <= 70) {
            return 'paid'; // 70%
        } elseif ($rand <= 90) {
            return 'sent'; // 20%
        } elseif ($rand <= 97) {
            return 'draft'; // 7%
        } else {
            return 'cancelled'; // 3%
        }
    }

    /**
     * Show financial statistics
     */
    private function showFinancialStats(): void
    {
        $this->command->newLine();
        $this->command->info('💰 Invoice Status Distribution:');

        $invoiceStats = DB::table('invoices')
            ->select('status', DB::raw('COUNT(*) as count'))
            ->groupBy('status')
            ->get();

        $invoiceTable = [];
        foreach ($invoiceStats as $stat) {
            $invoiceTable[] = [$stat->status, $stat->count];
        }
        $this->command->table(['Invoice Status', 'Count'], $invoiceTable);

        $this->command->newLine();
        $this->command->info('💳 Transaction Status Distribution:');

        $txStats = DB::table('transactions')
            ->select('status', DB::raw('COUNT(*) as count'))
            ->groupBy('status')
            ->get();

        $txTable = [];
        foreach ($txStats as $stat) {
            $txTable[] = [$stat->status, $stat->count];
        }
        $this->command->table(['Transaction Status', 'Count'], $txTable);

        // Show total revenue
        $totalRevenue = DB::table('transactions')
            ->where('status', 'success')
            ->sum('amount');

        $this->command->newLine();
        $this->command->info("💵 Total Revenue (Paid Transactions): Rp " . number_format($totalRevenue, 0, ',', '.'));
    }
}

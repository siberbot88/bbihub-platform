<?php

namespace App\Livewire\Admin\Demo;

use Livewire\Component;
use Livewire\Attributes\Layout;
use App\Models\Customer;
use App\Models\Vehicle;
use App\Models\Service;
use App\Models\Workshop;
use App\Models\Transaction;
use App\Models\TransactionItem; // Assuming logic might need it, generally Service -> Transaction link is direct
use App\Models\Voucher;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

use Livewire\WithPagination;

class Form extends Component
{
    use WithPagination;

    // Wizard Step
    public int $step = 1;

    // Table Filters
    public $search = '';
    public $filterType = '';

    // --- STEP 1: CUSTOMER ---
    public $customerName;
    public $customerPhone;
    public $customerEmail;
    public $customerAddress;
    public ?Customer $customer = null;

    // --- STEP 2: VEHICLE ---
    public $vehiclePlate;
    public $vehicleBrand;
    public $vehicleModel;
    public $vehicleType = 'motor'; // default
    public $vehicleYear;
    public $vehicleColor;
    public $vehicleOdometer;
    public ?Vehicle $vehicle = null;

    // --- STEP 3: SERVICE ---
    public $workshopId;
    public $serviceName; // Masalah/Keluhan utama
    public $serviceDesc;
    public $serviceType = 'booking';
    public $serviceCategory = 'ringan';
    // Default price to 0 (to be updated by workshop later), but property must exist
    public $servicePrice = 0;
    public ?Service $service = null;

    // --- STEP 4: PAYMENT ---
    public ?Transaction $transaction = null;
    public $voucherCode = '';
    public $discountAmount = 0;
    public $finalAmount = 0;
    public $snapToken = null;
    public $voucherMessage = '';

    // --- STEP 5: FEEDBACK ---
    public $rating = 0;
    public $feedbackComment = '';

    // Options
    public $workshops = [];

    protected $rules = [
        1 => [
            'customerName' => 'required|string|max:255',
            'customerPhone' => 'required|string|max:20',
            'customerEmail' => 'nullable|email',
            'customerAddress' => 'nullable|string',
        ],
        2 => [
            'vehiclePlate' => 'required|string|max:20',
            'vehicleBrand' => 'required|string',
            'vehicleModel' => 'required|string',
            'vehicleYear' => 'required|numeric|digits:4',
            'vehicleOdometer' => 'nullable|numeric|min:0',
        ],
        3 => [
            'workshopId' => 'required|exists:workshops,id',
            'serviceName' => 'required|string', // Keluhan
            'serviceCategory' => 'required|in:ringan,sedang,berat,maintenance',
        ],
        5 => [
            'rating' => 'required|integer|min:1|max:5',
            'feedbackComment' => 'nullable|string|max:1000',
        ]
    ];

    public function mount()
    {
        // Load workshops for dropdown
        // If superadmin, show all. If admin/owner, restrict.
        // For simplicity in demo, showing all workshops or based on auth
        if (auth()->user()->hasRole('superadmin')) {
            $this->workshops = Workshop::select('id', 'name')->get();
        } else {
            // Get user's workshops
            $this->workshops = auth()->user()->workshops ?? collect();
            if ($this->workshops->isEmpty() && auth()->user()->employment) {
                // If mechanic/admin
                $this->workshops = collect([auth()->user()->employment->workshop]);
            }
        }

        // Auto select if only 1 workshop
        if (count($this->workshops) === 1) {
            $this->workshopId = $this->workshops[0]->id;
        }
    }

    public function nextStep()
    {
        $this->validate($this->rules[$this->step] ?? []);

        if ($this->step === 1) {
            $this->saveCustomer();
            $this->step++;
        } elseif ($this->step === 2) {
            $this->saveVehicle();
            $this->step++;
        } elseif ($this->step === 3) {
            if ($this->saveServiceAndTransaction()) {
                // Finish flow here
                session()->flash('message', 'Servis berhasil dibuat! Menunggu pengerjaan bengkel.');
                $this->resetForm();
            }
        }
    }

    public function prevStep()
    {
        if ($this->step > 1) {
            $this->step--;
        }
    }

    // --- ACTIONS ---

    public function resetForm()
    {
        $this->reset([
            'step',
            'customer',
            'vehicle',
            'service',
            'transaction',
            'customerName',
            'customerPhone',
            'customerEmail',
            'customerAddress',
            'vehiclePlate',
            'vehicleBrand',
            'vehicleModel',
            'vehicleType',
            'vehicleYear',
            'vehicleColor',
            'vehicleOdometer',
            'serviceName',
            'serviceDesc',
            'serviceType',
            'serviceCategory',
            'voucherCode',
            'discountAmount',
            'finalAmount',
            'snapToken',
            'voucherMessage',
            'rating',
            'feedbackComment'
        ]);

        $this->step = 1;
        $this->mount(); // Re-init workshop selection
    }

    // --- TABLE ACTIONS ---

    public function markAsComplete($serviceId)
    {
        $srv = Service::find($serviceId);
        if ($srv && $srv->status === 'pending') {
            $srv->update(['status' => 'completed']); // Ready for payment
            session()->flash('message', 'Status servis diperbarui: Selesai Dikerjakan.');
        }
    }

    public function verifyByAI($serviceId)
    {
        $srv = Service::find($serviceId);
        // Only for booking that is pending
        if ($srv && $srv->status === 'pending' && $srv->type === 'booking') {
            $srv->update([
                'acceptance_status' => 'approved',
                // 'status' => 'pending' // Still pending execution, but AI accepted
            ]);
            session()->flash('message', 'Booking berhasil diterima oleh Admin.');
        }
    }

    public function openPayment($transactionId)
    {
        // Added 'service.invoice.items' to eager load actual invoice details
        // Added 'service.invoice' to access invoice totals
        // Fixed: 'vehicle' relationship does not exist on Transaction, getting it via service.vehicle
        $trx = Transaction::with(['customer', 'service.vehicle', 'service.invoice.items'])->find($transactionId);

        if (!$trx)
            return;

        // Load data into component
        $this->transaction = $trx;
        $this->customer = $trx->customer;
        $this->vehicle = $trx->service->vehicle; // Vehicle comes from service
        $this->service = $trx->service;
        $this->workshopId = $trx->workshop_uuid;

        // PRIORITIZE INVOICE TOTAL
        // If invoice exists, leverage its total. Otherwise fall back to transaction amount.
        if ($this->service->invoice) {
            $this->finalAmount = $this->service->invoice->total;
        } else {
            $this->finalAmount = $trx->amount;
        }

        $this->discountAmount = 0;
        $this->voucherCode = '';
        $this->voucherMessage = '';
        $this->snapToken = null;

        // Jump to payment step (Visual only)
        $this->step = 4;
    }

    public function openFeedback($transactionId)
    {
        // Fixed: 'vehicle' relationship does not exist on Transaction
        $trx = Transaction::with(['customer', 'service.vehicle', 'service'])->find($transactionId);

        if (!$trx)
            return;

        // Load data into component
        $this->transaction = $trx;
        $this->customer = $trx->customer;
        $this->vehicle = $trx->service->vehicle;
        $this->service = $trx->service;
        $this->workshopId = $trx->workshop_uuid;

        $this->rating = 0;
        $this->feedbackComment = '';

        // Jump to feedback step
        $this->step = 5;
    }

    protected function saveCustomer()
    {
        // Demo feature: Create new customer every time or find existing by phone? 
        // Request says "save at each step", implies persistence.
        // Let's create or update based on phone for demo convenience

        $this->customer = Customer::updateOrCreate(
            ['phone' => $this->customerPhone],
            [
                'name' => $this->customerName,
                'email' => $this->customerEmail,
                'address' => $this->customerAddress,
                'code' => 'CUST-' . Str::random(5), // Simple code gen
            ]
        );
    }

    protected function saveVehicle()
    {
        if (!$this->customer) {
            // Should not happen if flow is followed
            $this->addError('customer', 'Customer data missing.');
            return;
        }

        $this->vehicle = Vehicle::updateOrCreate(
            [
                'plate_number' => $this->vehiclePlate,
                'customer_uuid' => $this->customer->id
            ],
            [
                'brand' => $this->vehicleBrand,
                'model' => $this->vehicleModel,
                'year' => $this->vehicleYear,
                'type' => $this->vehicleType,
                'color' => $this->vehicleColor ?? '-',
                'name' => "$this->vehicleBrand $this->vehicleModel",
                'code' => 'VEH-' . strtoupper(Str::random(5)),
                'odometer' => $this->vehicleOdometer ?? 0,
            ]
        );
    }

    protected function saveServiceAndTransaction()
    {
        // Ensure customer/vehicle are saved if not already
        if (!$this->customer) {
            $this->saveCustomer();
        }
        if (!$this->vehicle) {
            $this->saveVehicle();
        }

        if (!$this->customer || !$this->vehicle) {
            $this->addError('system', 'Data Customer atau Kendaraan tidak valid. Silakan ulangi pengisian.');
            return false;
        }

        DB::beginTransaction();
        try {
            // 1. Create Service
            $this->service = Service::create([
                'workshop_uuid' => $this->workshopId,
                'customer_uuid' => $this->customer->id,
                'vehicle_uuid' => $this->vehicle->id,
                'name' => $this->serviceName, // Title/Complaint
                'description' => $this->serviceDesc ?? 'Demo Service Entry',
                'status' => 'pending', // Initial status
                'type' => $this->serviceType,
                'category_service' => $this->serviceCategory,
                'scheduled_date' => now(),
                'estimated_time' => match ($this->serviceCategory) {
                    'sedang' => now()->addHours(2),
                    'berat' => now()->addHours(5),
                    'maintenance' => now()->addMinutes(30),
                    default => now()->addHour(), // ringan
                },
                'code' => 'SRV-' . time(),
            ]);

            // 2. Create Transaction (Pending)
            $this->transaction = Transaction::create([
                'service_uuid' => $this->service->id,
                'customer_uuid' => $this->customer->id,
                'workshop_uuid' => $this->workshopId,
                // 'admin_uuid' => auth()->id(), // Removed: simulating customer action
                'amount' => $this->servicePrice,
                'status' => 'pending', // unpaid
                // 'payment_method' => null, (set later)
            ]);

            DB::commit();
            return true;
        } catch (\Exception $e) {
            DB::rollBack();
            $this->addError('system', 'Failed to save service: ' . $e->getMessage());
            return false;
        }
    }

    // --- PAYMENT & VOUCHER ---

    public function checkVoucher()
    {
        $this->reset('discountAmount', 'finalAmount', 'voucherMessage');

        // Use Invoice Total if available as base, just like openPayment
        $baseAmount = $this->service->invoice ? $this->service->invoice->total : $this->transaction->amount;
        $this->finalAmount = $baseAmount;

        if (empty($this->voucherCode))
            return;

        $voucher = Voucher::where('code_voucher', $this->voucherCode)
            ->where('workshop_uuid', $this->workshopId)
            ->first();

        // Simple validation logic (can be expanded based on Voucher model logic)
        if (!$voucher) {
            $this->addError('voucherCode', 'Voucher tidak ditemukan.');
            return;
        }

        if ($voucher->status !== 'active') {
            $this->addError('voucherCode', 'Voucher tidak aktif atau kadaluarsa.');
            return;
        }

        if ($voucher->quota <= 0) {
            $this->addError('voucherCode', 'Kuota voucher sudah habis.');
            return;
        }

        if ($baseAmount < $voucher->min_transaction) {
            $this->addError('voucherCode', "Minimal transaksi Rp " . number_format($voucher->min_transaction));
            return;
        }

        // Apply Logic: <= 100 is Percentage, > 100 is Fixed
        $val = $voucher->discount_value;
        if ($val <= 100) {
            // Percentage
            $this->discountAmount = $baseAmount * ($val / 100);
            $msgType = "{$val}%";
        } else {
            // Fixed Amount
            $this->discountAmount = $val;
            $msgType = "Rp " . number_format($val);
        }

        $this->finalAmount = max(0, $baseAmount - $this->discountAmount);
        $this->voucherMessage = "Voucher applied: -{$msgType} (Hemat Rp " . number_format($this->discountAmount) . ")";
    }

    public function processPayment()
    {
        // 1. Update Transaction with final details
        // Update both amount and discount
        $this->transaction->update([
            'amount' => $this->finalAmount,
            // 'discount_amount' => $this->discountAmount, // If we had this column
        ]);

        // 2. Midtrans Snap using MidtransService
        try {
            $midtransService = new \App\Services\MidtransService();

            // Check if we have real invoice items (e.g. from Mohammad Bayu Rizki)
            $itemDetails = [];
            $invoice = $this->service->invoice; // loaded via eager load in openPayment

            if ($invoice && $invoice->items && $invoice->items->count() > 0) {
                // Use actual invoice items
                foreach ($invoice->items as $item) {
                    $itemDetails[] = [
                        'id' => $item->id,
                        'price' => (int) $item->unit_price,
                        'quantity' => $item->quantity,
                        // Truncate name to 50 chars as per Midtrans spec recommendation
                        'name' => substr($item->name, 0, 50),
                    ];
                }

                // Add Invoice Tax if any
                if ($invoice->tax > 0) {
                    $itemDetails[] = [
                        'id' => 'TAX',
                        'price' => (int) $invoice->tax,
                        'quantity' => 1,
                        'name' => 'Tax'
                    ];
                }

                // Add Invoice Discount if any
                if ($invoice->discount > 0) {
                    $itemDetails[] = [
                        'id' => 'INV-DISCOUNT',
                        'price' => -((int) $invoice->discount),
                        'quantity' => 1,
                        'name' => 'Invoice Discount'
                    ];
                }

            } else {
                // Fallback for Manual Demo Entry (no invoice record yet)
                $itemDetails[] = [
                    'id' => $this->service->id,
                    'price' => (int) $this->transaction->amount, // Original Price base
                    'quantity' => 1,
                    'name' => "Service: " . substr($this->service->name, 0, 40)
                ];
            }

            // Apply Form Voucher Discount (Additional)
            if ($this->discountAmount > 0) {
                $itemDetails[] = [
                    'id' => 'VOUCHER-FORM',
                    'price' => -((int) $this->discountAmount),
                    'quantity' => 1,
                    'name' => 'Form Voucher'
                ];
            }

            // Calculate Gross Amount strictly from items sum to avoid Midtrans error
            $grossAmount = 0;
            foreach ($itemDetails as $item) {
                $grossAmount += ($item['price'] * $item['quantity']);
            }
            // Ensure grossAmount matches finalAmount roughly (integrity check)
            // But strict sum is required by Midtrans.

            $params = [
                'transaction_details' => [
                    'order_id' => $this->transaction->id . '-' . time(), // Unique ID for Midtrans
                    'gross_amount' => (int) $grossAmount,
                ],
                'customer_details' => [
                    'first_name' => $this->customer->name,
                    'email' => $this->customer->email ?? 'cust@example.com',
                    'phone' => $this->customer->phone,
                ],
                'item_details' => $itemDetails
            ];

            $this->snapToken = $midtransService->createSnapToken($params);

            // Dispatch event for frontend to open Snap Popup
            $this->dispatch('snap-token-generated', ['token' => $this->snapToken]);

        } catch (\Exception $e) {
            $this->addError('payment', 'Midtrans Error: ' . $e->getMessage());
        }
    }

    // Called after success payment (frontend can redirect or calling this)
    public function finishDemo()
    {
        // Update status to paid/completed
        $this->transaction->update(['status' => 'paid']);
        $this->service->update(['status' => 'completed']);

        // Decrement Voucher Quota if used
        if (!empty($this->voucherCode) && $this->discountAmount > 0) {
            Voucher::where('code_voucher', $this->voucherCode)
                ->where('workshop_uuid', $this->workshopId)
                ->decrement('quota');
        }

        session()->flash('message', 'Pembayaran Berhasil! Transaksi telah selesai.');

        // Redirect to Demo Form Dashboard as requested so user can see the Feedback button
        return redirect()->route('demo-form');
    }

    public function submitFeedback()
    {
        $this->validate($this->rules[5]);

        \App\Models\Feedback::create([
            'transaction_uuid' => $this->transaction->id,
            'rating' => $this->rating,
            'comment' => $this->feedbackComment,
            'submitted_at' => now(),
        ]);

        session()->flash('message', 'Terima kasih atas masukan Anda! Demo selesai.');
        $this->resetForm();
    }

    #[Layout('layouts.app')]
    public function render()
    {
        // Fetch recent services/transactions for the list
        $query = Service::with(['customer', 'vehicle', 'workshop', 'transaction.feedback']) // Eager load feedback
            ->latest();

        if ($this->search) {
            $query->where(function ($q) {
                $q->where('name', 'like', '%' . $this->search . '%')
                    ->orWhereHas('customer', function ($c) {
                        $c->where('name', 'like', '%' . $this->search . '%');
                    })
                    ->orWhereHas('vehicle', function ($v) {
                        $v->where('plate_number', 'like', '%' . $this->search . '%');
                    });
            });
        }

        if ($this->filterType) {
            $query->where('type', $this->filterType);
        }

        $recentServices = $query->paginate(5);

        return view('livewire.admin.demo.form', [
            'recentServices' => $recentServices
        ]);
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Voucher\StoreVoucherRequest;
use App\Http\Requests\Api\Voucher\UpdateVoucherRequest;
use App\Http\Resources\VoucherResource;
use App\Models\Voucher;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;

class VoucherApiController extends Controller
{
    public function index(Request $request)
    {
        $this->authorize('viewAny', Voucher::class);

        $user = $request->user();

        $vouchers = Voucher::query()
            ->with('workshop')
            ->forUser($user)
            ->when(
                $request->filled('workshop_uuid'),
                fn($q) => $q->where('workshop_uuid', $request->workshop_uuid)
            )
            ->status($request->query('status'))
            ->latest()
            ->paginate(15);

        return VoucherResource::collection($vouchers);
    }

    public function store(StoreVoucherRequest $request)
    {
        $data = $request->validated();

        // cek akses ke workshop
        Gate::authorize('create', [Voucher::class, $data['workshop_uuid']]);

        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('vouchers', 'public');
        }

        $voucher = Voucher::create($data);

        return new VoucherResource($voucher);
    }

    public function show(Voucher $voucher)
    {
        $this->authorize('view', $voucher);

        return new VoucherResource($voucher);
    }

    public function update(UpdateVoucherRequest $request, Voucher $voucher)
    {
        $this->authorize('update', $voucher);

        $data = $request->validated();

        if ($request->hasFile('image')) {
            if ($voucher->image) {
                Storage::disk('public')->delete($voucher->image);
            }

            $data['image'] = $request->file('image')->store('vouchers', 'public');
        }

        $voucher->update($data);

        return new VoucherResource($voucher);
    }

    public function destroy(Voucher $voucher)
    {
        $this->authorize('delete', $voucher);

        if ($voucher->image) {
            Storage::disk('public')->delete($voucher->image);
        }

        $voucher->delete();

        return response()->noContent();
    }

    public function validateVoucher(Request $request)
    {
        $request->validate([
            'code' => 'required|string',
            'amount' => 'required|numeric',
            'workshop_uuid' => 'nullable|string'
        ]);

        $code = $request->code;
        $amount = (float) $request->amount;
        $workshopUuid = $request->workshop_uuid; // Optional override

        $query = Voucher::where('code_voucher', $code)
            ->status('active');

        // Scope to workshop logic
        $user = $request->user();
        if ($user) {
            // If manual workshop override provided (for superadmin/testing), use it
            if ($workshopUuid && ($user->hasRole('superadmin') || $user->hasRole('owner'))) {
                $query->where('workshop_uuid', $workshopUuid);
            } else {
                // Standard scoping
                $query->forUser($user);
            }
        }

        $voucher = $query->first();

        if (!$voucher) {
            return response()->json([
                'valid' => false,
                'message' => 'Voucher tidak ditemukan, tidak aktif, atau tidak berlaku untuk bengkel ini.'
            ], 422);
        }

        // 1. Quota Check
        if ($voucher->quota <= 0) {
            return response()->json([
                'valid' => false,
                'message' => 'Kuota voucher sudah habis.'
            ], 422);
        }

        // 2. Min Transaction Check
        if ($amount < $voucher->min_transaction) {
            return response()->json([
                'valid' => false,
                'message' => 'Minimal transaksi tidak terpenuhi (Min: ' . number_format($voucher->min_transaction) . ').'
            ], 422);
        }

        // 3. Discount Logic
        // Logic: <= 100 means percentage, > 100 means fixed value
        $discountValue = (float) $voucher->discount_value;
        $finalDiscount = 0;

        if ($discountValue <= 100) {
            // Percentage
            $finalDiscount = $amount * ($discountValue / 100);
        } else {
            // Fixed
            $finalDiscount = $discountValue;
        }

        // Ensure discount doesn't exceed transaction amount
        if ($finalDiscount > $amount) {
            $finalDiscount = $amount;
        }

        return response()->json([
            'valid' => true,
            'message' => 'Voucher valid.',
            'voucher_code' => $voucher->code_voucher,
            'discount_amount' => $finalDiscount,
            'type' => ($discountValue <= 100) ? 'percentage' : 'fixed',
            'original_value' => $discountValue
        ]);
    }
}

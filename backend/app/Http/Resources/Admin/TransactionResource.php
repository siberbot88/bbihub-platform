<?php

namespace App\Http\Resources\Admin;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransactionResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'invoice_code' => $this->invoice_code,
            'service_id' => $this->service_uuid,

            // Amount
            'total' => (float) $this->total,
            'formatted_total' => 'Rp ' . number_format($this->total, 0, ',', '.'),

            // Status
            'status' => $this->status, // 'menunggu pembayaran' or 'lunas'
            'payment_method' => $this->payment_method,

            // Items
            'items' => $this->whenLoaded('items', function () {
                return $this->items->map(function ($item) {
                    return [
                        'id' => $item->id,
                        'name' => $item->name,
                        'type' => $item->type, // 'jasa' or 'sparepart'
                        'price' => (float) $item->price,
                        'quantity' => $item->quantity,
                        'subtotal' => (float) $item->subtotal,
                        'formatted_price' => 'Rp ' . number_format($item->price, 0, ',', '.'),
                        'formatted_subtotal' => 'Rp ' . number_format($item->subtotal, 0, ',', '.'),
                    ];
                });
            }),

            // Service info (if needed)
            'service' => $this->when($this->relationLoaded('service'), [
                'code' => $this->service?->code,
                'name' => $this->service?->name,
                'customer_name' => $this->service?->customer?->name,
            ]),

            // Timestamps
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}

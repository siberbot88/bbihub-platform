<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InvoiceResource extends JsonResource
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
            'code' => $this->invoice_code ?? $this->code, // Handle both naming conventions
            'transaction_uuid' => $this->transaction_uuid ?? $this->transaction?->id, // Fallback
            'service_uuid' => $this->service_uuid,
            'customer_uuid' => $this->customer_uuid,
            'workshop_uuid' => $this->workshop_uuid,
            'amount' => $this->total, // Standardize on total
            'total' => $this->total,
            'subtotal' => $this->subtotal,
            'discount' => $this->discount,
            'tax' => $this->tax,
            'status' => $this->status,
            'sent_at' => $this->sent_at?->toISOString(),
            'paid_at' => $this->paid_at?->toISOString(), // If available in model
            'due_date' => $this->due_date?->toISOString(), // If available
            'notes' => $this->notes,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),

            // Direct Relations (Priority for Invoice View)
            'customer' => $this->whenLoaded('customer', function () {
                return [
                    'id' => $this->customer->id,
                    'name' => $this->customer->name,
                    'phone' => $this->customer->phone,
                    'email' => $this->customer->email,
                    'address' => $this->customer->address,
                ];
            }),

            'workshop' => $this->whenLoaded('workshop', function () {
                return [
                    'id' => $this->workshop->id,
                    'name' => $this->workshop->name,
                    'address' => $this->workshop->address,
                    'phone' => $this->workshop->phone,
                    'logo_url' => $this->workshop->logo_url,
                ];
            }),

            // Service & Vehicle (via Service)
            'service' => $this->whenLoaded('service', function () {
                return [
                    'id' => $this->service->id,
                    'code' => $this->service->code,
                    'vehicle' => $this->whenLoaded('service.vehicle', function () {
                        return [
                            'id' => $this->service->vehicle->id,
                            'license_plate' => $this->service->vehicle->license_plate ?? $this->service->vehicle->plate_number,
                            'plate_number' => $this->service->vehicle->license_plate ?? $this->service->vehicle->plate_number, // Alias
                            'brand' => $this->service->vehicle->brand,
                            'model' => $this->service->vehicle->model,
                        ];
                    }),
                ];
            }),

            // Invoice Items (Source of Truth)
            'items' => $this->whenLoaded('items', function () {
                return $this->items->map(function ($item) {
                    return [
                        'id' => $item->id,
                        'name' => $item->name,
                        'type' => $item->type,
                        'quantity' => $item->quantity,
                        'price' => $item->unit_price, // Standardize name
                        'unit_price' => $item->unit_price,
                        'subtotal' => $item->subtotal,
                        'notes' => $item->description,
                    ];
                });
            }),

            // Legacy Transaction Support (Optional)
            'transaction' => $this->whenLoaded('transaction', function () {
                return [
                    'id' => $this->transaction->id,
                    'status' => $this->transaction->status,
                    'items' => $this->transaction->items, // If loaded
                ];
            }),
        ];
    }
}

<?php

namespace App\Http\Resources\Admin;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ServiceResource extends JsonResource
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
            'code' => $this->code,
            'type' => $this->type, // 'booking' or 'on-site'
            'status' => $this->status,
            'acceptance_status' => $this->acceptance_status,

            // Service details
            'name' => $this->name,
            'description' => $this->description,
            'category' => $this->category_service,
            'scheduled_date' => $this->scheduled_date?->format('Y-m-d'),
            'scheduled_time' => $this->estimated_time?->format('H:i'),

            // Customer info (nested)
            'customer' => [
                'id' => $this->customer?->id,
                'name' => $this->customer?->name,
                'phone' => $this->customer?->phone,
                'email' => $this->customer?->email,
            ],

            // Vehicle info (nested)
            'vehicle' => [
                'id' => $this->vehicle?->id,
                'brand' => $this->vehicle?->brand,
                'model' => $this->vehicle?->model,
                'plate_number' => $this->vehicle?->plate_number,
                'year' => $this->vehicle?->year,
                'type' => $this->vehicle?->type,
            ],

            // Mechanic info (only if assigned)
            'mechanic' => $this->when($this->mechanic_uuid, [
                'id' => $this->mechanic?->user_uuid,
                'name' => $this->mechanic?->user?->name,
                'email' => $this->mechanic?->user?->email,
            ]),

            // Service image
            'image_url' => $this->image_path ? url('storage/' . $this->image_path) : null,

            // Rejection info (only if rejected)
            'rejection' => $this->when($this->acceptance_status === 'decline', [
                'reason' => $this->reason,
                'description' => $this->reason_description,
            ]),

            // Timestamps
            'created_at' => $this->created_at?->toIso8601String(),
            'accepted_at' => $this->accepted_at?->toIso8601String(),
            'completed_at' => $this->completed_at?->toIso8601String(),
        ];
    }
}

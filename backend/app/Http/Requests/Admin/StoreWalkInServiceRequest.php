<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreWalkInServiceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin');
    }

    public function rules(): array
    {
        return [
            // Worksheet UUID
            'workshop_uuid' => ['required', 'uuid', 'exists:workshops,id'],

            // Customer data
            'customer_name' => ['required', 'string', 'max:100', 'regex:/^[a-zA-Z\s\.]+$/'],
            'customer_phone' => ['required', 'string', 'regex:/^(\+62|62|0)[0-9]{9,12}$/'],
            'customer_email' => ['nullable', 'email', 'max:100'],

            // Vehicle data
            'vehicle_brand' => ['required', 'string', 'max:50'],
            'vehicle_model' => ['required', 'string', 'max:50'],
            'vehicle_plate' => ['required', 'string', 'max:15', 'regex:/^[A-Z0-9\s]+$/'],
            'vehicle_year' => ['nullable', 'integer', 'min:1900', 'max:' . (date('Y') + 1)],
            'vehicle_type' => ['nullable', 'in:matic,manual,kopling'],
            'vehicle_category' => ['nullable', 'in:motor,mobil'],

            // Service data
            'service_name' => ['required', 'string', 'max:200'],
            'service_description' => ['nullable', 'string', 'max:1000'],
            'scheduled_date' => ['nullable', 'date', 'after_or_equal:today'],
        ];
    }

    public function messages(): array
    {
        return [
            'workshop_uuid.required' => 'Workshop harus dipilih',
            'customer_name.required' => 'Nama customer harus diisi',
            'customer_name.regex' => 'Nama customer hanya boleh huruf dan spasi',
            'customer_phone.required' => 'Nomor telepon harus diisi',
            'customer_phone.regex' => 'Format nomor telepon tidak valid (contoh: 081234567890)',
            'customer_email.email' => 'Format email tidak valid',
            'vehicle_brand.required' => 'Merk kendaraan harus diisi',
            'vehicle_model.required' => 'Model kendaraan harus diisi',
            'vehicle_plate.required' => 'Plat nomor harus diisi',
            'vehicle_plate.regex' => 'Format plat nomor tidak valid (contoh: B1234AB)',
            'service_name.required' => 'Nama service harus diisi',
        ];
    }
}

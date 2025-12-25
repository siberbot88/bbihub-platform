<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class CreateInvoiceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin');
    }

    public function rules(): array
    {
        return [
            'items' => ['required', 'array', 'min:1', 'max:50'],
            'items.*.name' => ['required', 'string', 'max:200'],
            'items.*.type' => ['required', 'in:jasa,sparepart'],
            'items.*.price' => ['required', 'numeric', 'min:0', 'max:99999999'],
            'items.*.quantity' => ['required', 'integer', 'min:1', 'max:999'],
        ];
    }

    public function messages(): array
    {
        return [
            'items.required' => 'Item invoice harus diisi',
            'items.min' => 'Minimal 1 item harus diisi',
            'items.max' => 'Maksimal 50 item',
            'items.*.name.required' => 'Nama item harus diisi',
            'items.*.type.required' => 'Tipe item harus dipilih',
            'items.*.type.in' => 'Tipe item harus jasa atau sparepart',
            'items.*.price.required' => 'Harga item harus diisi',
            'items.*.price.numeric' => 'Harga harus berupa angka',
            'items.*.price.min' => 'Harga minimal 0',
            'items.*.quantity.required' => 'Jumlah item harus diisi',
            'items.*.quantity.integer' => 'Jumlah harus berupa angka bulat',
            'items.*.quantity.min' => 'Jumlah minimal 1',
        ];
    }
}

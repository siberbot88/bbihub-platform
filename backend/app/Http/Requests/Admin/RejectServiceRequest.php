<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Str;

class RejectServiceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin');
    }

    protected function prepareForValidation(): void
    {
        // Sanitize description to prevent XSS
        if ($this->has('reason_description')) {
            $this->merge([
                'reason_description' => Str::of($this->reason_description)->stripTags()->toString()
            ]);
        }
    }

    public function rules(): array
    {
        return [
            'reason' => [
                'required',
                'string',
                'max:100',
                'in:Slot penuh,Waktu tidak sesuai,Service tidak tersedia,Lainnya'
            ],
            'reason_description' => [
                'required',
                'string',
                'max:500',
                'min:10'
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'reason.required' => 'Alasan penolakan harus dipilih',
            'reason.in' => 'Alasan penolakan tidak valid',
            'reason_description.required' => 'Deskripsi alasan harus diisi',
            'reason_description.min' => 'Deskripsi minimal 10 karakter',
            'reason_description.max' => 'Deskripsi maksimal 500 karakter',
        ];
    }
}

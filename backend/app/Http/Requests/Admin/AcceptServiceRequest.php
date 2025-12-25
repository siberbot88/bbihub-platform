<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class AcceptServiceRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // Only admin role can accept services
        return $this->user()->hasRole('admin');
    }

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'mechanic_uuid' => [
                'required',
                'uuid',
                'exists:employments,user_uuid',
            ],
        ];
    }

    /**
     * Get custom error messages.
     */
    public function messages(): array
    {
        return [
            'mechanic_uuid.required' => 'Mekanik harus dipilih',
            'mechanic_uuid.uuid' => 'Format mekanik ID tidak valid',
            'mechanic_uuid.exists' => 'Mekanik tidak ditemukan',
        ];
    }
}

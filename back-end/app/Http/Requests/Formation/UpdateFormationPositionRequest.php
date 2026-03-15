<?php

namespace App\Http\Requests\Formation;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Contracts\Validation\Validator;

class UpdateFormationPositionRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'x' => ['sometimes', 'integer', 'min:0', 'max:100'],
            'y' => ['sometimes', 'integer', 'min:0', 'max:100'],
            'role' => ['sometimes', 'string', 'max:20'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'x.integer' => 'X coordinate must be an integer.',
            'x.min' => 'X coordinate must be at least 0.',
            'x.max' => 'X coordinate must not exceed 100.',
            'y.integer' => 'Y coordinate must be an integer.',
            'y.min' => 'Y coordinate must be at least 0.',
            'y.max' => 'Y coordinate must not exceed 100.',
            'role.string' => 'Role must be a string.',
            'role.max' => 'Role must not exceed 20 characters.',
        ];
    }

    /**
     * Handle a failed validation attempt.
     */
    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(
            response()->json([
                'message' => 'Validation failed.',
                'errors' => $validator->errors(),
            ], 422)
        );
    }
}

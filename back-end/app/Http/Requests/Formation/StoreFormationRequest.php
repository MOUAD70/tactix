<?php

namespace App\Http\Requests\Formation;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Contracts\Validation\Validator;

class StoreFormationRequest extends FormRequest
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
            'name' => ['required', 'string', 'max:20'],
            'positions' => ['required', 'array', 'min:11'],
            'positions.*.role' => ['required', 'string', 'max:20'],
            'positions.*.x' => ['required', 'integer', 'min:0', 'max:100'],
            'positions.*.y' => ['required', 'integer', 'min:0', 'max:100'],
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
            'name.required' => 'Name is required.',
            'name.string' => 'Name must be a string.',
            'name.max' => 'Name must not exceed 20 characters.',
            'positions.required' => 'Positions are required.',
            'positions.array' => 'Positions must be an array.',
            'positions.min' => 'At least 11 positions are required.',
            'positions.*.role.required' => 'Role is required for each position.',
            'positions.*.role.string' => 'Role must be a string.',
            'positions.*.role.max' => 'Role must not exceed 20 characters.',
            'positions.*.x.required' => 'X coordinate is required for each position.',
            'positions.*.x.integer' => 'X coordinate must be an integer.',
            'positions.*.x.min' => 'X coordinate must be at least 0.',
            'positions.*.x.max' => 'X coordinate must not exceed 100.',
            'positions.*.y.required' => 'Y coordinate is required for each position.',
            'positions.*.y.integer' => 'Y coordinate must be an integer.',
            'positions.*.y.min' => 'Y coordinate must be at least 0.',
            'positions.*.y.max' => 'Y coordinate must not exceed 100.',
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

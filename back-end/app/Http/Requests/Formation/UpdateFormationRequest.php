<?php

namespace App\Http\Requests\Formation;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Contracts\Validation\Validator;

class UpdateFormationRequest extends FormRequest
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
            'name' => ['sometimes', 'string', 'max:20'],
            'positions' => ['sometimes', 'array', 'min:11'],
            'positions.*.role' => ['required_with:positions', 'string', 'max:20'],
            'positions.*.x' => ['required_with:positions', 'integer', 'min:0', 'max:100'],
            'positions.*.y' => ['required_with:positions', 'integer', 'min:0', 'max:100'],
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
            'name.string' => 'Name must be a string.',
            'name.max' => 'Name must not exceed 20 characters.',
            'positions.array' => 'Positions must be an array.',
            'positions.min' => 'At least 11 positions are required.',
            'positions.*.role.required_with' => 'Role is required for each position.',
            'positions.*.role.string' => 'Role must be a string.',
            'positions.*.role.max' => 'Role must not exceed 20 characters.',
            'positions.*.x.required_with' => 'X coordinate is required for each position.',
            'positions.*.x.integer' => 'X coordinate must be an integer.',
            'positions.*.x.min' => 'X coordinate must be at least 0.',
            'positions.*.x.max' => 'X coordinate must not exceed 100.',
            'positions.*.y.required_with' => 'Y coordinate is required for each position.',
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

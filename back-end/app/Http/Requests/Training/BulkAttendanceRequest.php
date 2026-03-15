<?php

namespace App\Http\Requests\Training;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Contracts\Validation\Validator;

class BulkAttendanceRequest extends FormRequest
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
            'attendance' => ['required', 'array', 'min:1'],
            'attendance.*.player_id' => ['required', 'integer', 'exists:players,id'],
            'attendance.*.status' => ['required', 'string', 'in:present,absent,late'],
            'attendance.*.note' => ['nullable', 'string', 'max:255'],
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
            'attendance.required' => 'Attendance is required.',
            'attendance.array' => 'Attendance must be an array.',
            'attendance.min' => 'At least one attendance record is required.',
            'attendance.*.player_id.required' => 'Player ID is required.',
            'attendance.*.player_id.integer' => 'Player ID must be an integer.',
            'attendance.*.player_id.exists' => 'Player does not exist.',
            'attendance.*.status.required' => 'Status is required.',
            'attendance.*.status.in' => 'Status must be present, absent, or late.',
            'attendance.*.note.string' => 'Note must be a string.',
            'attendance.*.note.max' => 'Note must not exceed 255 characters.',
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

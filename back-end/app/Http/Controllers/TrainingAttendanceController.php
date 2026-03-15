<?php

namespace App\Http\Controllers;

use App\Http\Requests\Training\BulkAttendanceRequest;
use App\Http\Requests\Training\UpdateAttendanceRequest;
use App\Services\TrainingService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TrainingAttendanceController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @param  TrainingService  $trainingService
     */
    public function __construct(private TrainingService $trainingService)
    {
    }

    /**
     * Submit bulk attendance for a training session.
     *
     * @param  BulkAttendanceRequest  $request
     * @param  int  $sessionId
     * @return JsonResponse
     */
    public function bulkStore(BulkAttendanceRequest $request, int $sessionId): JsonResponse
    {
        $summary = $this->trainingService->bulkAttendance(
            $request->user(),
            $sessionId,
            $request->validated()
        );

        return response()->json([
            'message' => 'Attendance submitted successfully.',
            'data' => [
                'summary' => $summary,
            ],
        ], 200);
    }

    /**
     * Update a single player's attendance record.
     *
     * @param  UpdateAttendanceRequest  $request
     * @param  int  $sessionId
     * @param  int  $playerId
     * @return JsonResponse
     */
    public function updateSingle(UpdateAttendanceRequest $request, int $sessionId, int $playerId): JsonResponse
    {
        $attendance = $this->trainingService->updateAttendance(
            $request->user(),
            $sessionId,
            $playerId,
            $request->validated()
        );

        return response()->json([
            'message' => 'Attendance updated successfully.',
            'data' => $attendance,
        ], 200);
    }
}

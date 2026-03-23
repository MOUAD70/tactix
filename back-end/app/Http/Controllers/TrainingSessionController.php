<?php

namespace App\Http\Controllers;

use App\Http\Requests\Training\StoreTrainingSessionRequest;
use App\Http\Requests\Training\UpdateTrainingSessionRequest;
use App\Services\TrainingService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TrainingSessionController extends Controller
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
     * List training sessions for a team.
     *
     * @param  Request  $request
     * @param  int  $teamId
     * @return JsonResponse
     */
    public function index(Request $request, int $teamId): JsonResponse
    {
        $sessions = $this->trainingService->index($request->user(), $teamId);

        return response()->json([
            'data' => $sessions,
        ], 200);
    }

    /**
     * Get a single training session with attendance.
     *
     * @param  Request  $request
     * @param  int  $sessionId
     * @return JsonResponse
     */
    public function show(Request $request, int $sessionId): JsonResponse
    {
        $session = $this->trainingService->show($request->user(), $sessionId);

        return response()->json([
            'data' => $session,
        ], 200);
    }

    /**
     * Create a new training session.
     *
     * @param  StoreTrainingSessionRequest  $request
     * @param  int  $teamId
     * @return JsonResponse
     */
    public function store(StoreTrainingSessionRequest $request, int $teamId): JsonResponse
    {
        $session = $this->trainingService->store(
            $request->user(),
            $teamId,
            $request->validated()
        );

        return response()->json([
            'message' => 'Training session created successfully.',
            'data' => [
                'id' => $session->id,
                'team_id' => $session->team_id,
                'title' => $session->title,
                'description' => $session->description,
                'session_date' => $session->session_date,
                'tactical_data' => $session->tactical_data,
            ],
        ], 201);
    }

    /**
     * Update an existing training session.
     *
     * @param  UpdateTrainingSessionRequest  $request
     * @param  int  $sessionId
     * @return JsonResponse
     */
    public function update(UpdateTrainingSessionRequest $request, int $sessionId): JsonResponse
    {
        $session = $this->trainingService->update(
            $request->user(),
            $sessionId,
            $request->validated()
        );

        return response()->json([
            'message' => 'Training session updated successfully.',
            'data' => [
                'id' => $session->id,
                'team_id' => $session->team_id,
                'title' => $session->title,
                'description' => $session->description,
                'session_date' => $session->session_date,
                'tactical_data' => $session->tactical_data,
            ],
        ], 200);
    }

    /**
     * Delete a training session.
     *
     * @param  Request  $request
     * @param  int  $sessionId
     * @return JsonResponse
     */
    public function destroy(Request $request, int $sessionId): JsonResponse
    {
        $this->trainingService->destroy($request->user(), $sessionId);

        return response()->json([
            'message' => 'Training session deleted successfully.',
        ], 200);
    }
}

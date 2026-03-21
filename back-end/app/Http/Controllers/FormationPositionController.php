<?php

namespace App\Http\Controllers;

use App\Http\Requests\Formation\UpdateFormationPositionRequest;
use App\Services\FormationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FormationPositionController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @param  FormationService  $formationService
     */
    public function __construct(private FormationService $formationService)
    {
    }

    /**
     * Update a single formation position (drag & drop).
     *
     * @param  UpdateFormationPositionRequest  $request
     * @param  int  $formationId
     * @param  int  $positionId
     * @return JsonResponse
     */
    public function update(UpdateFormationPositionRequest $request, int $formationId, int $positionId): JsonResponse
    {
        $position = $this->formationService->updatePosition(
            $request->user(),
            $formationId,
            $positionId,
            $request->validated()
        );

        return response()->json([
            'message' => 'Position updated successfully.',
            'data' => $position,
        ], 200);
    }
}

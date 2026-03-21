<?php

namespace App\Http\Controllers;

use App\Http\Requests\Formation\StoreFormationRequest;
use App\Http\Requests\Formation\UpdateFormationRequest;
use App\Services\FormationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FormationController extends Controller
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
     * List formations available to the authenticated user.
     *
     * @param  Request  $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $formations = $this->formationService->index($request->user());

        return response()->json([
            'data' => $formations,
        ], 200);
    }

    /**
     * Get a single formation with its positions.
     *
     * @param  Request  $request
     * @param  int  $formationId
     * @return JsonResponse
     */
    public function show(Request $request, int $formationId): JsonResponse
    {
        $formation = $this->formationService->show($request->user(), $formationId);

        return response()->json([
            'data' => $formation,
        ], 200);
    }

    /**
     * Create a new formation.
     *
     * @param  StoreFormationRequest  $request
     * @return JsonResponse
     */
    public function store(StoreFormationRequest $request): JsonResponse
    {
        $formation = $this->formationService->store(
            $request->user(),
            $request->validated()
        );

        return response()->json([
            'message' => 'Formation created successfully.',
            'data' => $formation,
        ], 201);
    }

    /**
     * Update an existing formation.
     *
     * @param  UpdateFormationRequest  $request
     * @param  int  $formationId
     * @return JsonResponse
     */
    public function update(UpdateFormationRequest $request, int $formationId): JsonResponse
    {
        $formation = $this->formationService->update(
            $request->user(),
            $formationId,
            $request->validated()
        );

        return response()->json([
            'message' => 'Formation updated successfully.',
            'data' => $formation,
        ], 200);
    }

    /**
     * Remove a formation.
     *
     * @param  Request  $request
     * @param  int  $formationId
     * @return JsonResponse
     */
    public function destroy(Request $request, int $formationId): JsonResponse
    {
        $this->formationService->destroy($request->user(), $formationId);

        return response()->json([
            'message' => 'Formation deleted successfully.',
        ], 200);
    }

    /**
     * Copy a global template formation into the coach's team.
     *
     * @param  Request  $request
     * @param  int  $formationId
     * @return JsonResponse
     */
    public function copy(Request $request, int $formationId): JsonResponse
    {
        $formation = $this->formationService->copy($request->user(), $formationId);

        return response()->json([
            'message' => 'Formation copied to your team successfully.',
            'data' => $formation,
        ], 201);
    }
}

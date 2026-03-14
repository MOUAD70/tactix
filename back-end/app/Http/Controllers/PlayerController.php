<?php

namespace App\Http\Controllers;

use App\Http\Requests\Player\StorePlayerRequest;
use App\Http\Requests\Player\UpdatePlayerRequest;
use App\Services\PlayerService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PlayerController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @param  PlayerService  $playerService
     */
    public function __construct(private PlayerService $playerService)
    {
    }

    /**
     * Get all players for a specific team.
     *
     * @param  Request  $request
     * @param  int  $teamId
     * @return JsonResponse
     */
    public function index(Request $request, int $teamId): JsonResponse
    {
        $players = $this->playerService->index($request->user(), $teamId);

        return response()->json([
            'data' => $players,
        ], 200);
    }

    /**
     * Get a single player by ID.
     *
     * @param  Request  $request
     * @param  int  $playerId
     * @return JsonResponse
     */
    public function show(Request $request, int $playerId): JsonResponse
    {
        $player = $this->playerService->show($request->user(), $playerId);

        return response()->json([
            'data' => $player,
        ], 200);
    }

    /**
     * Add a new player to a team.
     *
     * @param  StorePlayerRequest  $request
     * @param  int  $teamId
     * @return JsonResponse
     */
    public function store(StorePlayerRequest $request, int $teamId): JsonResponse
    {
        $player = $this->playerService->store(
            $request->user(),
            $teamId,
            $request->validated()
        );

        return response()->json([
            'message' => 'Player added successfully.',
            'data' => $player,
        ], 201);
    }

    /**
     * Update an existing player.
     *
     * @param  UpdatePlayerRequest  $request
     * @param  int  $playerId
     * @return JsonResponse
     */
    public function update(UpdatePlayerRequest $request, int $playerId): JsonResponse
    {
        $player = $this->playerService->update(
            $request->user(),
            $playerId,
            $request->validated()
        );

        return response()->json([
            'message' => 'Player updated successfully.',
            'data' => $player,
        ], 200);
    }

    /**
     * Remove a player from a team.
     *
     * @param  Request  $request
     * @param  int  $playerId
     * @return JsonResponse
     */
    public function destroy(Request $request, int $playerId): JsonResponse
    {
        $this->playerService->destroy($request->user(), $playerId);

        return response()->json([
            'message' => 'Player removed successfully.',
        ], 200);
    }
}

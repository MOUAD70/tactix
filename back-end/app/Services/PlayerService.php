<?php

namespace App\Services;

use App\Models\Player;
use App\Models\Team;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class PlayerService
{
    /**
     * Get all players for a specific team.
     *
     * @param  User  $user
     * @param  int  $teamId
     * @return Collection<int, Player>
     */
    public function index(User $user, int $teamId): Collection
    {
        // Verify the team exists
        if (!Team::find($teamId)) {
            abort(404, 'Team not found.');
        }

        // Enforce scope: coaches can only view their own team's players
        $this->ensureUserCanAccessTeam($user, $teamId);

        return Player::where('team_id', $teamId)->get();
    }

    /**
     * Get a single player by ID.
     *
     * @param  User  $user
     * @param  int  $playerId
     * @return Player
     */
    public function show(User $user, int $playerId): Player
    {
        $player = Player::find($playerId);

        if (!$player) {
            abort(404, 'Player not found.');
        }

        // Enforce scope: coaches can only view players from their own team
        $this->ensureUserCanAccessTeam($user, $player->team_id);

        return $player;
    }

    /**
     * Create a new player in a team.
     *
     * @param  User  $user
     * @param  int  $teamId
     * @param  array  $data
     * @return Player
     */
    public function store(User $user, int $teamId, array $data): Player
    {
        // Verify the team exists
        if (!Team::find($teamId)) {
            abort(404, 'Team not found.');
        }

        // Enforce scope: coaches can only add players to their own team
        $this->ensureUserCanAccessTeam($user, $teamId);

        // Check for unique jersey_number within the team
        if (isset($data['jersey_number']) && $data['jersey_number'] !== null) {
            $existing = Player::where('team_id', $teamId)
                ->where('jersey_number', $data['jersey_number'])
                ->first();

            if ($existing) {
                abort(409, 'A player with this jersey number already exists in this team.');
            }
        }

        // Add the team_id to the data
        $data['team_id'] = $teamId;

        return Player::create($data);
    }

    /**
     * Update an existing player.
     *
     * @param  User  $user
     * @param  int  $playerId
     * @param  array  $data
     * @return Player
     */
    public function update(User $user, int $playerId, array $data): Player
    {
        $player = Player::find($playerId);

        if (!$player) {
            abort(404, 'Player not found.');
        }

        // Enforce scope: coaches can only update players from their own team
        $this->ensureUserCanAccessTeam($user, $player->team_id);

        // Check for unique jersey_number within the team (only if jersey_number is in the update data)
        if (isset($data['jersey_number']) && $data['jersey_number'] !== null) {
            $existing = Player::where('team_id', $player->team_id)
                ->where('jersey_number', $data['jersey_number'])
                ->where('id', '!=', $playerId)
                ->first();

            if ($existing) {
                abort(409, 'A player with this jersey number already exists in this team.');
            }
        }

        $player->update($data);

        return $player;
    }

    /**
     * Delete a player.
     *
     * @param  User  $user
     * @param  int  $playerId
     * @return void
     */
    public function destroy(User $user, int $playerId): void
    {
        $player = Player::find($playerId);

        if (!$player) {
            abort(404, 'Player not found.');
        }

        // Enforce scope: coaches can only delete players from their own team
        $this->ensureUserCanAccessTeam($user, $player->team_id);

        $player->delete();
    }

    /**
     * Ensure the authenticated user can access a specific team.
     * Coaches can only access their own team. Admins can access any team.
     *
     * @param  User  $user
     * @param  int  $teamId
     * @return void
     */
    private function ensureUserCanAccessTeam(User $user, int $teamId): void
    {
        // Admins can access all teams
        if ($user->role === 'admin') {
            return;
        }

        // Coaches can only access their own team
        if ($user->role === 'coach' && $user->team_id !== $teamId) {
            abort(403, 'You are not authorized to manage this team\'s players.');
        }
    }
}

<?php

namespace App\Services;

use App\Models\Formation;
use App\Models\FormationPosition;
use App\Models\Team;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class FormationService
{
    /**
     * Get formations visible to the authenticated user.
     *
     * @param  User  $user
     * @return Collection<int, Formation>
     */
    public function index(User $user): Collection
    {
        if ($user->role === 'admin') {
            return Formation::whereNull('team_id')->with('positions')->get();
        }

        // Coaches can only view their own team's formations
        $teamId = $this->getCoachTeamId($user);

        return Formation::where('team_id', $teamId)
            ->with('positions')
            ->get();
    }

    /**
     * Get a single formation by ID.
     *
     * @param  User  $user
     * @param  int  $formationId
     * @return Formation
     */
    public function show(User $user, int $formationId): Formation
    {
        $formation = Formation::with('positions')->find($formationId);

        if (!$formation) {
            abort(404, 'Formation not found.');
        }

        $this->ensureUserCanManageFormation($user, $formation);

        return $formation;
    }

    /**
     * Create a new formation with positions.
     *
     * @param  User  $user
     * @param  array  $data
     * @return Formation
     */
    public function store(User $user, array $data): Formation
    {
        $teamId = $user->role === 'admin' ? null : $this->getCoachTeamId($user);

        $this->ensureFormationNameIsUnique($data['name'], $teamId);
        $this->ensureNoDuplicateCoordinates($data['positions']);

        return DB::transaction(function () use ($data, $teamId) {
            $formation = Formation::create([
                'name' => $data['name'],
                'team_id' => $teamId,
            ]);

            $formation->positions()->createMany($data['positions']);

            return $formation->load('positions');
        });
    }

    /**
     * Update a formation's name and/or replace its positions.
     *
     * @param  User  $user
     * @param  int  $formationId
     * @param  array  $data
     * @return Formation
     */
    public function update(User $user, int $formationId, array $data): Formation
    {
        $formation = Formation::with('positions')->find($formationId);

        if (!$formation) {
            abort(404, 'Formation not found.');
        }

        $this->ensureUserCanManageFormation($user, $formation);

        // Validate uniqueness if name is being changed
        if (isset($data['name'])) {
            $this->ensureFormationNameIsUnique($data['name'], $formation->team_id, $formation->id);
        }

        if (isset($data['positions'])) {
            $this->ensureNoDuplicateCoordinates($data['positions']);
        }

        return DB::transaction(function () use ($formation, $data) {
            if (isset($data['name'])) {
                $formation->name = $data['name'];
                $formation->save();
            }

            if (isset($data['positions'])) {
                $formation->positions()->delete();
                $formation->positions()->createMany($data['positions']);
            }

            return $formation->load('positions');
        });
    }

    /**
     * Delete a formation.
     *
     * @param  User  $user
     * @param  int  $formationId
     * @return void
     */
    public function destroy(User $user, int $formationId): void
    {
        $formation = Formation::find($formationId);

        if (!$formation) {
            abort(404, 'Formation not found.');
        }

        $this->ensureUserCanManageFormation($user, $formation);

        $formation->delete();
    }

    /**
     * Copy a global template formation into the coach's team.
     *
     * @param  User  $user
     * @param  int  $formationId
     * @return Formation
     */
    public function copy(User $user, int $formationId): Formation
    {
        if ($user->role !== 'coach') {
            abort(403, 'You are not authorized to perform this action.');
        }

        $formation = Formation::with('positions')->find($formationId);

        if (!$formation) {
            abort(404, 'Formation not found.');
        }

        if ($formation->team_id !== null) {
            abort(403, 'You can only copy global formation templates.');
        }

        $teamId = $this->getCoachTeamId($user);

        $this->ensureFormationNameIsUnique($formation->name, $teamId);

        return DB::transaction(function () use ($formation, $teamId) {
            $copy = Formation::create([
                'name' => $formation->name,
                'team_id' => $teamId,
            ]);

            $copy->positions()->createMany($formation->positions->map(function ($position) {
                return [
                    'role' => $position->role,
                    'x' => $position->x,
                    'y' => $position->y,
                ];
            })->toArray());

            return $copy->load('positions');
        });
    }

    /**
     * Update a single formation position.
     *
     * @param  User  $user
     * @param  int  $formationId
     * @param  int  $positionId
     * @param  array  $data
     * @return FormationPosition
     */
    public function updatePosition(User $user, int $formationId, int $positionId, array $data): FormationPosition
    {
        $formation = Formation::find($formationId);

        if (!$formation) {
            abort(404, 'Formation not found.');
        }

        $this->ensureUserCanManageFormation($user, $formation);

        $position = FormationPosition::find($positionId);

        if (!$position) {
            abort(404, 'Position not found.');
        }

        if ($position->formation_id !== $formationId) {
            abort(404, 'Position does not belong to this formation.');
        }

        $newX = $data['x'] ?? $position->x;
        $newY = $data['y'] ?? $position->y;

        if (array_key_exists('x', $data) || array_key_exists('y', $data)) {
            $conflict = FormationPosition::where('formation_id', $formationId)
                ->where('id', '!=', $positionId)
                ->where('x', $newX)
                ->where('y', $newY)
                ->first();

            if ($conflict) {
                abort(409, 'Another position already occupies these coordinates in this formation.');
            }
        }

        $position->update($data);

        return $position;
    }

    /**
     * Ensure the formation name is unique within a team scope.
     *
     * @param  string  $name
     * @param  int|null  $teamId
     * @param  int|null  $exceptId
     * @return void
     */
    private function ensureFormationNameIsUnique(string $name, ?int $teamId, ?int $exceptId = null): void
    {
        $query = Formation::where('name', $name);

        if ($teamId === null) {
            $query->whereNull('team_id');
        } else {
            $query->where('team_id', $teamId);
        }

        if ($exceptId !== null) {
            $query->where('id', '!=', $exceptId);
        }

        if ($query->exists()) {
            abort(409, 'A formation with this name already exists in your team.');
        }
    }

    /**
     * Ensure there are no duplicate (x,y) coordinates within the given positions list.
     *
     * @param  array  $positions
     * @return void
     */
    private function ensureNoDuplicateCoordinates(array $positions): void
    {
        $seen = [];

        foreach ($positions as $position) {
            $key = sprintf('%s:%s', $position['x'] ?? '', $position['y'] ?? '');

            if (isset($seen[$key])) {
                abort(409, 'Another position already occupies these coordinates in this formation.');
            }

            $seen[$key] = true;
        }
    }

    /**
     * Ensure the user can manage the given formation based on role and team.
     *
     * @param  User  $user
     * @param  Formation  $formation
     * @return void
     */
    private function ensureUserCanManageFormation(User $user, Formation $formation): void
    {
        if ($user->role === 'admin') {
            if ($formation->team_id !== null) {
                abort(403, 'You are not authorized to manage this formation.');
            }

            return;
        }

        // Only coaches reach here.
        $teamId = $this->getCoachTeamId($user);

        if ($formation->team_id !== $teamId) {
            abort(403, 'You are not authorized to manage this formation.');
        }
    }

    /**
     * Get the coach's team id, aborting if not set.
     *
     * @param  User  $user
     * @return int
     */
    private function getCoachTeamId(User $user): int
    {
        if ($user->role !== 'coach') {
            abort(403, 'You are not authorized to manage this formation.');
        }

        if (!$user->team_id) {
            abort(403, 'You are not authorized to manage this formation.');
        }

        // Verify the team exists
        if (!Team::find($user->team_id)) {
            abort(404, 'Team not found.');
        }

        return $user->team_id;
    }
}

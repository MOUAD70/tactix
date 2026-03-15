<?php

namespace App\Services;

use App\Models\Player;
use App\Models\Team;
use App\Models\TrainingAttendance;
use App\Models\TrainingSession;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class TrainingService
{
    /**
     * Get all training sessions for a team.
     *
     * @param  User  $user
     * @param  int  $teamId
     * @return Collection<int, TrainingSession>
     */
    public function index(User $user, int $teamId): Collection
    {
        // Ensure team exists
        if (!Team::find($teamId)) {
            abort(404, 'Team not found.');
        }

        // Coach can only view own team
        $this->ensureUserCanAccessTeam($user, $teamId);

        $sessions = TrainingSession::where('team_id', $teamId)
            ->with('attendance')
            ->get();

        return $sessions->map(function (TrainingSession $session) {
            $summary = $this->calculateSummary($session->attendance);

            return [
                'id' => $session->id,
                'team_id' => $session->team_id,
                'title' => $session->title,
                'description' => $session->description,
                'session_date' => $session->session_date,
                'created_at' => $session->created_at,
                'updated_at' => $session->updated_at,
                'summary' => $summary,
            ];
        });
    }

    /**
     * Get a single training session with full attendance.
     *
     * @param  User  $user
     * @param  int  $sessionId
     * @return TrainingSession
     */
    public function show(User $user, int $sessionId): TrainingSession
    {
        $session = TrainingSession::with(['attendance.player'])->find($sessionId);

        if (!$session) {
            abort(404, 'Training session not found.');
        }

        $this->ensureUserCanAccessTeam($user, $session->team_id);

        $attendance = $session->attendance->map(function (TrainingAttendance $record) {
            return [
                'player_id' => $record->player_id,
                'name' => $record->player?->name,
                'status' => $record->status,
                'note' => $record->note,
            ];
        });

        $summary = $this->calculateSummary($session->attendance);

        return (object) array_merge($session->toArray(), [
            'attendance' => $attendance,
            'summary' => $summary,
        ]);
    }

    /**
     * Create a new training session.
     *
     * @param  User  $user
     * @param  int  $teamId
     * @param  array  $data
     * @return TrainingSession
     */
    public function store(User $user, int $teamId, array $data): TrainingSession
    {
        // Ensure team exists
        if (!Team::find($teamId)) {
            abort(404, 'Team not found.');
        }

        $this->ensureUserCanAccessTeam($user, $teamId);

        $data['team_id'] = $teamId;

        return TrainingSession::create($data);
    }

    /**
     * Update a training session.
     *
     * @param  User  $user
     * @param  int  $sessionId
     * @param  array  $data
     * @return TrainingSession
     */
    public function update(User $user, int $sessionId, array $data): TrainingSession
    {
        $session = TrainingSession::find($sessionId);

        if (!$session) {
            abort(404, 'Training session not found.');
        }

        $this->ensureUserCanAccessTeam($user, $session->team_id);

        $session->update($data);

        return $session;
    }

    /**
     * Delete a training session.
     *
     * @param  User  $user
     * @param  int  $sessionId
     * @return void
     */
    public function destroy(User $user, int $sessionId): void
    {
        $session = TrainingSession::find($sessionId);

        if (!$session) {
            abort(404, 'Training session not found.');
        }

        $this->ensureUserCanAccessTeam($user, $session->team_id);

        $session->delete();
    }

    /**
     * Submit bulk attendance for a session.
     *
     * @param  User  $user
     * @param  int  $sessionId
     * @param  array  $data
     * @return array{total:int, present:int, absent:int, late:int}
     */
    public function bulkAttendance(User $user, int $sessionId, array $data): array
    {
        $session = TrainingSession::find($sessionId);

        if (!$session) {
            abort(404, 'Training session not found.');
        }

        $this->ensureUserCanAccessTeam($user, $session->team_id);

        $attendance = $data['attendance'];

        $this->ensureUniquePlayerIds($attendance);
        $this->ensurePlayersBelongToTeam($attendance, $session->team_id);

        return DB::transaction(function () use ($session, $attendance) {
            $session->attendance()->delete();

            foreach ($attendance as $record) {
                TrainingAttendance::create([
                    'training_id' => $session->id,
                    'player_id' => $record['player_id'],
                    'status' => $record['status'],
                    'note' => $record['note'] ?? null,
                ]);
            }

            return $this->calculateSummary($session->attendance()->get());
        });
    }

    /**
     * Update a single attendance record.
     *
     * @param  User  $user
     * @param  int  $sessionId
     * @param  int  $playerId
     * @param  array  $data
     * @return array<string, mixed>
     */
    public function updateAttendance(User $user, int $sessionId, int $playerId, array $data): array
    {
        $session = TrainingSession::find($sessionId);

        if (!$session) {
            abort(404, 'Training session not found.');
        }

        $this->ensureUserCanAccessTeam($user, $session->team_id);

        $attendance = TrainingAttendance::where('training_id', $sessionId)
            ->where('player_id', $playerId)
            ->first();

        if (!$attendance) {
            abort(404, 'Attendance record not found for this player.');
        }

        $attendance->update($data);

        $player = Player::find($playerId);

        return [
            'player_id' => $playerId,
            'name' => $player?->name,
            'status' => $attendance->status,
            'note' => $attendance->note,
        ];
    }

    /**
     * Ensure all provided player IDs belong to the given team.
     *
     * @param  array  $attendance
     * @param  int  $teamId
     * @return void
     */
    private function ensurePlayersBelongToTeam(array $attendance, int $teamId): void
    {
        $playerIds = array_column($attendance, 'player_id');

        $count = Player::whereIn('id', $playerIds)
            ->where('team_id', $teamId)
            ->count();

        if ($count !== count(array_unique($playerIds))) {
            abort(422, 'One or more players do not belong to this team.');
        }
    }

    /**
     * Ensure player IDs in attendance are unique.
     *
     * @param  array  $attendance
     * @return void
     */
    private function ensureUniquePlayerIds(array $attendance): void
    {
        $seen = [];

        foreach ($attendance as $record) {
            $playerId = $record['player_id'];

            if (isset($seen[$playerId])) {
                abort(409, 'An attendance record already exists for this player in this session.');
            }

            $seen[$playerId] = true;
        }
    }

    /**
     * Calculate attendance summary counts.
     *
     * @param  \Illuminate\Database\Eloquent\Collection<int, TrainingAttendance>  $attendance
     * @return array{total:int, present:int, absent:int, late:int}
     */
    private function calculateSummary($attendance): array
    {
        $total = $attendance->count();
        $present = $attendance->where('status', 'present')->count();
        $absent = $attendance->where('status', 'absent')->count();
        $late = $attendance->where('status', 'late')->count();

        return [
            'total' => $total,
            'present' => $present,
            'absent' => $absent,
            'late' => $late,
        ];
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
            abort(403, 'You are not authorized to manage this training session.');
        }
    }
}

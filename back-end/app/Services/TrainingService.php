<?php

namespace App\Services;

use App\Models\Player;
use App\Models\Team;
use App\Models\TrainingAttendance;
use App\Models\TrainingSession;
use App\Models\User;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class TrainingService
{
    public function index(User $user, int $teamId): Collection
    {
        if (!Team::find($teamId)) {
            abort(404, 'Team not found.');
        }

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

    public function show(User $user, int $sessionId): object
    {
        $session = TrainingSession::with(['attendance.player'])->findOrFail($sessionId);

        $this->ensureUserCanAccessTeam($user, $session->team_id);

        if ($session->attendance->isEmpty()) {
            $players = Player::where('team_id', $session->team_id)->get();
            $attendance = $players->map(function ($player) {
                return [
                    'player_id' => $player->id,
                    'name' => $player->name,
                    'status' => 'present',
                    'note' => null,
                ];
            });
        } else {
            $attendance = $session->attendance->map(function (TrainingAttendance $record) {
                return [
                    'player_id' => $record->player_id,
                    'name' => $record->player?->name ?? 'Unknown',
                    'status' => $record->status,
                    'note' => $record->note,
                ];
            });
        }

        $summary = $this->calculateSummary($session->attendance);

        return (object) array_merge($session->toArray(), [
            'attendance' => $attendance,
            'summary' => $summary,
        ]);
    }

    public function store(User $user, int $teamId, array $data): TrainingSession
    {
        if (!Team::find($teamId)) {
            abort(404, 'Team not found.');
        }

        $this->ensureUserCanAccessTeam($user, $teamId);

        $data['team_id'] = $teamId;

        return TrainingSession::create($data);
    }

    public function update(User $user, int $sessionId, array $data): TrainingSession
    {
        $session = TrainingSession::findOrFail($sessionId);

        $this->ensureUserCanAccessTeam($user, $session->team_id);

        $session->update($data);

        return $session;
    }

    public function destroy(User $user, int $sessionId): void
    {
        $session = TrainingSession::findOrFail($sessionId);

        $this->ensureUserCanAccessTeam($user, $session->team_id);

        $session->delete();
    }

    public function bulkAttendance(User $user, int $sessionId, array $data): array
    {
        $session = TrainingSession::findOrFail($sessionId);

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

    private function ensureUniquePlayerIds(array $attendance): void
    {
        $seen = [];

        foreach ($attendance as $record) {
            $playerId = $record['player_id'];

            if (isset($seen[$playerId])) {
                abort(409, 'An attendance record already exists for this player.');
            }

            $seen[$playerId] = true;
        }
    }

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

    private function ensureUserCanAccessTeam(User $user, int $teamId): void
    {
        if ($user->role === 'admin') {
            return;
        }

        if ($user->role === 'coach' && $user->team_id !== $teamId) {
            abort(403, 'You are not authorized to manage this session.');
        }
    }
}

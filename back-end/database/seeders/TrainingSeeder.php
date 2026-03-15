<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TrainingSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $sessions = [
            [
                'team_id' => 1,
                'title' => 'Tactical Pressing Session',
                'description' => 'Focus on high press triggers and defensive shape',
                'session_date' => '2026-03-10',
            ],
            [
                'team_id' => 1,
                'title' => 'Set Pieces Training',
                'description' => 'Corner kicks, free kicks, defensive and offensive',
                'session_date' => '2026-03-12',
            ],
            [
                'team_id' => 1,
                'title' => 'Physical Conditioning',
                'description' => 'Endurance runs, sprint drills, recovery',
                'session_date' => '2026-03-14',
            ],
        ];

        $playerIds = DB::table('players')
            ->where('team_id', 1)
            ->pluck('id')
            ->toArray();

        foreach ($sessions as $session) {
            DB::table('training_sessions')->updateOrInsert(
                [
                    'team_id' => $session['team_id'],
                    'title' => $session['title'],
                    'session_date' => $session['session_date'],
                ],
                [
                    'description' => $session['description'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );

            $sessionRecord = DB::table('training_sessions')
                ->where('team_id', $session['team_id'])
                ->where('title', $session['title'])
                ->where('session_date', $session['session_date'])
                ->first();

            if (!$sessionRecord) {
                continue;
            }

            foreach ($playerIds as $index => $playerId) {
                $status = 'present';
                $note = null;

                // Mix in absent/late statuses for a realistic dataset
                if ($index === 9) {
                    $status = 'absent';
                    $note = 'Injured';
                }

                if ($index === 10) {
                    $status = 'late';
                    $note = 'Traffic delay';
                }

                DB::table('training_attendance')->updateOrInsert(
                    [
                        'training_id' => $sessionRecord->id,
                        'player_id' => $playerId,
                    ],
                    [
                        'status' => $status,
                        'note' => $note,
                    ]
                );
            }
        }
    }
}

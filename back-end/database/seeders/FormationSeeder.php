<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class FormationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $formations = [
            [
                'name' => '4-3-3',
                'positions' => [
                    ['role' => 'GK',  'x' => 50, 'y' => 5],
                    ['role' => 'LB',  'x' => 15, 'y' => 25],
                    ['role' => 'CB',  'x' => 35, 'y' => 25],
                    ['role' => 'CB',  'x' => 65, 'y' => 25],
                    ['role' => 'RB',  'x' => 85, 'y' => 25],
                    ['role' => 'CM',  'x' => 25, 'y' => 55],
                    ['role' => 'CDM', 'x' => 50, 'y' => 45],
                    ['role' => 'CM',  'x' => 75, 'y' => 55],
                    ['role' => 'LW',  'x' => 15, 'y' => 80],
                    ['role' => 'ST',  'x' => 50, 'y' => 88],
                    ['role' => 'RW',  'x' => 85, 'y' => 80],
                ],
            ],
            [
                'name' => '4-4-2',
                'positions' => [
                    ['role' => 'GK',  'x' => 50, 'y' => 5],
                    ['role' => 'LB',  'x' => 15, 'y' => 25],
                    ['role' => 'CB',  'x' => 35, 'y' => 25],
                    ['role' => 'CB',  'x' => 65, 'y' => 25],
                    ['role' => 'RB',  'x' => 85, 'y' => 25],
                    ['role' => 'LM',  'x' => 15, 'y' => 55],
                    ['role' => 'CM',  'x' => 35, 'y' => 55],
                    ['role' => 'CM',  'x' => 65, 'y' => 55],
                    ['role' => 'RM',  'x' => 85, 'y' => 55],
                    ['role' => 'ST',  'x' => 35, 'y' => 85],
                    ['role' => 'ST',  'x' => 65, 'y' => 85],
                ],
            ],
            [
                'name' => '4-2-3-1',
                'positions' => [
                    ['role' => 'GK',  'x' => 50, 'y' => 5],
                    ['role' => 'LB',  'x' => 15, 'y' => 25],
                    ['role' => 'CB',  'x' => 35, 'y' => 25],
                    ['role' => 'CB',  'x' => 65, 'y' => 25],
                    ['role' => 'RB',  'x' => 85, 'y' => 25],
                    ['role' => 'CDM', 'x' => 35, 'y' => 45],
                    ['role' => 'CDM', 'x' => 65, 'y' => 45],
                    ['role' => 'LW',  'x' => 15, 'y' => 68],
                    ['role' => 'CAM', 'x' => 50, 'y' => 68],
                    ['role' => 'RW',  'x' => 85, 'y' => 68],
                    ['role' => 'ST',  'x' => 50, 'y' => 88],
                ],
            ],
        ];

        foreach ($formations as $formation) {
            $formationId = DB::table('formations')->updateOrInsert(
                ['name' => $formation['name'], 'team_id' => null],
                [
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );

            $formationRecord = DB::table('formations')
                ->where('name', $formation['name'])
                ->whereNull('team_id')
                ->first();

            if (!$formationRecord) {
                continue;
            }

            foreach ($formation['positions'] as $position) {
                DB::table('formation_positions')->updateOrInsert(
                    [
                        'formation_id' => $formationRecord->id,
                        'x' => $position['x'],
                        'y' => $position['y'],
                    ],
                    [
                        'role' => $position['role'],
                    ]
                );
            }
        }
    }
}

<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PlayerSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('players')->updateOrInsert(
            ['team_id' => 1, 'jersey_number' => 1],
            [
                'name'           => 'Karim Mansouri',
                'position'       => 'GK',
                'date_of_birth'  => '1995-03-12',
                'created_at'     => now(),
                'updated_at'     => now(),
            ]
        );

        DB::table('players')->updateOrInsert(
            ['team_id' => 1, 'jersey_number' => 2],
            [
                'name'           => 'Youssef Alami',
                'position'       => 'RB',
                'date_of_birth'  => '1998-07-24',
                'created_at'     => now(),
                'updated_at'     => now(),
            ]
        );

        DB::table('players')->updateOrInsert(
            ['team_id' => 1, 'jersey_number' => 5],
            [
                'name'           => 'Hassan Berrada',
                'position'       => 'CB',
                'date_of_birth'  => '1997-01-15',
                'created_at'     => now(),
                'updated_at'     => now(),
            ]
        );

        DB::table('players')->updateOrInsert(
            ['team_id' => 1, 'jersey_number' => 6],
            [
                'name'           => 'Mehdi Tahiri',
                'position'       => 'CB',
                'date_of_birth'  => '1996-09-08',
                'created_at'     => now(),
                'updated_at'     => now(),
            ]
        );

        DB::table('players')->updateOrInsert(
            ['team_id' => 1, 'jersey_number' => 3],
            [
                'name'           => 'Amine Benali',
                'position'       => 'LB',
                'date_of_birth'  => '1999-04-30',
                'created_at'     => now(),
                'updated_at'     => now(),
            ]
        );

        DB::table('players')->updateOrInsert(
            ['team_id' => 1, 'jersey_number' => 8],
            [
                'name'           => 'Rachid Moukrim',
                'position'       => 'CM',
                'date_of_birth'  => '1997-11-20',
                'created_at'     => now(),
                'updated_at'     => now(),
            ]
        );

        DB::table('players')->updateOrInsert(
            ['team_id' => 1, 'jersey_number' => 4],
            [
                'name'           => 'Samir Idrissi',
                'position'       => 'CDM',
                'date_of_birth'  => '1995-06-17',
                'created_at'     => now(),
                'updated_at'     => now(),
            ]
        );

        DB::table('players')->updateOrInsert(
            ['team_id' => 1, 'jersey_number' => 10],
            [
                'name'           => 'Omar Cherkaoui',
                'position'       => 'CAM',
                'date_of_birth'  => '2000-02-11',
                'created_at'     => now(),
                'updated_at'     => now(),
            ]
        );

        DB::table('players')->updateOrInsert(
            ['team_id' => 1, 'jersey_number' => 7],
            [
                'name'           => 'Bilal Kettani',
                'position'       => 'RW',
                'date_of_birth'  => '2001-08-05',
                'created_at'     => now(),
                'updated_at'     => now(),
            ]
        );

        DB::table('players')->updateOrInsert(
            ['team_id' => 1, 'jersey_number' => 11],
            [
                'name'           => 'Tariq Bensouda',
                'position'       => 'LW',
                'date_of_birth'  => '2000-12-28',
                'created_at'     => now(),
                'updated_at'     => now(),
            ]
        );

        DB::table('players')->updateOrInsert(
            ['team_id' => 1, 'jersey_number' => 9],
            [
                'name'           => 'Zakaria Hajji',
                'position'       => 'ST',
                'date_of_birth'  => '1998-05-03',
                'created_at'     => now(),
                'updated_at'     => now(),
            ]
        );
    }
}

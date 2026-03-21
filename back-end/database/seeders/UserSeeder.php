<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('users')->updateOrInsert(
            ['email' => 'mouad@tactix.com'],
            [
                'name'       => 'Mouad',
                'password'   => Hash::make('password123'),
                'role'       => 'admin',
                'team_id'    => null,
                'created_at' => now(),
                'updated_at' => now(),
            ]
        );

        DB::table('users')->updateOrInsert(
            ['email' => 'taoufik@tactix.com'],
            [
                'name'       => 'Taoufik',
                'password'   => Hash::make('password123'),
                'role'       => 'coach',
                'team_id'    => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]
        );
    }
}

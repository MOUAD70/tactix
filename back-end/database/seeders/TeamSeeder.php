<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TeamSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('teams')->updateOrInsert(
            ['id' => 1],
            ['name' => 'Tactix FC', 'created_at' => now(), 'updated_at' => now()]
        );
    }
}

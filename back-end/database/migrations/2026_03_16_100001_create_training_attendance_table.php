<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('training_attendance', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->foreignId('training_id')->constrained('training_sessions')->cascadeOnDelete();
            $table->foreignId('player_id')->constrained('players')->cascadeOnDelete();
            $table->enum('status', ['present', 'absent', 'late'])->default('present');
            $table->string('note', 255)->nullable();

            // Unique constraint: one attendance record per player per session
            $table->unique(['training_id', 'player_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('training_attendance');
    }
};

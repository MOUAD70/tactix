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
        Schema::create('formation_positions', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->foreignId('formation_id')->constrained('formations')->cascadeOnDelete();
            $table->string('role', 20)->nullable();
            $table->integer('x')->nullable();
            $table->integer('y')->nullable();

            // Unique constraint: no two positions in the same formation may share the same coordinates
            $table->unique(['formation_id', 'x', 'y']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('formation_positions');
    }
};

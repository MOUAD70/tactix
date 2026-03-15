<?php

use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\FormationController;
use App\Http\Controllers\FormationPositionController;
use App\Http\Controllers\PlayerController;
use Illuminate\Support\Facades\Route;

// Public authentication routes
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Authenticated routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);

    // Player routes
    Route::get('/teams/{team_id}/players', [PlayerController::class, 'index']);
    Route::post('/teams/{team_id}/players', [PlayerController::class, 'store']);
    Route::get('/players/{id}', [PlayerController::class, 'show']);
    Route::put('/players/{id}', [PlayerController::class, 'update']);
    Route::delete('/players/{id}', [PlayerController::class, 'destroy']);

    // Formation routes
    Route::get('/formations', [FormationController::class, 'index']);
    Route::get('/formations/{id}', [FormationController::class, 'show']);
    Route::post('/formations', [FormationController::class, 'store']);
    Route::put('/formations/{id}', [FormationController::class, 'update']);
    Route::delete('/formations/{id}', [FormationController::class, 'destroy']);
    Route::post('/formations/{id}/copy', [FormationController::class, 'copy'])->middleware('role:coach');

    // Position update route
    Route::patch('/formations/{formation_id}/positions/{position_id}', [FormationPositionController::class, 'update']);
});

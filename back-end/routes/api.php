<?php

use App\Http\Controllers\Auth\AuthController;
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
});

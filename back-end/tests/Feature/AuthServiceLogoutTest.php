<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\AuthService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\TransientToken;
use Tests\TestCase;

class AuthServiceLogoutTest extends TestCase
{
    use RefreshDatabase;

    public function test_logout_deletes_the_current_personal_access_token(): void
    {
        $user = User::factory()->create();
        $accessToken = $user->createToken('auth_token')->accessToken;

        app(AuthService::class)->logout($user->withAccessToken($accessToken));

        $this->assertModelMissing($accessToken);
    }

    public function test_logout_ignores_transient_tokens(): void
    {
        $user = User::factory()->create();
        $storedToken = $user->createToken('auth_token')->accessToken;

        app(AuthService::class)->logout($user->withAccessToken(new TransientToken()));

        $this->assertNotNull($storedToken->fresh());
    }
}
<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\PersonalAccessToken;

class AuthService
{
    /**
     * Register a new coach user.
     *
     * @param  array  $data
     * @return User
     *
     * @throws ValidationException
     */
    public function register(array $data): User
    {
        // All new registrations are assigned the coach role
        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'role' => 'coach',
            'team_id' => $data['team_id'],
        ]);

        return $user;
    }

    /**
     * Login user and return a Sanctum token.
     *
     * @param  array  $credentials
     * @return array
     */
    public function login(array $credentials): array
    {
        $user = User::where('email', $credentials['email'])->first();

        if (!$user || !Hash::check($credentials['password'], $user->password)) {
            abort(401, 'The provided credentials are incorrect.');
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return [
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'team_id' => $user->team_id,
            ],
        ];
    }

    /**
     * Logout user by revoking the current token.
     *
     * @param  User  $user
     * @return void
     */
    public function logout(User $user): void
    {
        $token = $user->currentAccessToken();

        if ($token instanceof PersonalAccessToken) {
            $token->delete();
        }
    }

    /**
     * Get the current user profile.
     *
     * @param  User  $user
     * @return array
     */
    public function getMe(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'team_id' => $user->team_id,
            'created_at' => $user->created_at,
            'updated_at' => $user->updated_at,
        ];
    }
}

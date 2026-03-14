<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Player extends Model
{
    /** @use HasFactory<\Database\Factories\PlayerFactory> */
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'jersey_number',
        'position',
        'date_of_birth',
        'team_id',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'date_of_birth' => 'date',
        ];
    }

    /**
     * Get the team that owns this player.
     *
     * @return BelongsTo<Team>
     */
    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }

    /**
     * Get the player's age calculated from date_of_birth.
     * Age is never stored in the database — it is always calculated dynamically.
     *
     * @return int|null
     */
    public function getAgeAttribute(): ?int
    {
        if ($this->date_of_birth) {
            return Carbon::parse($this->date_of_birth)->age;
        }

        return null;
    }

    /**
     * Append the age attribute to the model's JSON representation.
     *
     * @var array
     */
    protected $appends = ['age'];
}

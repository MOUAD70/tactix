<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasManyThrough;

class TrainingSession extends Model
{
    /** @use HasFactory<\Database\Factories\TrainingSessionFactory> */
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'team_id',
        'title',
        'description',
        'session_date',
    ];

    /**
     * Get the team that owns this training session.
     *
     * @return BelongsTo<Team>
     */
    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }

    /**
     * Get the attendance records for this session.
     *
     * @return HasMany<TrainingAttendance>
     */
    public function attendance(): HasMany
    {
        return $this->hasMany(TrainingAttendance::class, 'training_id');
    }

    /**
     * Get players who participated in this session through attendance.
     *
     * @return HasManyThrough<Player, TrainingAttendance>
     */
    public function players(): HasManyThrough
    {
        return $this->hasManyThrough(
            Player::class,
            TrainingAttendance::class,
            'training_id', // Foreign key on training_attendance table...
            'id', // Foreign key on players table...
            'id', // Local key on training_sessions table...
            'player_id' // Local key on training_attendance table...
        );
    }
}

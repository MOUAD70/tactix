<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TrainingAttendance extends Model
{
    /** @use HasFactory<\Database\Factories\TrainingAttendanceFactory> */
    use HasFactory;
    protected $table = 'training_attendance';

    /**
     * Disable timestamps for this model.
     *
     * @var bool
     */
    public $timestamps = false;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'training_id',
        'player_id',
        'status',
        'note',
    ];

    /**
     * Get the training session that owns this attendance.
     *
     * @return BelongsTo<TrainingSession>
     */
    public function training(): BelongsTo
    {
        return $this->belongsTo(TrainingSession::class, 'training_id');
    }

    /**
     * Get the player that this attendance record belongs to.
     *
     * @return BelongsTo<Player>
     */
    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class);
    }
}

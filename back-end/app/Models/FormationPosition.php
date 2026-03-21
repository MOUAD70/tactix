<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FormationPosition extends Model
{
    /** @use HasFactory<\Database\Factories\FormationPositionFactory> */
    use HasFactory;

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
        'formation_id',
        'role',
        'x',
        'y',
    ];

    /**
     * Get the formation that owns this position.
     *
     * @return BelongsTo<Formation>
     */
    public function formation(): BelongsTo
    {
        return $this->belongsTo(Formation::class);
    }
}

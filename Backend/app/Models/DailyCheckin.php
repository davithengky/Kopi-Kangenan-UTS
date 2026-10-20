<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Check-in yang sudah dilakukan pengguna (MemberStore.checkedDays).
 * `period` berformat YYYY-MM supaya hitungan 6 hari direset tiap bulan.
 */
class DailyCheckin extends Model
{
    protected $table = 'daily_checkins';

    public $timestamps = false;

    protected $fillable = ['user_id', 'day_number', 'period', 'reward_label', 'claimed_at'];

    protected function casts(): array
    {
        return [
            'day_number' => 'integer',
            'claimed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

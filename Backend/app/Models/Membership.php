<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Poin dan total belanja pengguna (MemberStore).
 *
 * Level membership TIDAK disimpan — dihitung dari `total_spent`, sama seperti
 * `MemberStore.level` di aplikasi Flutter.
 */
class Membership extends Model
{
    /**
     * Level beserta ambang belanjanya (MemberLevel).
     * Format: label => [min_spend, next_threshold].
     */
    public const LEVELS = [
        'Silver' => [0, 700000],
        'Gold' => [700000, 9999999],
        'Black' => [9999999, 0],
    ];

    protected $fillable = ['user_id', 'points', 'total_spent'];

    protected function casts(): array
    {
        return [
            'points' => 'integer',
            'total_spent' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /** Level saat ini: Silver / Gold / Black. */
    public function level(): string
    {
        if ($this->total_spent >= self::LEVELS['Black'][0]) {
            return 'Black';
        }

        if ($this->total_spent >= self::LEVELS['Gold'][0]) {
            return 'Gold';
        }

        return 'Silver';
    }

    public function isHighest(): bool
    {
        return $this->level() === 'Black';
    }

    /** Belanja yang dibutuhkan untuk naik ke level berikutnya (0 = tertinggi). */
    public function nextThreshold(): int
    {
        return self::LEVELS[$this->level()][1];
    }

    /** Sisa belanja menuju level berikutnya. */
    public function remainingToNextLevel(): int
    {
        if ($this->isHighest()) {
            return 0;
        }

        return max(0, $this->nextThreshold() - $this->total_spent);
    }

    /** Progres 0.0–1.0 menuju level berikutnya. */
    public function levelProgress(): float
    {
        if ($this->isHighest()) {
            return 1.0;
        }

        $base = self::LEVELS[$this->level()][0];
        $range = $this->nextThreshold() - $base;

        if ($range <= 0) {
            return 1.0;
        }

        return max(0.0, min(1.0, ($this->total_spent - $base) / $range));
    }

    public function toApi(): array
    {
        $level = $this->level();

        return [
            'points' => $this->points,
            'total_spent' => $this->total_spent,
            'level' => [
                'label' => $level,
                'min_spend' => self::LEVELS[$level][0],
                'next_threshold' => self::LEVELS[$level][1],
                'is_highest' => $this->isHighest(),
            ],
            'level_progress' => round($this->levelProgress(), 4),
            'remaining_to_next_level' => $this->remainingToNextLevel(),
        ];
    }
}

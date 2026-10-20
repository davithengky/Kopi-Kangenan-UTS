<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** Satu baris riwayat poin (PointEntry). */
class PointEntry extends Model
{
    protected $table = 'point_entries';

    /** Tabel hanya punya `created_at`, tidak ada `updated_at`. */
    public const UPDATED_AT = null;

    protected $fillable = ['user_id', 'title', 'delta', 'order_id'];

    protected function casts(): array
    {
        return [
            'delta' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'delta' => $this->delta,
            'date' => $this->created_at?->diffForHumans(),
        ];
    }
}

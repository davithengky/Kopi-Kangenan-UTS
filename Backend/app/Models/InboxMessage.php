<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** Satu notifikasi di Kotak Masuk (InboxMessage). */
class InboxMessage extends Model
{
    protected $table = 'inbox_messages';

    protected $fillable = ['user_id', 'title', 'body', 'kind', 'read_at'];

    protected function casts(): array
    {
        return [
            'read_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function isRead(): bool
    {
        return $this->read_at !== null;
    }

    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'body' => $this->body,
            'kind' => $this->kind,
            'read' => $this->isRead(),
            'date' => $this->created_at?->diffForHumans(),
        ];
    }
}

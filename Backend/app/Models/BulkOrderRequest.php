<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** Permintaan pesanan jumlah besar (BulkOrderScreen). */
class BulkOrderRequest extends Model
{
    protected $table = 'bulk_order_requests';

    protected $fillable = [
        'user_id',
        'name',
        'contact',
        'purpose',
        'estimated_cups',
        'event_date',
        'note',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'estimated_cups' => 'integer',
            'event_date' => 'date',
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
            'name' => $this->name,
            'contact' => $this->contact,
            'purpose' => $this->purpose,
            'estimated_cups' => $this->estimated_cups,
            'event_date' => $this->event_date?->toDateString(),
            'note' => $this->note,
            'status' => $this->status,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}

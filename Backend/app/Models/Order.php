<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/** Pesanan (Order). Kode berformat `#1001`. */
class Order extends Model
{
    /** Status yang urut maju (OrderStatus di Flutter). */
    public const STATUS_FLOW = ['Pending', 'Processing', 'Ready', 'Completed'];

    protected $fillable = [
        'code',
        'user_id',
        'outlet_id',
        'subtotal',
        'bag_fee',
        'voucher_discount',
        'points_used',
        'total',
        'payment_method_id',
        'payment_method',
        'fulfilment',
        'status',
        'scheduled_at',
    ];

    protected function casts(): array
    {
        return [
            'subtotal' => 'integer',
            'bag_fee' => 'integer',
            'voucher_discount' => 'integer',
            'points_used' => 'integer',
            'total' => 'integer',
            'scheduled_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function outlet(): BelongsTo
    {
        return $this->belongsTo(Outlet::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    /** Sudah tidak bisa dibatalkan (Completed / Cancelled). */
    public function isFinal(): bool
    {
        return in_array($this->status, ['Completed', 'Cancelled'], true);
    }

    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'code' => $this->code,
            'items' => $this->relationLoaded('items')
                ? $this->items->map(fn (OrderItem $i) => $i->toApi())->all()
                : [],
            'subtotal' => $this->subtotal,
            'bag_fee' => $this->bag_fee,
            'voucher_discount' => $this->voucher_discount,
            'points_used' => $this->points_used,
            'total' => $this->total,
            'payment_method' => $this->payment_method,
            'payment_method_id' => $this->payment_method_id,
            'fulfilment' => $this->fulfilment,
            'status' => $this->status,
            'is_final' => $this->isFinal(),
            'scheduled_at' => $this->scheduled_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}

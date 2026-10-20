<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/** Keranjang belanja pengguna (CartStore). */
class Cart extends Model
{
    protected $fillable = ['user_id'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(CartItem::class);
    }

    public function toApi(): array
    {
        $items = $this->items->map(fn (CartItem $i) => $i->toApi())->all();

        return [
            'items' => $items,
            'total_quantity' => array_sum(array_column($items, 'quantity')),
            'total_price' => array_sum(array_column($items, 'total_price')),
        ];
    }
}

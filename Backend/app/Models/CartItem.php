<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Satu baris keranjang (CartItem).
 *
 * Menyimpan SNAPSHOT nama + harga karena model CartItem di Flutter tidak
 * menyimpan product_id; `toppings`/`syrups` disimpan sebagai JSON.
 */
class CartItem extends Model
{
    protected $table = 'cart_items';

    protected $appends = ['total_price'];

    protected $fillable = [
        'cart_id',
        'product_id',
        'name',
        'image_path',
        'base_price',
        'unit_price',
        'quantity',
        'size',
        'milk',
        'sugar',
        'ice',
        'toppings',
        'syrups',
        'note',
    ];

    protected function casts(): array
    {
        return [
            'base_price' => 'integer',
            'unit_price' => 'integer',
            'quantity' => 'integer',
            'toppings' => 'array',
            'syrups' => 'array',
        ];
    }

    public function cart(): BelongsTo
    {
        return $this->belongsTo(Cart::class);
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function getTotalPriceAttribute(): int
    {
        return $this->unit_price * $this->quantity;
    }

    /** Baris kustomisasi untuk ditampilkan, mis. "Large · Oatside · No Sugar". */
    public function customizationLines(): array
    {
        return array_values(array_filter(array_merge(
            [$this->size],
            [$this->milk],
            [$this->sugar],
            [$this->ice],
            $this->toppings ?? [],
            $this->syrups ?? [],
        )));
    }

    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'name' => $this->name,
            'image' => $this->image_path,
            'base_price' => $this->base_price,
            'unit_price' => $this->unit_price,
            'quantity' => $this->quantity,
            'total_price' => $this->total_price,
            'size' => $this->size,
            'milk' => $this->milk,
            'sugar' => $this->sugar,
            'ice' => $this->ice,
            'toppings' => $this->toppings ?? [],
            'syrups' => $this->syrups ?? [],
            'note' => $this->note,
        ];
    }
}

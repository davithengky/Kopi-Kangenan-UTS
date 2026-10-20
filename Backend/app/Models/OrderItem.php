<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** Isi pesanan — snapshot CartItem pada saat checkout. */
class OrderItem extends Model
{
    protected $table = 'order_items';

    public $timestamps = false;

    protected $fillable = [
        'order_id',
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

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
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
            'total_price' => $this->unit_price * $this->quantity,
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

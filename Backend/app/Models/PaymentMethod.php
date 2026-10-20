<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/** Metode pembayaran (PaymentMethod / kPaymentMethods). */
class PaymentMethod extends Model
{
    protected $table = 'payment_methods';

    protected $primaryKey = 'id';

    public $incrementing = false;

    protected $keyType = 'string';

    public $timestamps = false;

    protected $fillable = [
        'id',
        'name',
        'subtitle',
        'icon_key',
        'brand_color',
        'needs_connection',
        'is_active',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'needs_connection' => 'boolean',
            'is_active' => 'boolean',
        ];
    }

    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'subtitle' => $this->subtitle,
            'icon_key' => $this->icon_key,
            'brand_color' => $this->brand_color,
            'needs_connection' => $this->needs_connection,
        ];
    }
}

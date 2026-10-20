<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** Alamat pengiriman tersimpan (Address / AddressStore). */
class Address extends Model
{
    protected $fillable = [
        'user_id',
        'label',
        'recipient',
        'phone',
        'detail',
        'note',
        'is_default',
    ];

    protected function casts(): array
    {
        return [
            'is_default' => 'boolean',
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
            'label' => $this->label,
            'recipient' => $this->recipient,
            'phone' => $this->phone,
            'detail' => $this->detail,
            'note' => $this->note,
            'is_default' => $this->is_default,
        ];
    }
}

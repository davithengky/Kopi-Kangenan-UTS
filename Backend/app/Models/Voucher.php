<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Voucher (Voucher). Dipakai untuk dua hal: katalog contoh yang bisa
 * dimasukkan langsung, dan template voucher yang diberikan saat membeli paket.
 */
class Voucher extends Model
{
    protected $fillable = [
        'code',
        'title',
        'description',
        'kind',
        'percent',
        'amount',
        'min_purchase',
        'validity',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'percent' => 'integer',
            'amount' => 'integer',
            'min_purchase' => 'integer',
            'is_active' => 'boolean',
        ];
    }

    /** Potongan untuk `$subtotal`, dibatasi agar tidak melebihi subtotal. */
    public function discountFor(int $subtotal): int
    {
        if ($this->min_purchase > 0 && $subtotal < $this->min_purchase) {
            return 0;
        }

        if ($this->percent > 0) {
            $value = intdiv($subtotal * $this->percent, 100);

            return min($value, $subtotal);
        }

        return min($this->amount, $subtotal);
    }

    public function isApplicable(int $subtotal): bool
    {
        return $this->discountFor($subtotal) > 0;
    }

    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'code' => $this->code,
            'title' => $this->title,
            'description' => $this->description,
            'kind' => $this->kind,
            'percent' => $this->percent,
            'amount' => $this->amount,
            'min_purchase' => $this->min_purchase,
            'validity' => $this->validity,
        ];
    }
}

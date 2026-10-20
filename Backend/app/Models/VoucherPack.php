<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

/** Paket voucher yang bisa dibeli (VoucherPack / kVoucherPacks). */
class VoucherPack extends Model
{
    protected $table = 'voucher_packs';

    protected $primaryKey = 'id';

    public $incrementing = false;

    protected $keyType = 'string';

    public $timestamps = false;

    protected $fillable = [
        'id',
        'title',
        'description',
        'old_price',
        'price',
        'saving',
        'count_label',
        'is_active',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'old_price' => 'integer',
            'price' => 'integer',
            'is_active' => 'boolean',
        ];
    }

    public function vouchers(): BelongsToMany
    {
        return $this->belongsToMany(Voucher::class, 'pack_vouchers', 'pack_id', 'voucher_id')
            ->withPivot('quantity');
    }

    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'old_price' => $this->old_price,
            'price' => $this->price,
            'saving' => $this->saving,
            'count' => $this->count_label,
        ];
    }
}

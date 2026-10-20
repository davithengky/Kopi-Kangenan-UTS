<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** Promo yang sudah diklaim (VoucherStore.claimedPromos). */
class PromoClaim extends Model
{
    protected $table = 'promo_claims';

    public $timestamps = false;

    protected $fillable = ['user_id', 'label', 'claimed_at'];

    protected function casts(): array
    {
        return [
            'claimed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

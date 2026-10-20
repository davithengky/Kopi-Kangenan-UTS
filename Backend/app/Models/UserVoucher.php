<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** Voucher milik pengguna (VoucherStore.userVouchers). */
class UserVoucher extends Model
{
    protected $table = 'user_vouchers';

    protected $fillable = [
        'user_id',
        'voucher_id',
        'code',
        'status',
        'claimed_at',
        'used_at',
        'order_id',
    ];

    protected function casts(): array
    {
        return [
            'claimed_at' => 'datetime',
            'used_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function voucher(): BelongsTo
    {
        return $this->belongsTo(Voucher::class);
    }

    public function toApi(): array
    {
        $data = $this->voucher?->toApi() ?? [];
        $data['code'] = $this->code;
        $data['status'] = $this->status;

        return $data;
    }
}

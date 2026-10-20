<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** Metode pembayaran milik pengguna yang sudah dihubungkan / dipilih. */
class UserPaymentMethod extends Model
{
    protected $table = 'user_payment_methods';

    protected $fillable = ['user_id', 'payment_method_id', 'is_connected', 'is_selected'];

    protected function casts(): array
    {
        return [
            'is_connected' => 'boolean',
            'is_selected' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function paymentMethod(): BelongsTo
    {
        return $this->belongsTo(PaymentMethod::class, 'payment_method_id');
    }
}

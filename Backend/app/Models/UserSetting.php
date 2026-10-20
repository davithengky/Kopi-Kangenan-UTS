<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** Preferensi aplikasi: bahasa, notifikasi, biometrik (SettingsStore). */
class UserSetting extends Model
{
    protected $table = 'user_settings';

    protected $fillable = [
        'user_id',
        'language',
        'notif_promo',
        'notif_pesanan',
        'biometric',
    ];

    protected function casts(): array
    {
        return [
            'notif_promo' => 'boolean',
            'notif_pesanan' => 'boolean',
            'biometric' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function toApi(): array
    {
        return [
            'language' => $this->language,
            'notif_promo' => $this->notif_promo,
            'notif_pesanan' => $this->notif_pesanan,
            'biometric' => $this->biometric,
        ];
    }
}

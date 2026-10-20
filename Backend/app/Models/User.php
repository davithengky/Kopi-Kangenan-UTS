<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

/**
 * Akun pengguna.
 *
 * Dua sumber data di aplikasi Flutter digabung di sini:
 * - AuthUser  : name + identifier (email atau nomor HP)
 * - _Account  : password + provider
 */
class User extends Authenticatable
{
    use HasApiTokens;

    protected $fillable = [
        'name',
        'identifier',
        'identifier_type',
        'password',
        'provider',
    ];

    protected $hidden = ['password'];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
        ];
    }

    // --- Relasi -----------------------------------------------------------

    public function settings(): HasOne
    {
        return $this->hasOne(UserSetting::class);
    }

    public function membership(): HasOne
    {
        return $this->hasOne(Membership::class);
    }

    public function addresses(): HasMany
    {
        return $this->hasMany(Address::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    public function pointEntries(): HasMany
    {
        return $this->hasMany(PointEntry::class);
    }

    public function userVouchers(): HasMany
    {
        return $this->hasMany(UserVoucher::class);
    }

    public function promoClaims(): HasMany
    {
        return $this->hasMany(PromoClaim::class);
    }

    public function checkins(): HasMany
    {
        return $this->hasMany(DailyCheckin::class);
    }

    public function cart(): HasOne
    {
        return $this->hasOne(Cart::class);
    }

    public function inboxMessages(): HasMany
    {
        return $this->hasMany(InboxMessage::class);
    }

    public function userPaymentMethods(): HasMany
    {
        return $this->hasMany(UserPaymentMethod::class);
    }

    // --- Pembantu ---------------------------------------------------------

    /** Nama siap ditampilkan; `Guest` bila belum diisi. */
    public function displayName(): string
    {
        return $this->name !== '' ? $this->name : 'Guest';
    }

    /** Bentuk ringkas untuk respons API. */
    public function toApi(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'identifier' => $this->identifier,
            'identifier_type' => $this->identifier_type,
            'provider' => $this->provider,
        ];
    }
}

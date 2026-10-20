<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserVoucher;
use App\Models\Voucher;

/**
 * Logika voucher.
 *
 * Meniru `lib/providers/voucher_store.dart`:
 * - cari dulu di voucher milik pengguna, lalu di katalog contoh;
 * - voucher katalog yang dipakai otomatis masuk ke akun pengguna.
 */
class VoucherService
{
    /** Mencari voucher berdasarkan kode, tanpa mengaitkannya ke pengguna. */
    public function find(string $rawCode): ?Voucher
    {
        $code = strtoupper(trim($rawCode));

        if ($code === '') {
            return null;
        }

        return Voucher::whereRaw('UPPER(code) = ?', [$code])
            ->where('is_active', true)
            ->first();
    }

    /**
     * Memvalidasi kode voucher untuk pengguna.
     *
     * Bila kode berasal dari katalog, voucher otomatis ditambahkan ke akun
     * pengguna (perilaku `VoucherStore.validateCode`).
     *
     * @return array{voucher:Voucher,discount:int,user_voucher:?UserVoucher}
     */
    public function resolve(User $user, string $rawCode, int $subtotal = 0): array
    {
        $voucher = $this->find($rawCode);

        if ($voucher === null) {
            throw new \RuntimeException('Kode voucher tidak dikenal atau sudah kadaluarsa.');
        }

        $userVoucher = $this->ensureOwned($user, $voucher);

        return [
            'voucher' => $voucher,
            'discount' => $voucher->discountFor($subtotal),
            'user_voucher' => $userVoucher,
        ];
    }

    /** Memastikan pengguna memiliki baris voucher untuk kode tersebut. */
    public function ensureOwned(User $user, Voucher $voucher): UserVoucher
    {
        $existing = UserVoucher::where('user_id', $user->id)
            ->whereRaw('UPPER(code) = ?', [strtoupper($voucher->code)])
            ->where('status', 'available')
            ->first();

        if ($existing !== null) {
            return $existing;
        }

        return UserVoucher::create([
            'user_id' => $user->id,
            'voucher_id' => $voucher->id,
            'code' => $voucher->code,
            'status' => 'available',
            'claimed_at' => now(),
        ]);
    }

    /** Menandai voucher pengguna sudah dipakai pada sebuah pesanan. */
    public function markUsed(User $user, string $code, int $orderId): void
    {
        UserVoucher::where('user_id', $user->id)
            ->whereRaw('UPPER(code) = ?', [strtoupper($code)])
            ->where('status', 'available')
            ->update([
                'status' => 'used',
                'used_at' => now(),
                'order_id' => $orderId,
            ]);
    }
}

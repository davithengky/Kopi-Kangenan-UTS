<?php

namespace App\Services;

use App\Models\CheckinReward;
use App\Models\DailyCheckin;
use App\Models\Membership;
use App\Models\PointEntry;
use App\Models\User;

/**
 * Logika poin, level, dan Daily Check-In.
 *
 * Meniru `lib/providers/member_store.dart`:
 * - dapat 1 poin untuk setiap Rp1.000 belanja;
 * - 1 poin = Rp1 saat dipakai;
 * - check-in 6 hari per bulan, hadiah dibaca dari tabel `checkin_rewards`.
 */
class MemberService
{
    public const MAX_CHECK_IN_DAYS = 6;

    /** Mengambil (atau membuat) baris membership milik pengguna. */
    public function membershipFor(User $user): Membership
    {
        return Membership::firstOrCreate(
            ['user_id' => $user->id],
            ['points' => 0, 'total_spent' => 0],
        );
    }

    /** Hadiah check-in untuk hari ke-`$day` (1–6). */
    public function rewardForDay(int $day): ?CheckinReward
    {
        return CheckinReward::where('day_number', $day)->first();
    }

    public function allRewards(): array
    {
        return CheckinReward::orderBy('day_number')->get()->all();
    }

    /** Periode bulan berjalan, mis. `2026-10`. */
    public function currentPeriod(): string
    {
        return now()->format('Y-m');
    }

    /** Nomor hari yang sudah dipakai check-in pada bulan berjalan. */
    public function checkedDays(User $user): array
    {
        return DailyCheckin::where('user_id', $user->id)
            ->where('period', $this->currentPeriod())
            ->orderBy('day_number')
            ->pluck('day_number')
            ->all();
    }

    public function canCheckInToday(User $user): bool
    {
        return count($this->checkedDays($user)) < self::MAX_CHECK_IN_DAYS;
    }

    /**
     * Melakukan check-in hari ini.
     *
     * @return array{day:int,reward:string,points:int}
     */
    public function checkIn(User $user): array
    {
        if (! $this->canCheckInToday($user)) {
            throw new \RuntimeException('Kamu sudah check-in 6 hari. Sampai jumpa bulan depan!');
        }

        $day = count($this->checkedDays($user)) + 1;
        $reward = $this->rewardForDay($day);

        if ($reward === null) {
            throw new \RuntimeException('Hadiah check-in belum tersedia.');
        }

        DailyCheckin::create([
            'user_id' => $user->id,
            'day_number' => $day,
            'period' => $this->currentPeriod(),
            'reward_label' => $reward->reward_label,
            'claimed_at' => now(),
        ]);

        $points = 0;

        if ($reward->reward_type === 'points') {
            $points = (int) $reward->reward_value;
            $this->addPoints($user, $points, "Daily Check-In hari ke-{$day}");
        } else {
            // Hadiah voucher: catat di riwayat poin tanpa perubahan saldo.
            PointEntry::create([
                'user_id' => $user->id,
                'title' => "Daily Check-In hari ke-{$day}",
                'delta' => 0,
            ]);
        }

        return ['day' => $day, 'reward' => $reward->reward_label, 'points' => $points];
    }

    /** Menambah poin beserta catatan riwayatnya. */
    public function addPoints(User $user, int $amount, string $title, ?int $orderId = null): void
    {
        if ($amount === 0) {
            return;
        }

        $membership = $this->membershipFor($user);
        $membership->points += $amount;
        $membership->save();

        PointEntry::create([
            'user_id' => $user->id,
            'title' => $title,
            'delta' => $amount,
            'order_id' => $orderId,
        ]);
    }

    /** Memakai poin; jumlahnya dibatasi saldo yang ada. */
    public function redeemPoints(User $user, int $amount, string $title, ?int $orderId = null): int
    {
        $membership = $this->membershipFor($user);
        $used = min($amount, $membership->points);

        if ($used <= 0) {
            return 0;
        }

        $membership->points -= $used;
        $membership->save();

        PointEntry::create([
            'user_id' => $user->id,
            'title' => $title,
            'delta' => -$used,
            'order_id' => $orderId,
        ]);

        return $used;
    }

    /** Mencatat belanja + poin yang didapat dari sebuah pesanan. */
    public function registerSpend(User $user, int $total, string $orderCode, ?int $orderId = null): int
    {
        $membership = $this->membershipFor($user);
        $membership->total_spent += $total;
        $membership->save();

        $earned = intdiv($total, 1000);

        if ($earned > 0) {
            $this->addPoints($user, $earned, "Belanja pesanan {$orderCode}", $orderId);
        }

        return $earned;
    }
}

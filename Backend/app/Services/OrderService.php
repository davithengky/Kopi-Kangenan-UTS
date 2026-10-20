<?php

namespace App\Services;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\PaymentMethod;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

/**
 * Pembuatan & perubahan status pesanan.
 *
 * Meniru `lib/providers/order_store.dart`:
 * total = subtotal + bag_fee - voucher_discount - points_used (tidak negatif);
 * kode pesanan berformat `#XXXX` (mulai `#1002` untuk pesanan baru).
 */
class OrderService
{
    public function __construct(
        private MemberService $members,
        private VoucherService $vouchers,
    ) {}

    /**
     * Membuat pesanan baru.
     *
     * Poin yang dipakai langsung dipotong, voucher ditandai terpakai, lalu
     * belanja dicatat untuk poin dan level membership.
     */
    public function create(User $user, array $data): Order
    {
        $items = $data['items'] ?? [];

        if (! is_array($items) || $items === []) {
            throw new InvalidArgumentException('Keranjang masih kosong.');
        }

        return DB::transaction(function () use ($user, $data, $items) {
            $subtotal = 0;

            foreach ($items as $item) {
                $subtotal += (int) ($item['unit_price'] ?? 0) * (int) ($item['quantity'] ?? 0);
            }

            $bagFee = (int) ($data['bag_fee'] ?? 0);
            $voucherCode = $data['voucher_code'] ?? null;
            $discount = 0;

            if (is_string($voucherCode) && trim($voucherCode) !== '') {
                $discount = $this->vouchers->resolve($user, $voucherCode, $subtotal)['discount'];
            }

            $membership = $this->members->membershipFor($user);
            $pointsUsed = max(0, (int) ($data['points_used'] ?? 0));
            $pointsUsed = min($pointsUsed, $membership->points);
            $pointsUsed = min($pointsUsed, max(0, $subtotal + $bagFee - $discount));

            $total = max(0, $subtotal + $bagFee - $discount - $pointsUsed);

            $nextId = ((int) Order::max('id')) + 1;
            $code = '#'.(1000 + $nextId);

            $methodId = $data['payment_method_id'] ?? 'qris';
            $methodName = PaymentMethod::find($methodId)?->name ?? 'QRIS';

            $order = Order::create([
                'code' => $code,
                'user_id' => $user->id,
                'outlet_id' => $data['outlet_id'] ?? null,
                'subtotal' => $subtotal,
                'bag_fee' => $bagFee,
                'voucher_discount' => $discount,
                'points_used' => $pointsUsed,
                'total' => $total,
                'payment_method_id' => $methodId,
                'payment_method' => $methodName,
                'fulfilment' => $data['fulfilment'] ?? 'Pickup',
                'status' => 'Pending',
                'scheduled_at' => $data['scheduled_at'] ?? null,
            ]);

            foreach ($items as $item) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $item['product_id'] ?? null,
                    'name' => $item['name'],
                    'image_path' => $item['image'] ?? '',
                    'base_price' => (int) ($item['base_price'] ?? 0),
                    'unit_price' => (int) ($item['unit_price'] ?? 0),
                    'quantity' => (int) ($item['quantity'] ?? 1),
                    'size' => $item['size'] ?? 'Regular',
                    'milk' => $item['milk'] ?? 'Milk',
                    'sugar' => $item['sugar'] ?? 'Normal Sugar',
                    'ice' => $item['ice'] ?? 'Normal Ice',
                    'toppings' => $item['toppings'] ?? [],
                    'syrups' => $item['syrups'] ?? [],
                    'note' => $item['note'] ?? '',
                ]);
            }

            if ($pointsUsed > 0) {
                $this->members->redeemPoints($user, $pointsUsed, "Redeem poin pesanan {$code}", $order->id);
            }

            if (is_string($voucherCode) && trim($voucherCode) !== '') {
                $this->vouchers->markUsed($user, $voucherCode, $order->id);
            }

            $this->members->registerSpend($user, $total, $code, $order->id);

            return $order->load('items');
        });
    }

    /** Memajukan status satu langkah: Pending → Processing → Ready → Completed. */
    public function advance(Order $order): Order
    {
        if ($order->isFinal()) {
            return $order;
        }

        $index = array_search($order->status, Order::STATUS_FLOW, true);

        if ($index === false || $index >= count(Order::STATUS_FLOW) - 1) {
            return $order;
        }

        $order->status = Order::STATUS_FLOW[$index + 1];
        $order->save();

        return $order;
    }

    /** Membatalkan pesanan selama statusnya belum final. */
    public function cancel(Order $order): Order
    {
        if ($order->isFinal()) {
            throw new \RuntimeException('Pesanan yang sudah selesai tidak bisa dibatalkan.');
        }

        $order->status = 'Cancelled';
        $order->save();

        return $order;
    }
}

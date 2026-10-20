<?php

namespace Database\Seeders;

use App\Models\Membership;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\User;
use App\Models\UserSetting;
use Illuminate\Database\Seeder;

/**
 * Data pengguna contoh.
 *
 * Data katalog (outlet, kategori, produk, voucher, dll.) sudah terisi lewat
 * file `docs/database/kopi_kangenan.sql` di aplikasi Flutter. Seeder ini
 * melengkapi data yang butuh hash password, yaitu akun demo dan pesanan #1001
 * — sama seperti `AuthService` + `OrderStore._seedOnce` di aplikasi.
 */
class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $demo = User::firstOrCreate(
            ['identifier' => 'demo@kangenan.com'],
            [
                'name' => 'Pengguna Demo',
                'identifier_type' => 'email',
                'password' => '123456',
                'provider' => 'local',
            ],
        );

        User::firstOrCreate(
            ['identifier' => 'pengguna.google@gmail.com'],
            [
                'name' => 'Pengguna Google',
                'identifier_type' => 'email',
                'password' => '123456',
                'provider' => 'google',
            ],
        );

        UserSetting::firstOrCreate(['user_id' => $demo->id], [
            'language' => 'indonesia',
            'notif_promo' => true,
            'notif_pesanan' => true,
            'biometric' => false,
        ]);

        Membership::firstOrCreate(['user_id' => $demo->id], [
            'points' => 0,
            'total_spent' => 0,
        ]);

        if (! Order::where('code', '#1001')->exists()) {
            $order = Order::create([
                'code' => '#1001',
                'user_id' => $demo->id,
                'outlet_id' => 1,
                'subtotal' => 28000,
                'bag_fee' => 0,
                'voucher_discount' => 0,
                'points_used' => 0,
                'total' => 28000,
                'payment_method_id' => 'qris',
                'payment_method' => 'QRIS',
                'fulfilment' => 'Pickup',
                'status' => 'Completed',
                'created_at' => now()->subDays(3),
            ]);

            OrderItem::create([
                'order_id' => $order->id,
                'product_id' => 6,
                'name' => 'Taro Cloud Latte',
                'image_path' => 'assets/taro cloud latte.png',
                'base_price' => 28000,
                'unit_price' => 28000,
                'quantity' => 1,
                'size' => 'Regular',
                'milk' => 'Milk',
                'sugar' => 'Normal Sugar',
                'ice' => 'Normal Ice',
                'toppings' => [],
                'syrups' => [],
                'note' => '',
            ]);
        }
    }
}

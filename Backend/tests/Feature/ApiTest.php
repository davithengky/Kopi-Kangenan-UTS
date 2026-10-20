<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

/**
 * Uji endpoint REST API Kopi Kangenan.
 *
 * Memakai `DatabaseTransactions` (bukan RefreshDatabase) karena skema database
 * dibuat oleh `docs/database/kopi_kangenan.sql`, bukan oleh migration Laravel.
 */
class ApiTest extends TestCase
{
    use DatabaseTransactions;

    // --- Pembantu ---------------------------------------------------------

    private function loginDemo(): string
    {
        $response = $this->postJson('/api/auth/login', [
            'identifier' => 'demo@kangenan.com',
            'password' => '123456',
        ]);

        $response->assertOk();

        return $response->json('data.token');
    }

    private function auth(): array
    {
        return ['Authorization' => 'Bearer '.$this->loginDemo()];
    }

    /**
     * Melupakan guard yang sudah ter-cache di container.
     *
     * Laravel menyimpan instance guard selama satu tes, sehingga berpindah
     * token/pengguna di tengah tes perlu ini agar otentikasi dibaca ulang.
     */
    private function forgetAuth(): void
    {
        $this->app['auth']->forgetGuards();
    }

    /** Satu item contoh untuk keranjang / checkout. */
    private function sampleItem(): array
    {
        return [
            'product_id' => 6,
            'name' => 'Taro Cloud Latte',
            'image' => 'assets/taro cloud latte.png',
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
        ];
    }

    // --- Auth -------------------------------------------------------------

    public function test_login_demo_berhasil(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'identifier' => 'demo@kangenan.com',
            'password' => '123456',
        ]);

        $response->assertOk()
            ->assertJsonPath('data.user.name', 'Pengguna Demo')
            ->assertJsonPath('data.membership.level.label', 'Silver');

        $this->assertNotEmpty($response->json('data.token'));
    }

    public function test_login_password_salah_ditolak(): void
    {
        $this->postJson('/api/auth/login', [
            'identifier' => 'demo@kangenan.com',
            'password' => 'salah',
        ])->assertStatus(422);
    }

    public function test_register_membuat_data_awal(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Pembeli Baru',
            'identifier' => 'baru@kangenan.com',
            'password' => 'rahasia123',
            'password_confirmation' => 'rahasia123',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.user.identifier_type', 'email')
            ->assertJsonPath('data.settings.notif_promo', true);

        $user = User::where('identifier', 'baru@kangenan.com')->firstOrFail();

        $this->assertDatabaseHas('memberships', ['user_id' => $user->id, 'points' => 0]);
        $this->assertDatabaseHas('carts', ['user_id' => $user->id]);
        $this->assertSame(3, $user->inboxMessages()->count());
    }

    public function test_endpoint_terlindungi_butuh_token(): void
    {
        $this->getJson('/api/membership')->assertStatus(401);
    }

    public function test_login_google_membuat_akun_bila_belum_ada(): void
    {
        $response = $this->postJson('/api/auth/login/google', [
            'identifier' => 'baru.google@gmail.com',
            'name' => 'Pembeli Google',
        ]);

        $response->assertOk()
            ->assertJsonPath('data.user.provider', 'google');
    }

    public function test_me_mengembalikan_profil(): void
    {
        $this->getJson('/api/auth/me', $this->auth())
            ->assertOk()
            ->assertJsonPath('data.user.identifier', 'demo@kangenan.com');
    }

    public function test_logout_menghapus_token(): void
    {
        $headers = $this->auth();
        $this->postJson('/api/auth/logout', [], $headers)->assertOk();
        $this->forgetAuth();
        $this->getJson('/api/membership', $headers)->assertStatus(401);
    }

    // --- Katalog ----------------------------------------------------------

    public function test_outlets_dan_kategori_tersedia(): void
    {
        $this->getJson('/api/outlets')
            ->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonPath('data.0.name', 'Tunjungan Plaza 3')
            ->assertJsonPath('data.0.is_default', true);

        $this->getJson('/api/categories')
            ->assertOk()
            ->assertJsonCount(5, 'data');
    }

    public function test_produk_menu_berjumlah_10_dan_bisa_difilter(): void
    {
        $this->getJson('/api/products')
            ->assertOk()
            ->assertJsonCount(10, 'data');

        $makanan = $this->getJson('/api/products?category=makanan');
        $makanan->assertOk()->assertJsonCount(3, 'data');

        // Satu produk boleh ada di dua kategori sekaligus.
        $coffee = $this->getJson('/api/products?category=coffee');
        $coffee->assertOk()->assertJsonCount(1, 'data');
        $this->assertSame('Taro Cloud Latte', $coffee->json('data.0.name'));
    }

    public function test_merch_berjumlah_10(): void
    {
        $this->getJson('/api/merch')->assertOk()->assertJsonCount(10, 'data');
    }

    public function test_detail_produk_memuat_opsi(): void
    {
        $response = $this->getJson('/api/products/6');

        $response->assertOk()
            ->assertJsonPath('data.name', 'Taro Cloud Latte');

        $this->assertCount(7, $response->json('data.option_groups'));
    }

    public function test_halaman_statis(): void
    {
        $this->getJson('/api/static-pages/help')
            ->assertOk()
            ->assertJsonPath('data.title', 'Bantuan')
            ->assertJsonCount(3, 'data.sections');
    }

    // --- Keranjang --------------------------------------------------------

    public function test_keranjang_kosong_saat_awal(): void
    {
        $this->getJson('/api/cart', $this->auth())
            ->assertOk()
            ->assertJsonCount(0, 'data.items')
            ->assertJsonPath('data.total_price', 0);
    }

    public function test_tambah_ubah_dan_hapus_item_keranjang(): void
    {
        $headers = $this->auth();

        $created = $this->postJson('/api/cart/items', $this->sampleItem(), $headers);
        $created->assertStatus(201);
        $itemId = $created->json('data.id');

        $this->getJson('/api/cart', $headers)
            ->assertJsonPath('data.total_price', 28000)
            ->assertJsonPath('data.total_quantity', 1);

        $this->putJson("/api/cart/items/{$itemId}", ['quantity' => 3], $headers)
            ->assertOk()
            ->assertJsonPath('data.total_price', 84000);

        // Jumlah 0 menghapus item (perilaku CartStore.updateQuantity).
        $this->putJson("/api/cart/items/{$itemId}", ['quantity' => 0], $headers)->assertOk();
        $this->getJson('/api/cart', $headers)->assertJsonCount(0, 'data.items');
    }

    public function test_keranjang_pengguna_lain_tidak_bisa_diakses(): void
    {
        $headers = $this->auth();
        $itemId = $this->postJson('/api/cart/items', $this->sampleItem(), $headers)->json('data.id');

        $other = User::where('identifier', 'pengguna.google@gmail.com')->firstOrFail();
        $token = $other->createToken('test')->plainTextToken;

        $this->forgetAuth();

        $this->putJson("/api/cart/items/{$itemId}", ['quantity' => 2], [
            'Authorization' => 'Bearer '.$token,
        ])->assertStatus(404);
    }

    // --- Alamat -----------------------------------------------------------

    public function test_alamat_tersedia_dan_bisa_ditambah(): void
    {
        $headers = $this->auth();

        $this->getJson('/api/addresses', $headers)
            ->assertOk()
            ->assertJsonPath('data.0.label', 'Rumah')
            ->assertJsonPath('data.0.is_default', true);

        $created = $this->postJson('/api/addresses', [
            'label' => 'Kantor',
            'recipient' => 'Jibi',
            'phone' => '0812-0000-1111',
            'detail' => 'Jl. Darmo No. 1, Surabaya',
            'is_default' => true,
        ], $headers);

        $created->assertStatus(201)->assertJsonPath('data.is_default', true);

        // Alamat lama tidak lagi jadi default.
        $this->getJson('/api/addresses', $headers)
            ->assertJsonPath('data.0.label', 'Kantor');
    }

    // --- Voucher ----------------------------------------------------------

    public function test_validasi_kode_voucher_katalog(): void
    {
        $response = $this->postJson('/api/vouchers/validate', [
            'code' => 'kangenan10',
            'subtotal' => 40000,
        ], $this->auth());

        $response->assertOk()
            ->assertJsonPath('data.code', 'KANGENAN10')
            ->assertJsonPath('data.discount', 4000);

        // Voucher otomatis masuk ke akun pengguna.
        $this->getJson('/api/vouchers', $this->auth())
            ->assertJsonCount(1, 'data');
    }

    public function test_voucher_di_bawah_minimum_tidak_memberi_potongan(): void
    {
        $this->postJson('/api/vouchers/validate', [
            'code' => 'KANGENAN10',
            'subtotal' => 10000,
        ], $this->auth())
            ->assertOk()
            ->assertJsonPath('data.discount', 0)
            ->assertJsonPath('data.is_applicable', false);
    }

    public function test_kode_voucher_tidak_dikenal(): void
    {
        $this->postJson('/api/vouchers/validate', ['code' => 'NGACO'], $this->auth())
            ->assertStatus(422);
    }

    public function test_beli_paket_voucher_menambah_voucher_ke_akun(): void
    {
        $this->getJson('/api/voucher-packs')
            ->assertOk()
            ->assertJsonCount(2, 'data');

        $response = $this->postJson('/api/voucher-packs/pack-9000/buy', [], $this->auth());

        $response->assertOk()->assertJsonCount(3, 'data.vouchers');
        $this->getJson('/api/vouchers', $this->auth())->assertJsonCount(3, 'data');
    }

    public function test_klaim_promo(): void
    {
        $headers = $this->auth();

        $this->postJson('/api/promos/claim', ['label' => 'Buy 1 Get 1'], $headers)->assertOk();

        $this->getJson('/api/promos', $headers)
            ->assertOk()
            ->assertJsonPath('data.claimed.0', 'Buy 1 Get 1');
    }

    // --- Pesanan ----------------------------------------------------------

    public function test_riwayat_pesanan_contoh(): void
    {
        $this->getJson('/api/orders', $this->auth())
            ->assertOk()
            ->assertJsonPath('data.0.code', '#1001')
            ->assertJsonPath('data.0.status', 'Completed');
    }

    public function test_checkout_membuat_pesanan_dan_poin(): void
    {
        $headers = $this->auth();

        $response = $this->postJson('/api/orders', [
            'items' => [$this->sampleItem()],
            'outlet_id' => 1,
            'payment_method_id' => 'qris',
            'fulfilment' => 'Pickup',
        ], $headers);

        $response->assertStatus(201)
            ->assertJsonPath('data.code', '#1002')
            ->assertJsonPath('data.status', 'Pending')
            ->assertJsonPath('data.total', 28000)
            ->assertJsonPath('data.payment_method', 'QRIS');

        // 1 poin per Rp1.000 belanja.
        $this->getJson('/api/membership', $headers)
            ->assertJsonPath('data.points', 28)
            ->assertJsonPath('data.total_spent', 28000);
    }

    public function test_checkout_dengan_voucher_dan_poin(): void
    {
        $headers = $this->auth();

        // Kumpulkan poin dulu lewat pesanan pertama.
        $this->postJson('/api/orders', [
            'items' => [$this->sampleItem()],
        ], $headers)->assertStatus(201);

        $response = $this->postJson('/api/orders', [
            'items' => [array_merge($this->sampleItem(), ['quantity' => 2])],
            'voucher_code' => 'KANGENAN10',
            'points_used' => 10,
        ], $headers);

        // 56.000 + 0 - 5.600 (10%) - 10 (poin) = 50.390
        $response->assertStatus(201)
            ->assertJsonPath('data.voucher_discount', 5600)
            ->assertJsonPath('data.points_used', 10)
            ->assertJsonPath('data.total', 50390);
    }

    public function test_poin_yang_dipakai_tidak_melebihi_saldo(): void
    {
        $response = $this->postJson('/api/orders', [
            'items' => [$this->sampleItem()],
            'points_used' => 999999,
        ], $this->auth());

        $response->assertStatus(201)->assertJsonPath('data.points_used', 0);
    }

    public function test_status_pesanan_berjalan_maju(): void
    {
        $headers = $this->auth();

        $orderId = $this->postJson('/api/orders', [
            'items' => [$this->sampleItem()],
        ], $headers)->json('data.id');

        $this->putJson("/api/orders/{$orderId}/advance", [], $headers)
            ->assertOk()
            ->assertJsonPath('data.status', 'Processing');

        $this->putJson("/api/orders/{$orderId}/advance", [], $headers)
            ->assertJsonPath('data.status', 'Ready');
    }

    public function test_pesanan_bisa_dibatalkan(): void
    {
        $headers = $this->auth();

        $orderId = $this->postJson('/api/orders', [
            'items' => [$this->sampleItem()],
        ], $headers)->json('data.id');

        $this->putJson("/api/orders/{$orderId}/cancel", [], $headers)
            ->assertOk()
            ->assertJsonPath('data.status', 'Cancelled');
    }

    public function test_pesanan_selesai_tidak_bisa_dibatalkan(): void
    {
        $headers = $this->auth();

        // Pesanan contoh #1001 statusnya Completed.
        $orderId = $this->getJson('/api/orders', $headers)->json('data.0.id');

        $this->putJson("/api/orders/{$orderId}/cancel", [], $headers)->assertStatus(422);
    }

    public function test_checkout_keranjang_kosong_ditolak(): void
    {
        $this->postJson('/api/orders', ['items' => []], $this->auth())->assertStatus(422);
    }

    // --- Membership -------------------------------------------------------

    public function test_level_naik_sesuai_total_belanja(): void
    {
        $user = User::where('identifier', 'demo@kangenan.com')->firstOrFail();

        $user->membership()->update(['total_spent' => 700000]);

        $this->getJson('/api/membership', [
            'Authorization' => 'Bearer '.$user->createToken('t')->plainTextToken,
        ])
            ->assertOk()
            ->assertJsonPath('data.level.label', 'Gold')
            ->assertJsonPath('data.remaining_to_next_level', 9299999);
    }

    public function test_hadiah_check_in_berjumlah_enam(): void
    {
        $this->getJson('/api/checkin/rewards')
            ->assertOk()
            ->assertJsonCount(6, 'data');
    }

    public function test_check_in_hari_pertama_memberi_25_poin(): void
    {
        $headers = $this->auth();

        $this->getJson('/api/checkin', $headers)
            ->assertOk()
            ->assertJsonPath('data.can_check_in', true)
            ->assertJsonCount(0, 'data.checked_days');

        $this->postJson('/api/checkin', [], $headers)
            ->assertOk()
            ->assertJsonPath('data.day', 1)
            ->assertJsonPath('data.reward', '+25 poin')
            ->assertJsonPath('data.points', 25);

        $this->getJson('/api/membership', $headers)->assertJsonPath('data.points', 25);
    }

    public function test_riwayat_poin_tercatat(): void
    {
        $headers = $this->auth();
        $this->postJson('/api/checkin', [], $headers)->assertOk();

        $this->getJson('/api/points/history', $headers)
            ->assertOk()
            ->assertJsonPath('data.0.title', 'Daily Check-In hari ke-1')
            ->assertJsonPath('data.0.delta', 25);
    }

    // --- Pembayaran, Kotak Masuk, Pengaturan, Pesanan Besar ---------------

    public function test_metode_pembayaran_dan_pilih(): void
    {
        $headers = $this->auth();

        $this->getJson('/api/payment-methods', $headers)
            ->assertOk()
            ->assertJsonCount(4, 'data')
            ->assertJsonPath('data.0.id', 'qris')
            ->assertJsonPath('data.0.is_selected', true);

        $this->putJson('/api/payment-methods/select', ['payment_method_id' => 'blu'], $headers)
            ->assertOk()
            ->assertJsonPath('data.is_selected', true);
    }

    public function test_gopay_harus_dihubungkan_dulu(): void
    {
        $headers = $this->auth();

        $this->postJson('/api/payment-methods/gopay/connect', [], $headers)
            ->assertOk()
            ->assertJsonPath('data.is_connected', true);

        $this->putJson('/api/payment-methods/select', ['payment_method_id' => 'gopay'], $headers)
            ->assertOk()
            ->assertJsonPath('data.is_selected', true);
    }

    public function test_kotak_masuk_berisi_tiga_pesan(): void
    {
        $headers = $this->auth();

        $this->getJson('/api/inbox', $headers)
            ->assertOk()
            ->assertJsonCount(3, 'data.messages')
            ->assertJsonPath('data.unread_count', 2);

        $this->putJson('/api/inbox/read-all', [], $headers)->assertOk();

        $this->getJson('/api/inbox', $headers)->assertJsonPath('data.unread_count', 0);
    }

    public function test_pengaturan_bisa_diubah(): void
    {
        $headers = $this->auth();

        $this->putJson('/api/settings', [
            'language' => 'english',
            'notif_promo' => false,
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.language', 'english')
            ->assertJsonPath('data.notif_promo', false);
    }

    public function test_profil_bisa_diubah(): void
    {
        $headers = $this->auth();

        $this->putJson('/api/profile', [
            'name' => 'Jibi Kangenan',
            'identifier' => 'demo@kangenan.com',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.user.name', 'Jibi Kangenan');
    }

    public function test_ganti_password(): void
    {
        $headers = $this->auth();

        $this->putJson('/api/profile/password', [
            'current_password' => '123456',
            'password' => 'passwordbaru',
            'password_confirmation' => 'passwordbaru',
        ], $headers)->assertOk();

        $this->postJson('/api/auth/login', [
            'identifier' => 'demo@kangenan.com',
            'password' => 'passwordbaru',
        ])->assertOk();
    }

    public function test_pesanan_besar_bisa_dikirim(): void
    {
        $response = $this->postJson('/api/bulk-orders', [
            'name' => 'Panitia Kampus',
            'contact' => '0812-3456-7890',
            'purpose' => 'Acara kampus',
            'estimated_cups' => 50,
            'event_date' => '2026-10-24',
        ]);

        $response->assertStatus(201)->assertJsonPath('data.estimated_cups', 50);
    }
}

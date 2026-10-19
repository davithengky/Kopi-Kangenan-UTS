# Database Kopi Kangenan

Folder ini berisi skema database untuk REST API `kopi-kangenan-api` (Laravel).
Skemanya diturunkan **1:1 dari model Dart** aplikasi Flutter (`lib/models/`) dan
logika store (`lib/providers/`), sehingga pemetaan API ⇄ aplikasi mudah.

| File | Isi |
|---|---|
| `kopi_kangenan.sql` | **Sumber kebenaran** struktur database: 29 tabel + seed data |

Dokumentasi REST API yang memakai skema ini ada di `../api.md`, dan koleksi
siap impor di `../postman/kopi_kangenan.postman_collection.json`.

## Cara import

```powershell
# Laragon: MySQL 8.4, user root tanpa password
D:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe -u root < kopi_kangenan.sql
```

Script bersifat **idempoten**: menjalankan ulang akan menghapus lalu membuat
ulang semua tabel beserta seed-nya (aman untuk reset).

Verifikasi cepat:

```powershell
D:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe -u root -t `
  -e "USE kopi_kangenan; SELECT COUNT(*) AS tabel FROM information_schema.tables WHERE table_schema='kopi_kangenan';"
# → 29
```

## Daftar 29 tabel

| # | Grup | Tabel |
|---|---|---|
| 1 | Akun & profil | `users`, `user_settings`, `addresses` |
| 2 | Membership & poin | `memberships`, `point_entries`, `checkin_rewards`, `daily_checkins` |
| 3 | Katalog | `outlets`, `categories`, `products`, `product_categories`, `static_pages` |
| 4 | Pembayaran | `payment_methods`, `user_payment_methods` |
| 5 | Voucher & promo | `vouchers`, `voucher_packs`, `pack_vouchers`, `user_vouchers`, `promo_claims` |
| 6 | Keranjang | `carts`, `cart_items` |
| 7 | Pesanan | `orders`, `order_items` |
| 8 | Komunikasi | `inbox_messages`, `bulk_order_requests` |
| 9 | Auth token | `personal_access_tokens` (Sanctum) |
| 10 | Opsi produk *(opsional)* | `option_groups`, `options`, `product_option_group` |

## Peta model Dart → tabel

| Model / store Dart | Tabel |
|---|---|
| `AuthUser`, `AuthService._Account` | `users` |
| `SettingsStore` | `user_settings` |
| `Address` / `AddressStore` | `addresses` |
| `Outlet` / `kOutlets` / `OutletStore` | `outlets` |
| `Product.category` / `MenuScreen.categories` | `categories`, `product_categories` |
| `Product` / `kProductCatalog` | `products` (`type = 'menu'`) |
| `MerchProduct` / `kMerchCatalog` | `products` (`type = 'merch'`) |
| Opsi di `product_detail_screen.dart` | `option_groups`, `options`, `product_option_group` |
| `PaymentMethod` / `kPaymentMethods` / `PaymentStore` | `payment_methods`, `user_payment_methods` |
| `Voucher` / `VoucherStore.catalog` | `vouchers` |
| `VoucherPack` / `kVoucherPacks` | `voucher_packs`, `pack_vouchers` |
| `VoucherStore.userVouchers` | `user_vouchers` |
| `VoucherStore.claimedPromos` | `promo_claims` |
| `MemberStore.points` / `totalSpent` | `memberships` |
| `PointEntry` / `MemberStore.history` | `point_entries` |
| `MemberStore.dailyRewards` | `checkin_rewards` |
| `MemberStore.checkedDays` | `daily_checkins` |
| `CartItem` / `CartStore` | `carts`, `cart_items` |
| `Order` / `OrderStore` | `orders`, `order_items` |
| `InboxMessage` / `InboxStore` | `inbox_messages` |
| form `bulk_order_screen.dart` | `bulk_order_requests` |
| `StaticPageScreen` | `static_pages` |
| `MemberLevel` (Silver/Gold/Black) | *tidak disimpan* — dihitung dari `memberships.total_spent` |

## Keputusan desain penting

1. **Uang = integer rupiah**, tanpa desimal, sama seperti model Dart.
2. **Level membership dihitung**, bukan disimpan:
   `total_spent` < 700.000 → Silver, ≥ 700.000 → Gold, ≥ 9.999.999 → Black.
3. **Poin**: 1 poin = Rp1 saat dipakai; dapat `total ÷ 1000` poin per pesanan.
4. **Snapshot**: `cart_items` dan `order_items` menyimpan nama + harga apa adanya
   karena `CartItem` di Flutter tidak menyimpan `product_id`.
5. **`toppings` / `syrups` = kolom JSON** karena di Dart hanya `List<String>`
   (harga tambahan sudah masuk ke `unit_price`).
6. **Pivot kategori**: satu produk boleh ada di banyak kategori
   (mis. "Taro Cloud Latte" ada di `Baru!` **dan** `Coffee`) → `product_categories`.
7. **Identifier login** bisa email atau nomor HP → satu kolom `users.identifier`
   (unik) + `identifier_type`.
8. **Kode pesanan** berformat `#1001`; urutan berikutnya mulai `#1002`.
9. Tabel bawaan Laravel (`cache`, `jobs`, `sessions`, `password_reset_tokens`)
   **tidak dibuat** karena tidak dipakai. Karena itu jangan menjalankan
   `php artisan migrate` — struktur database dikelola oleh file SQL ini.
   (Kalau tetap dijalankan, Laravel hanya akan menambah tabel `migrations`.)

## Data yang sudah terisi (seed)

| Data | Jumlah |
|---|---|
| Outlet | 3 (default: Tunjungan Plaza 3) |
| Kategori | 5 |
| Produk + Merch | 20 (10 menu + 10 merch) |
| Relasi produk–kategori | 14 |
| Opsi kustomisasi | 7 grup, 27 opsi |
| Metode pembayaran | 4 (default: QRIS) |
| Voucher | 9 (3 katalog + 6 template paket) |
| Paket voucher | 2 (Rp9.000 & Rp24.000) |
| Hadiah check-in | 6 hari |
| Halaman statis | 6 |
| Pesan kotak masuk | 3 |
| Pengguna | 2 |
| Pesanan contoh | 1 (`#1001`, Completed) |

### Akun demo

| Identifier | Password | Provider |
|---|---|---|
| `demo@kangenan.com` | `123456` | `local` |
| `pengguna.google@gmail.com` | `123456` | `google` |

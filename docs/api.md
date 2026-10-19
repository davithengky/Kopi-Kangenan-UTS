# REST API Kopi Kangenan

API ini melayani aplikasi Flutter `kopken_clone`. Dibuat dengan **Laravel
13.37** + **Laravel Sanctum** (Bearer token), database MySQL
`kopi_kangenan` (lihat `docs/database/README.md`).

- **Lokasi proyek** — `D:\laragon\www\kopi-kangenan-api`
- **Alamat dasar** — `http://127.0.0.1:8000/api`
- **CORS** — aktif untuk `api/*` (bawaan Laravel, `Access-Control-Allow-Origin: *`)

## Menjalankan

```powershell
# 1. Pastikan MySQL Laragon menyala, lalu impor skemanya (sekali saja)
D:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe -u root < docs\database\kopi_kangenan.sql

# 2. Jalankan server API
cd D:\laragon\www\kopi-kangenan-api
D:\laragon\bin\php\php-8.3.33-Win32-vs16-x64\php.exe artisan serve --host=127.0.0.1 --port=8000

# 3. Uji cepat
curl http://127.0.0.1:8000/api/outlets
```

Pengaturan database ada di `D:\laragon\www\kopi-kangenan-api\.env`
(`DB_DATABASE=kopi_kangenan`, `DB_USERNAME=root`, password kosong).

> **Penting:** struktur database dikelola oleh `docs/database/kopi_kangenan.sql`,
> **bukan** oleh migration Laravel. Jangan menjalankan `php artisan migrate`.

## Akun demo

| Identifier | Password | Provider |
|---|---|---|
| `demo@kangenan.com` | `123456` | `local` |
| `pengguna.google@gmail.com` | `123456` | `google` |

---

## Format respons

Semua respons JSON memakai pola yang sama:

```json
{ "message": "Pesan untuk pengguna.", "data": { } }
```

Kesalahan validasi memakai format bawaan Laravel:

```json
{ "message": "The given data was invalid.", "errors": { "identifier": ["..."] } }
```

Kode status: `200` sukses, `201` dibuat, `401` belum login, `404` bukan milik
pengguna, `422` gagal validasi / aturan bisnis.

---

## Endpoint

### Autentikasi

| Method | Path | Login? | Keterangan |
|---|---|---|---|
| POST | `/api/auth/register` | – | `name`, `identifier`, `password`, `password_confirmation` |
| POST | `/api/auth/login` | – | `identifier`, `password` |
| POST | `/api/auth/login/google` | – | `identifier`, `name` — akun dibuat otomatis bila belum ada |
| GET | `/api/auth/me` | ✔ | Pengguna + membership + pengaturan |
| POST | `/api/auth/logout` | ✔ | Menghapus token yang sedang dipakai |
| POST | `/api/auth/logout-all` | ✔ | Menghapus semua token pengguna |

Semua permintaan yang butuh login mengirim header:

```
Authorization: Bearer <token>
Accept: application/json
```

### Profil

| Method | Path | Keterangan |
|---|---|---|
| GET | `/api/profile` | Pengguna + pengaturan + membership |
| PUT | `/api/profile` | `name`, `identifier` |
| PUT | `/api/profile/password` | `current_password`, `password`, `password_confirmation` |

### Alamat

| Method | Path | Keterangan |
|---|---|---|
| GET | `/api/addresses` | Daftar alamat (utama lebih dulu) |
| POST | `/api/addresses` | `label`, `recipient`, `phone`, `detail`, `note`, `is_default` |
| PUT | `/api/addresses/{id}` | Ubah alamat |
| DELETE | `/api/addresses/{id}` | Hapus alamat |
| PUT | `/api/addresses/{id}/default` | Jadikan alamat utama |

### Katalog (publik)

| Method | Path | Keterangan |
|---|---|---|
| GET | `/api/outlets` | Outlet aktif |
| GET | `/api/categories` | Kategori menu |
| GET | `/api/products` | Produk menu. Filter: `?category=<slug\|nama>`, `?type=menu\|merch\|all`, `?new=1` |
| GET | `/api/products/{id}` | Detail produk + `option_groups` |
| GET | `/api/merch` | Katalog merchandise |
| GET | `/api/static-pages/{slug}` | Halaman statis (`help`, `privacy`, `terms`, `report`, `whatsapp`, `about`) |

### Metode pembayaran

| Method | Path | Login? | Keterangan |
|---|---|---|---|
| GET | `/api/payment-methods` | ✔ | Daftar + `is_connected` / `is_selected` pengguna |
| PUT | `/api/payment-methods/select` | ✔ | `payment_method_id` |
| POST | `/api/payment-methods/{id}/connect` | ✔ | Hubungkan (mis. GoPay) |

### Voucher & promo

| Method | Path | Login? | Keterangan |
|---|---|---|---|
| GET | `/api/vouchers` | ✔ | Voucher milik pengguna |
| GET | `/api/vouchers/catalog` | – | 3 voucher contoh (`KANGENAN10`, `GRATISKOPI`, `ONGKIRHEMAT`) |
| POST | `/api/vouchers/validate` | ✔ | `code`, `subtotal` → potongan. Voucher katalog otomatis masuk ke akun |
| GET | `/api/voucher-packs` | – | Daftar paket voucher |
| POST | `/api/voucher-packs/{id}/buy` | ✔ | Membeli paket; vouchernya langsung masuk akun |
| GET | `/api/promos` | ✔ | Label promo yang sudah diklaim |
| POST | `/api/promos/claim` | ✔ | `label` |

### Keranjang

| Method | Path | Keterangan |
|---|---|---|
| GET | `/api/cart` | Isi keranjang + `total_price`, `total_quantity` |
| POST | `/api/cart/items` | Tambah item (selalu jadi baris baru, sama seperti `CartStore.add`) |
| PUT | `/api/cart/items/{id}` | `quantity` — nilai `0` menghapus item |
| DELETE | `/api/cart/items/{id}` | Hapus item |
| DELETE | `/api/cart` | Kosongkan keranjang |

### Pesanan

| Method | Path | Keterangan |
|---|---|---|
| GET | `/api/orders` | Riwayat pesanan, terbaru dulu |
| POST | `/api/orders` | Membuat pesanan (lihat di bawah) |
| GET | `/api/orders/{id}` | Detail pesanan |
| PUT | `/api/orders/{id}/advance` | Pending → Processing → Ready → Completed |
| PUT | `/api/orders/{id}/cancel` | Batalkan (ditolak kalau sudah final) |

`POST /api/orders` menerima:

```json
{
  "items": [
    {
      "name": "Taro Cloud Latte",
      "image": "assets/taro cloud latte.png",
      "base_price": 28000,
      "unit_price": 28000,
      "quantity": 1,
      "size": "Regular",
      "milk": "Milk",
      "sugar": "Normal Sugar",
      "ice": "Normal Ice",
      "toppings": [],
      "syrups": [],
      "note": ""
    }
  ],
  "outlet_id": 1,
  "bag_fee": 0,
  "voucher_code": "KANGENAN10",
  "points_used": 10,
  "payment_method_id": "qris",
  "fulfilment": "Pickup",
  "scheduled_at": null
}
```

Perhitungan `total` di server sama seperti `OrderStore.create` di Flutter:

```
total = subtotal + bag_fee - voucher_discount - points_used   (tidak negatif)
```

Setelah pesanan dibuat, server juga: memotong poin, menandai voucher terpakai,
mencatat `total_spent`, dan memberi poin `total ÷ 1000`.

### Membership & poin

| Method | Path | Login? | Keterangan |
|---|---|---|---|
| GET | `/api/membership` | ✔ | Poin, `total_spent`, level, progres, sisa menuju level berikutnya |
| GET | `/api/points/history` | ✔ | Riwayat poin |
| GET | `/api/checkin/rewards` | – | Hadiah 6 hari |
| GET | `/api/checkin` | ✔ | Hari yang sudah check-in bulan ini + `can_check_in` |
| POST | `/api/checkin` | ✔ | Melakukan check-in hari ini |

Level **dihitung**, bukan disimpan: `< 700.000` → Silver, `≥ 700.000` → Gold,
`≥ 9.999.999` → Black.

### Kotak masuk & pesanan besar

| Method | Path | Login? | Keterangan |
|---|---|---|---|
| GET | `/api/inbox` | ✔ | `messages` + `unread_count` |
| PUT | `/api/inbox/{id}/read` | ✔ | Tandai satu pesan sudah dibaca |
| PUT | `/api/inbox/read-all` | ✔ | Tandai semua sudah dibaca |
| POST | `/api/bulk-orders` | – | `name`, `contact`, `purpose`, `estimated_cups`, `event_date`, `note` |
| GET | `/api/bulk-orders` | ✔ | Permintaan milik pengguna |

### Pengaturan

| Method | Path | Keterangan |
|---|---|---|
| GET | `/api/settings` | Bahasa, notifikasi, biometrik |
| PUT | `/api/settings` | Sebagian atau seluruh field |

---

## Cara aplikasi Flutter memakainya

Integrasinya **offline-first**: nilai awal setiap store sudah benar (data bawaan
di `lib/models/`), lalu disegarkan dari API.

| Berkas | Peran |
|---|---|
| `lib/config/api.dart` | Alamat dasar (`API_BASE_URL`), status aktif, token Sanctum |
| `lib/services/api_client.dart` | Pembungkus HTTP + `ApiException` berbahasa Indonesia |
| `lib/services/sync_service.dart` | Tarik data dari API & kirim perubahan ke API |
| `lib/providers/catalog_store.dart` | Katalog yang bisa diperbarui dari API |
| `lib/providers/auth_store.dart` | `signIn`/`signUp`/`saveProfile`/… memakai API; `login`/`register`/… tetap lokal |

Alur:

1. **Splash** (`splash_screen.dart`) menjalankan `SyncService.bootstrap()`
   sambil menunggu 3 detik → katalog menu, merch, dan outlet diambil dari API.
2. **Login/Daftar** memakai endpoint `/auth/*`; token disimpan di memori
   (`ApiConfig.token`).
3. Setelah login, `SyncService.refreshUserData()` menarik membership, poin,
   riwayat pesanan, voucher, alamat, kotak masuk, pengaturan, dan metode
   pembayaran.
4. **Checkout** mengirim pesanan ke `POST /api/orders`. Kalau API mati atau
   pengguna belum masuk, pesanan dibuat lokal lewat `OrderStore.create`.
5. Perubahan lain (check-in, klaim promo, beli paket, alamat, kotak masuk,
   pengaturan, metode pembayaran) mengubah store lokal lebih dulu, lalu dikirim
   ke server tanpa menunggu (`SyncService.push...`).

### Mengubah alamat API

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
```

### Mematikan API sepenuhnya

```dart
ApiConfig.enabled = false;
```

Ini yang dilakukan pengujian widget di `test/` supaya tidak butuh jaringan.

---

## Pengujian

```powershell
cd D:\laragon\www\kopi-kangenan-api
D:\laragon\bin\php\php-8.3.33-Win32-vs16-x64\php.exe artisan test
```

42 pengujian fitur memakai `DatabaseTransactions` (bukan `RefreshDatabase`,
karena tidak ada migration) sehingga data di `kopi_kangenan` tidak berubah
setelah pengujian.

---

## Keputusan rancangan

1. **Token, bukan sesi** — Sanctum Personal Access Token; `SESSION_DRIVER=file`
   supaya tabel `sessions` tidak diperlukan.
2. **`items` dikirim dari klien** — `CartItem` di Flutter tidak menyimpan
   `product_id`, jadi keranjang tetap di sisi klien dan server menyimpan
   snapshot. Tabel `carts`/`cart_items` tetap tersedia bagi klien yang ingin
   sinkron penuh.
3. **Id pesanan di URL adalah angka**, sedangkan `code` (`#1001`) dipakai untuk
   tampilan. Klien memetakan `code` → id saat memanggil `advance`/`cancel`.
4. **Voucher katalog otomatis diklaim** saat divalidasi, sama seperti
   `VoucherStore.validateCode`.
5. **Cek harga & diskon tetap dihitung di server** saat membuat pesanan, jadi
   total yang tersimpan tidak bisa dipalsukan klien.

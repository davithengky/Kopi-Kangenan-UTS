# REST API Kopi Kangenan

Dokumentasi kontrak REST API backend **Kopi Kangenan** untuk aplikasi Flutter.

| Item | Nilai |
| --- | --- |
| Base URL (lokal) | `http://localhost:8000` |
| Prefix API | `/api` |
| Format | JSON (`Content-Type: application/json`, `Accept: application/json`) |
| Autentikasi | Laravel Sanctum, Bearer token |
| Mata uang | Rupiah, disimpan dan dikirim sebagai **integer** (contoh `28000`) |
| Penamaan field | `snake_case` |

## Daftar Isi

- [1. Gambaran Umum](#1-gambaran-umum)
- [2. Ringkasan Endpoint](#2-ringkasan-endpoint)
- [3. Alur Utama](#3-alur-utama)
- [4. Aturan Bisnis](#4-aturan-bisnis)
- [5. Format Error](#5-format-error)
- [6. Catatan Integrasi](#6-catatan-integrasi)

---

## 1. Gambaran Umum

### 1.1 Autentikasi

Endpoint yang ditandai **Token** membutuhkan header:

```http
Authorization: Bearer 1|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Accept: application/json
```

Token diperoleh dari `POST /api/auth/register`, `POST /api/auth/login`, atau
`POST /api/auth/login/google`. Token disimpan Sanctum di tabel
`personal_access_tokens` dan berlaku sampai dihapus lewat logout.

Bila token tidak ada atau tidak valid, API membalas `401`:

```json
{
  "message": "Unauthenticated."
}
```

### 1.2 Bentuk Respons

Respons sukses selalu memakai envelope `data`, dan menambahkan `message`
untuk aksi yang mengubah data:

```json
{
  "message": "Pesan berhasil dibuat.",
  "data": { }
}
```

Daftar selalu berupa array di dalam `data`:

```json
{
  "data": []
}
```

### 1.3 Kode Status

| Status | Arti |
| --- | --- |
| `200 OK` | Permintaan berhasil |
| `201 Created` | Data baru berhasil dibuat (registrasi, item keranjang, alamat, pesanan, pesanan besar) |
| `401 Unauthorized` | Token tidak ada, salah, atau sudah dihapus |
| `404 Not Found` | Resource tidak ada **atau** bukan milik pengguna yang login |
| `422 Unprocessable Content` | Validasi gagal, kode voucher salah, atau aturan bisnis dilanggar |
| `500 Server Error` | Kesalahan tak terduga di server |

> Kepemilikan resource diperiksa dengan `abort_unless(... , 404)`. Jadi
> mengakses pesanan/alamat/item keranjang milik pengguna lain menghasilkan
> `404`, bukan `403`.

---

## 2. Ringkasan Endpoint

### 2.1 Endpoint Publik (tanpa token)

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| POST | `/api/auth/register` | Daftar akun baru, langsung dapat token |
| POST | `/api/auth/login` | Masuk dengan email/nomor HP + password |
| POST | `/api/auth/login/google` | Masuk dengan Google (simulasi, akun dibuat otomatis) |
| GET | `/api/outlets` | Daftar outlet aktif |
| GET | `/api/categories` | Daftar kategori aktif |
| GET | `/api/products` | Daftar produk menu; filter `category`, `type`, `new` |
| GET | `/api/products/{product}` | Detail produk + grup opsi kustomisasi |
| GET | `/api/merch` | Daftar merchandise |
| GET | `/api/voucher-packs` | Daftar paket voucher yang dijual |
| GET | `/api/vouchers/catalog` | Katalog contoh voucher yang bisa langsung dipakai |
| GET | `/api/checkin/rewards` | Enam hadiah Daily Check-In |
| GET | `/api/static-pages/{slug}` | Halaman statis (bantuan, privasi, dll.) |
| POST | `/api/bulk-orders` | Kirim permintaan pesanan besar (boleh tanpa login) |

### 2.2 Autentikasi & Profil (token)

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| GET | `/api/auth/me` | Profil, membership, dan pengaturan pengguna aktif |
| POST | `/api/auth/logout` | Hapus token yang sedang dipakai |
| POST | `/api/auth/logout-all` | Hapus semua token pengguna |
| GET | `/api/profile` | Profil + membership + pengaturan |
| PUT | `/api/profile` | Ubah nama dan identifier |
| PUT | `/api/profile/password` | Ganti password |

### 2.3 Alamat

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| GET | `/api/addresses` | Daftar alamat (default lebih dulu) |
| POST | `/api/addresses` | Tambah alamat (alamat pertama otomatis default) |
| PUT/PATCH | `/api/addresses/{address}` | Ubah alamat |
| DELETE | `/api/addresses/{address}` | Hapus alamat |
| PUT | `/api/addresses/{address}/default` | Jadikan alamat utama |

### 2.4 Keranjang

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| GET | `/api/cart` | Isi keranjang + total kuantitas & harga |
| POST | `/api/cart/items` | Tambah satu baris item |
| PUT | `/api/cart/items/{cartItem}` | Ubah jumlah/catatan; jumlah `0` menghapus item |
| DELETE | `/api/cart/items/{cartItem}` | Hapus item |
| DELETE | `/api/cart` | Kosongkan keranjang |

### 2.5 Voucher & Promo

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| GET | `/api/vouchers` | Voucher milik pengguna |
| POST | `/api/vouchers/validate` | Validasi kode + hitung potongan |
| POST | `/api/voucher-packs/{voucherPack}/buy` | Beli paket; voucher langsung masuk akun |
| GET | `/api/promos` | Label promo yang sudah diklaim |
| POST | `/api/promos/claim` | Klaim promo berdasarkan label |

### 2.6 Pesanan

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| GET | `/api/orders` | Riwayat pesanan (terbaru dulu) |
| POST | `/api/orders` | Buat pesanan (checkout) |
| GET | `/api/orders/{order}` | Detail pesanan |
| PUT | `/api/orders/{order}/advance` | Majukan status satu langkah |
| PUT | `/api/orders/{order}/cancel` | Batalkan pesanan |

### 2.7 Membership & Check-In

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| GET | `/api/membership` | Poin, total belanja, level, progres level |
| GET | `/api/points/history` | Riwayat poin (maksimal 100 terbaru) |
| GET | `/api/checkin` | Status check-in bulan berjalan |
| POST | `/api/checkin` | Lakukan check-in hari ini |

### 2.8 Pembayaran

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| GET | `/api/payment-methods` | Daftar metode + status koneksi/pilihan |
| PUT | `/api/payment-methods/select` | Pilih metode pembayaran |
| POST | `/api/payment-methods/{paymentMethod}/connect` | Hubungkan metode yang butuh koneksi |

### 2.9 Kotak Masuk & Pengaturan

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| GET | `/api/inbox` | Daftar pesan + jumlah belum dibaca |
| PUT | `/api/inbox/{inboxMessage}/read` | Tandai satu pesan sudah dibaca |
| PUT | `/api/inbox/read-all` | Tandai semua pesan sudah dibaca |
| GET | `/api/settings` | Preferensi aplikasi |
| PUT | `/api/settings` | Simpan preferensi aplikasi |

### 2.10 Pesanan Besar

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| GET | `/api/bulk-orders` | Riwayat permintaan pesanan besar milik pengguna |
| POST | `/api/bulk-orders` | Kirim permintaan baru (publik) |

---

## 3. Alur Utama

### 3.1 Registrasi

**Request**

```http
POST /api/auth/register
Content-Type: application/json
```

```json
{
  "name": "Pembeli Baru",
  "identifier": "baru@kangenan.com",
  "password": "rahasia123",
  "password_confirmation": "rahasia123"
}
```

| Field | Tipe | Aturan |
| --- | --- | --- |
| `name` | string | wajib, maks. 100 |
| `identifier` | string | wajib, maks. 150, unik; email atau nomor HP |
| `password` | string | wajib, min. 6, harus sama dengan `password_confirmation` |
| `password_confirmation` | string | wajib |

`identifier_type` ditentukan otomatis: `email` bila format email valid,
selain itu `phone`.

**Response `201`**

```json
{
  "message": "Registrasi berhasil.",
  "data": {
    "token": "1|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "user": {
      "id": 3,
      "name": "Pembeli Baru",
      "identifier": "baru@kangenan.com",
      "identifier_type": "email",
      "provider": "local"
    },
    "membership": {
      "points": 0,
      "total_spent": 0,
      "level": {
        "label": "Silver",
        "min_spend": 0,
        "next_threshold": 700000,
        "is_highest": false
      },
      "level_progress": 0,
      "remaining_to_next_level": 700000
    },
    "settings": {
      "language": "indonesia",
      "notif_promo": true,
      "notif_pesanan": true,
      "biometric": false
    }
  }
}
```

Registrasi (dan login pertama) otomatis membuat data awal: `user_settings`,
`memberships`, `carts`, metode pembayaran `qris` yang sudah terhubung dan
terpilih, serta tiga pesan kotak masuk contoh.

### 3.2 Login

**Request**

```json
{
  "identifier": "demo@kangenan.com",
  "password": "123456"
}
```

**Response `200`** sama bentuknya dengan registrasi, dengan
`message: "Berhasil masuk."`.

Bila kredensial salah, API membalas `422`:

```json
{
  "message": "Email/nomor HP atau password salah.",
  "errors": {
    "identifier": ["Email/nomor HP atau password salah."]
  }
}
```

**Login Google** (`POST /api/auth/login/google`) menerima `identifier`
(wajib) dan `name` (opsional). Akun dibuat otomatis dengan
`provider: "google"` bila belum ada. Endpoint ini **tidak** memverifikasi ID
token Google (lihat [Catatan Integrasi](#6-catatan-integrasi)).

### 3.3 Katalog

```http
GET /api/products?category=coffee&type=menu&new=1
```

| Query | Nilai | Default | Keterangan |
| --- | --- | --- | --- |
| `category` | slug atau nama kategori | - | Filter kategori, mis. `coffee` |
| `type` | `menu`, `merch`, `all` | `menu` | Jenis produk |
| `new` | `1` / `0` | `0` | Hanya produk baru |

**Response `200`**

```json
{
  "data": [
    {
      "id": 6,
      "name": "Taro Cloud Latte",
      "slug": "taro-cloud-latte",
      "description": "Taro creamy dengan espresso.",
      "price": 28000,
      "price_label": "Rp28.000",
      "image": "assets/taro cloud latte.png",
      "type": "menu",
      "is_new": true,
      "promo_label": null,
      "categories": ["Baru!", "Coffee"]
    }
  ]
}
```

Detail produk (`GET /api/products/6`) menambahkan `option_groups`:

```json
{
  "data": {
    "id": 6,
    "name": "Taro Cloud Latte",
    "option_groups": [
      {
        "id": 2,
        "name": "Size",
        "slug": "size",
        "type": "single",
        "is_required": true,
        "max_select": 1,
        "options": [
          { "id": 5, "name": "Regular", "extra_price": 0, "is_available": true },
          { "id": 6, "name": "Large", "extra_price": 4000, "is_available": true }
        ]
      }
    ]
  }
}
```

### 3.4 Keranjang

**Tambah item** — `POST /api/cart/items` (token)

```json
{
  "product_id": 6,
  "name": "Taro Cloud Latte",
  "image": "assets/taro cloud latte.png",
  "base_price": 28000,
  "unit_price": 32000,
  "quantity": 1,
  "size": "Large",
  "milk": "Oatside",
  "sugar": "Less Sugar",
  "ice": "Normal Ice",
  "toppings": ["Boba"],
  "syrups": ["Vanilla"],
  "note": ""
}
```

| Field | Wajib | Keterangan |
| --- | --- | --- |
| `name` | ya | Nama item (snapshot) |
| `base_price`, `unit_price`, `quantity` | ya | Integer; harga dalam Rupiah |
| `product_id` | tidak | Harus ada di tabel `products` bila diisi |
| `image`, `size`, `milk`, `sugar`, `ice`, `note` | tidak | Default: string kosong / `Regular` / `Milk` / `Normal Sugar` / `Normal Ice` |
| `toppings`, `syrups` | tidak | Array string |

Item **selalu ditambahkan sebagai baris baru** (tidak digabung otomatis
dengan baris yang sama).

**Response `201`**

```json
{
  "message": "Masuk ke keranjang.",
  "data": {
    "id": 12,
    "product_id": 6,
    "name": "Taro Cloud Latte",
    "image": "assets/taro cloud latte.png",
    "base_price": 28000,
    "unit_price": 32000,
    "quantity": 1,
    "total_price": 32000,
    "size": "Large",
    "milk": "Oatside",
    "sugar": "Less Sugar",
    "ice": "Normal Ice",
    "toppings": ["Boba"],
    "syrups": ["Vanilla"],
    "note": ""
  }
}
```

**Lihat keranjang** — `GET /api/cart`

```json
{
  "data": {
    "items": [
      {
        "id": 12,
        "product_id": 6,
        "name": "Taro Cloud Latte",
        "quantity": 1,
        "unit_price": 32000,
        "total_price": 32000
      }
    ],
    "total_quantity": 1,
    "total_price": 32000
  }
}
```

Ubah jumlah dengan `PUT /api/cart/items/{cartItem}`:

```json
{ "quantity": 3, "note": "Tanpa es" }
```

`quantity: 0` akan **menghapus** item dan membalas
`{"message": "Item dihapus dari keranjang."}`.

### 3.5 Validasi Voucher

**Request** — `POST /api/vouchers/validate` (token)

```json
{
  "code": "kangenan10",
  "subtotal": 40000
}
```

Kode tidak peka huruf besar/kecil. `subtotal` opsional (default `0`).

**Response `200`**

```json
{
  "message": "Voucher bisa dipakai.",
  "data": {
    "id": 1,
    "code": "KANGENAN10",
    "title": "Diskon 10%",
    "description": "Potongan 10% untuk semua menu.",
    "kind": "percent",
    "percent": 10,
    "amount": 0,
    "min_purchase": 0,
    "validity": "Berlaku s.d. 31 Okt 2026",
    "discount": 4000,
    "is_applicable": true
  }
}
```

Voucher dari katalog otomatis ditambahkan ke akun pengguna saat validasi
berhasil. Bila subtotal di bawah `min_purchase`, respons tetap `200` tetapi
`discount` bernilai `0` dan `is_applicable` bernilai `false`.

Kode tidak dikenal atau tidak aktif menghasilkan `422`:

```json
{ "message": "Kode voucher tidak dikenal atau sudah kadaluarsa." }
```

### 3.6 Checkout

**Request** — `POST /api/orders` (token)

```json
{
  "items": [
    {
      "product_id": 6,
      "name": "Taro Cloud Latte",
      "image": "assets/taro cloud latte.png",
      "base_price": 28000,
      "unit_price": 28000,
      "quantity": 2,
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

| Field | Wajib | Keterangan |
| --- | --- | --- |
| `items` | ya | Minimal 1 item; field item sama seperti keranjang |
| `outlet_id` | tidak | Harus ada di `outlets` bila diisi |
| `bag_fee` | tidak | Integer ≥ 0, default `0` |
| `voucher_code` | tidak | Kode voucher aktif |
| `points_used` | tidak | Integer ≥ 0; otomatis dibatasi saldo & total |
| `payment_method_id` | tidak | Default `qris`; harus ada di `payment_methods` |
| `fulfilment` | tidak | `Pickup` (default) atau `Delivery` |
| `scheduled_at` | tidak | Tanggal/waktu ISO 8601 |

Rumus total:

```text
subtotal        = Σ (unit_price × quantity)
points_used     = min(points_used, saldo_poin, subtotal + bag_fee - diskon)
total           = max(0, subtotal + bag_fee - diskon_voucher - points_used)
```

Pembuatan pesanan berjalan dalam **satu transaksi database**: simpan order dan
item, potong poin, tandai voucher terpakai, lalu catat belanja untuk poin dan
level membership.

**Response `201`**

```json
{
  "message": "Pesanan berhasil dibuat.",
  "data": {
    "id": 2,
    "code": "#1002",
    "items": [
      {
        "id": 3,
        "product_id": 6,
        "name": "Taro Cloud Latte",
        "image": "assets/taro cloud latte.png",
        "base_price": 28000,
        "unit_price": 28000,
        "quantity": 2,
        "total_price": 56000,
        "size": "Regular",
        "milk": "Milk",
        "sugar": "Normal Sugar",
        "ice": "Normal Ice",
        "toppings": [],
        "syrups": [],
        "note": ""
      }
    ],
    "subtotal": 56000,
    "bag_fee": 0,
    "voucher_discount": 5600,
    "points_used": 10,
    "total": 50390,
    "payment_method": "QRIS",
    "payment_method_id": "qris",
    "fulfilment": "Pickup",
    "status": "Pending",
    "is_final": false,
    "scheduled_at": null,
    "created_at": "2026-10-20T10:15:00+07:00"
  }
}
```

Kode pesanan berformat `#XXXX`, dimulai dari `#1002` untuk pesanan baru
(`#1001` adalah data demo).

**Status pesanan**

```text
Pending → Processing → Ready → Completed
        ↘ Cancelled (kapan saja sebelum Completed)
```

- `PUT /api/orders/{order}/advance` memajukan satu langkah. Bila status sudah
  `Completed`/`Cancelled`, respons tetap `200` tanpa perubahan.
- `PUT /api/orders/{order}/cancel` membatalkan. Pesanan final menghasilkan
  `422` dengan pesan
  `"Pesanan yang sudah selesai tidak bisa dibatalkan."`.

### 3.7 Membership & Check-In

**Ringkasan** — `GET /api/membership`

```json
{
  "data": {
    "points": 28,
    "total_spent": 28000,
    "level": {
      "label": "Silver",
      "min_spend": 0,
      "next_threshold": 700000,
      "is_highest": false
    },
    "level_progress": 0.04,
    "remaining_to_next_level": 672000
  }
}
```

**Status check-in** — `GET /api/checkin`

```json
{
  "data": {
    "period": "2026-10",
    "checked_days": [1, 2],
    "max_days": 6,
    "can_check_in": true,
    "points": 78
  }
}
```

**Check-in** — `POST /api/checkin` (tanpa body)

```json
{
  "message": "Check-in hari ke-3 berhasil: +40 poin.",
  "data": {
    "day": 3,
    "reward": "+40 poin",
    "points": 40,
    "membership": {
      "points": 118,
      "total_spent": 28000,
      "level": {
        "label": "Silver",
        "min_spend": 0,
        "next_threshold": 700000,
        "is_highest": false
      },
      "level_progress": 0.04,
      "remaining_to_next_level": 672000
    }
  }
}
```

Check-in dibatasi 6 hari per bulan (`period` berformat `YYYY-MM`). Bila sudah
6 kali, API membalas `422`:
`"Kamu sudah check-in 6 hari. Sampai jumpa bulan depan!"`.

### 3.8 Contoh `curl`

```bash
# Login
curl -s -X POST http://localhost:8000/api/auth/login \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"identifier":"demo@kangenan.com","password":"123456"}'

# Ambil katalog
curl -s "http://localhost:8000/api/products?category=coffee" \
  -H "Accept: application/json"

# Checkout
curl -s -X POST http://localhost:8000/api/orders \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 1|xxxxxxxx" \
  -d '{
    "items": [{
      "name": "Taro Cloud Latte",
      "base_price": 28000,
      "unit_price": 28000,
      "quantity": 1
    }],
    "payment_method_id": "qris"
  }'
```

---

## 4. Aturan Bisnis

### 4.1 Poin & Level

| Aturan | Nilai |
| --- | --- |
| Poin didapat | 1 poin per Rp1.000 total belanja (`intdiv(total, 1000)`) |
| Nilai poin saat dipakai | 1 poin = Rp1 |
| Poin maksimal dipakai | Sebesar saldo dan tidak melebihi tagihan |
| Level dihitung dari | `total_spent` (tidak disimpan di kolom terpisah) |

| Level | Ambang `total_spent` | Ambang berikutnya |
| --- | --- | --- |
| Silver | ≥ Rp0 | Rp700.000 |
| Gold | ≥ Rp700.000 | Rp9.999.999 |
| Black | ≥ Rp9.999.999 | - (tertinggi) |

### 4.2 Voucher

- Pencarian kode tidak peka huruf besar/kecil.
- Hanya voucher `is_active = true` yang bisa dipakai.
- `percent > 0` → potongan `intdiv(subtotal × percent, 100)`.
- Selain itu → potongan sebesar `amount`.
- Potongan tidak pernah melebihi subtotal.
- Bila `min_purchase > 0` dan subtotal lebih kecil, potongan `0`.
- Voucher yang dipakai saat checkout ditandai `status = "used"` beserta
  `used_at` dan `order_id`.
- Catatan: voucher yang potongannya `0` karena subtotal di bawah
  `min_purchase` **tetap ditandai terpakai** bila kodenya dikirim saat
  checkout. Validasi dulu lewat `/api/vouchers/validate` untuk menghindari ini.

### 4.3 Pembayaran

- `needs_connection = true` (mis. GoPay) harus di-`connect` sebelum bisa
  dipilih.
- Memilih metode yang butuh koneksi tetapi belum terhubung tidak mengubah
  pilihan; respons tetap `200` dengan `is_selected: false`.
- `buyPack` hanya memberikan voucher ke akun; belum ada pemotongan saldo atau
  integrasi payment gateway.

### 4.4 Pesanan Besar

`POST /api/bulk-orders` dapat dipanggil tanpa login (`user_id` menjadi
`null`). Status awal selalu `"Baru"`. Field wajib: `name`, `contact`,
`purpose`, `estimated_cups`; `event_date` dan `note` opsional.

---

## 5. Format Error

### 5.1 Validasi (`422`)

```json
{
  "message": "The name field is required.",
  "errors": {
    "name": ["The name field is required."]
  }
}
```

Pesan bawaan Laravel berbahasa Inggris karena aplikasi belum memuat file
terjemahan validasi. Beberapa error bisnis memakai pesan Indonesia, misalnya
login dan voucher.

### 5.2 Aturan bisnis (`422`)

```json
{ "message": "Keranjang masih kosong." }
```

```json
{ "message": "Kode voucher tidak dikenal atau sudah kadaluarsa." }
```

### 5.3 Tidak ditemukan / bukan pemilik (`404`)

```json
{ "message": "No query results for model [App\\Models\\Order]." }
```

Atau, untuk pemeriksaan kepemilikan:

```json
{ "message": "Not Found" }
```

### 5.4 Belum login (`401`)

```json
{ "message": "Unauthenticated." }
```

---

## 6. Catatan Integrasi

1. **Nominal uang** selalu integer Rupiah; jangan mengirim string
   `"Rp28.000"`. Gunakan `price_label` hanya untuk tampilan.
2. **Snapshot harga**: keranjang dan pesanan menyimpan `name`, `image`,
   `base_price`, dan `unit_price` dari klien. Perubahan harga produk tidak
   mengubah isi keranjang/pesanan lama.
3. **Keranjang tidak otomatis digabung**: menambah produk dengan opsi sama
   dua kali menghasilkan dua baris.
4. **Voucher katalog bersifat global** dan bisa dipakai berkali-kali oleh
   pengguna berbeda; `user_vouchers` mencatat salinan per pengguna.
5. **Login Google masih simulasi** dan belum memverifikasi token Google.
6. **Belum ada rate limit** pada endpoint autentikasi.
7. **Belum ada endpoint admin**; seluruh endpoint hanya untuk pengguna
   aplikasi.
8. **Zona waktu** mengikuti `APP_TIMEZONE` Laravel (default `UTC`); waktu
   dikirim dalam ISO 8601. Atur ke `Asia/Jakarta` bila ingin waktu lokal.

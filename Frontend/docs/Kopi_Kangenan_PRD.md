# Product Requirements Document (PRD)
## Kopi Kangenan — Aplikasi Mobile Pemesanan Kopi
Versi: 1.0
Tanggal: 14 Oktober 2026
Mata Kuliah: Pemrograman Aplikasi Bergerak
Tech Stack: Flutter, Laravel, MySQL (Laragon)

## 1. Ringkasan Eksekutif
Kopi Kangenan adalah aplikasi mobile pemesanan kopi yang mereplikasi pengalaman pengguna aplikasi Kopi Kenangan. Aplikasi ini memungkinkan pengguna menemukan outlet terdekat, memesan kopi dengan kustomisasi lengkap, melakukan pembayaran, serta mengumpulkan poin dan voucher melalui program membership.

Proyek ini dibangun dengan Flutter sebagai frontend, Laravel sebagai backend REST API, dan MySQL sebagai database. Seluruh sistem dijalankan secara lokal menggunakan Laragon.

## 2. Latar Belakang & Tujuan
### 2.1 Latar Belakang
Aplikasi pemesanan kopi modern menuntut pengalaman yang cepat, personal, dan terintegrasi. Pengguna ingin memesan tanpa antri, menyesuaikan pesanan sesuai selera, dan mendapatkan reward dari setiap transaksi. Kopi Kangenan hadir sebagai implementasi konsep tersebut dalam lingkup tugas akademik.

### 2.2 Tujuan Produk
Membangun aplikasi mobile dengan alur pemesanan end-to-end yang berfungsi.

Menyediakan fitur kustomisasi produk yang fleksibel.

Mengintegrasikan frontend Flutter dengan backend Laravel dan database MySQL.

Menghadirkan program membership dengan level, poin, dan voucher.

### 2.3 Kriteria Keberhasilan
Seluruh alur utama (pilih outlet → pesan → checkout → status) berjalan tanpa error.

Integrasi Flutter ↔ Laravel REST API berfungsi stabil.

Database terisi data seed yang realistis.

Antarmuka mendekati aplikasi referensi dari sisi warna, layout, dan navigasi.

## 3. Ruang Lingkup
### 3.1 Termasuk dalam Ruang Lingkup
Aplikasi mobile Flutter untuk platform Android.

Backend REST API dengan Laravel.

Database MySQL dengan skema lengkap.

Fitur pemesanan, kustomisasi, pembayaran simulasi, membership, voucher, dan merchandise.

Data seed untuk outlet, kategori, produk, dan promo.

### 3.2 Tidak Termasuk dalam Ruang Lingkup
Pembayaran real (hanya simulasi).

Push notification real (hanya simulasi).

Integrasi peta real (menggunakan koordinat statis).

Aplikasi iOS.

Panel admin berbasis web.

## 4. Pengguna & Peran
Peran	Deskripsi	Kebutuhan Utama
Guest	Pengguna belum login	Melihat menu, promo, outlet
Member	Pengguna sudah login	Memesan, kustomisasi, bayar, kumpulkan poin
Member VIP	Member dengan level tertentu	Akses voucher, benefit, dan promo eksklusif
## 5. Fitur Lengkap
5.1 Autentikasi & Akun
F1. Registrasi

Input nomor handphone dengan prefix +62.

Verifikasi OTP simulasi (kode statis atau random yang ditampilkan).

Input nama lengkap setelah verifikasi.

Simpan data user ke database.

F2. Login

Input nomor handphone.

Verifikasi OTP simulasi.

Simpan token autentikasi di perangkat.

Opsi login dengan akun Google (simulasi).

F3. Profil Pengguna

Lihat dan edit nama, email, nomor telepon.

Lihat level membership dan total poin.

Lihat total belanja.

Logout.

F4. Alamat Pengiriman

Daftar alamat tersimpan.

Tambah alamat baru (label, alamat lengkap, patokan, koordinat).

Edit dan hapus alamat.

Pilih alamat default.

F5. Kotak Masuk

Daftar notifikasi (promo, status pesanan, info akun).

Tandai sudah dibaca.

Hapus notifikasi.

5.2 Beranda
F6. Header Dinamis

Sapaan "Hai, Guest" atau "Hai, [Nama]" jika sudah login.

Tombol masuk jika belum login.

Menampilkan level dan poin jika sudah login.

F7. Pilih Outlet

Dropdown outlet yang sedang dipilih.

Toggle antara mode Delivery dan Pickup.

Tombol untuk membuka halaman daftar outlet.

F8. Banner Promo

Carousel banner promo yang bisa di-scroll horizontal.

Setiap banner memiliki gambar, judul, dan tautan ke halaman terkait.

Indikator halaman (dots).

F9. Spesial Hari Ini

Daftar produk promo dalam bentuk horizontal scroll.

Setiap kartu menampilkan gambar, nama, harga asli, harga promo, dan label promo.

F10. Diskon & Cashback

Kartu promo yang menampilkan nilai diskon atau cashback.

Tombol "Klaim" untuk menyimpan promo ke akun.

Menampilkan mitra promo (contoh: OVO, GExpress).

F11. Baru!

Daftar produk baru dalam bentuk grid.

Setiap kartu menampilkan gambar, nama, harga, dan badge "New".

F12. Makanan

Daftar produk kategori makanan dalam bentuk grid.

Setiap kartu menampilkan gambar, nama, dan harga.

F13. Voucher Package

Banner promosi paket voucher.

Tautan ke halaman pembelian paket voucher.

F14. Chat Layanan Pelanggan

Tombol yang membuka tautan ke WhatsApp layanan pelanggan.

Menampilkan nomor layanan pengaduan konsumen.

5.3 Menu & Katalog
F15. Kategori Produk

Tab horizontal yang bisa di-scroll.

Kategori: Promo & Combo, Baru!, Coffee, Non Coffee, Kangenan Toast, Food, Manual Brew, Kangenan at Home, Special Merchandise.

Tab aktif ditandai dengan garis bawah berwarna.

F16. Daftar Produk

Grid 2 kolom untuk setiap kategori.

Setiap kartu menampilkan gambar, nama, harga, dan badge (New, Promo Delivery).

Produk dengan stok habis ditandai "Out of Stock" dan tidak bisa dipilih.

F17. Pencarian Produk

Search bar untuk mencari produk berdasarkan nama.

Hasil pencarian ditampilkan secara real-time.

5.4 Detail Produk & Kustomisasi
F18. Halaman Detail Produk

Gambar produk ukuran besar.

Nama produk dan harga dasar.

Deskripsi produk.

Banner detail produk (opsional).

F19. Kustomisasi Wajib (Single Select)

Temperature: Ice, Hot.

Size: Regular, Large.

Beans: Kangenan Blend, Juwara Beans.

Milk Option: Milk, Oatside.

Sugar Level: Normal Sugar, Less Sugar.

Ice Level: Normal Ice, Less Ice, No Ice.

Setiap grup wajib dipilih satu.

Opsi yang tidak tersedia ditandai "Out of Stock" dan tidak bisa dipilih.

F20. Kustomisasi Opsional (Multiple Select)

Syrup: Vanilla Syrup, Hazelnut Syrup, Caramel Syrup, Salted Caramel Sauce, Choco Sauce, Butterscotch Sauce. Setiap pilihan menambah Rp6.000.

Topping: Espresso Shot Kangenan Blend, Espresso Shot Juwara Beans, Golden Boba (Out of Stock), Grass Jelly (Out of Stock), Oreo, Whipped Cream Chocolate. Setiap pilihan menambah Rp6.000.

Bisa memilih lebih dari satu atau tidak sama sekali.

F21. Catatan Tambahan

Text field dengan batas 100 karakter.

Placeholder: "Ga perlu baper".

F22. Harga Dinamis

Harga total dihitung dari harga dasar + semua tambahan.

Harga diperbarui secara real-time saat pengguna mengubah pilihan.

F23. Pemilih Jumlah

Tombol minus dan plus untuk mengatur quantity.

Quantity minimal 1.

F24. Tambah ke Keranjang

Tombol "+ Keranjang Rp[total]" yang menampilkan harga dinamis.

Validasi: semua single select wajib dipilih sebelum bisa menambahkan.

Setelah ditambahkan, pengguna diarahkan ke keranjang atau tetap di halaman.

5.5 Keranjang & Konfirmasi Pesanan
F25. Halaman Konfirmasi Pesanan

Tab metode: Pickup, Dine-In (jika tersedia), Delivery.

Info outlet yang dipilih dengan tombol "Ubah".

Info alamat delivery (jika mode Delivery) dengan tombol "Ubah".

Daftar item pesanan yang menampilkan nama produk, kustomisasi, harga, tombol "Ganti", dan quantity selector.

Tombol "Tambah Pesanan +" untuk kembali ke menu.

Seksi voucher: "Tambah pesanan untuk pakai voucher" (disabled jika belum memenuhi syarat) dan "Pakai Kode Voucher".

Total harga di bagian bawah.

Tombol "Pilih Pembayaran".

F26. Modal Konfirmasi Pickup

Menampilkan icon pickup, nama outlet, dan opsi "Pickup di Counter".

Teks instruksi: "Ambil pesananmu di Area Pickup di dalam outlet".

Tombol "Ya, Sudah Benar".

F27. Edit Kustomisasi

Tombol "Ganti" membuka kembali halaman kustomisasi dengan pilihan sebelumnya.

Perubahan memperbarui item di keranjang.

F28. Ubah Quantity

Tombol minus dan plus untuk mengubah jumlah item.

Menghapus item jika quantity menjadi 0.

F29. Hapus Item

Tombol hapus atau swipe untuk menghapus item dari keranjang.

5.6 Checkout & Pembayaran
F30. Halaman Checkout

Info outlet dan opsi pickup/delivery.

Seksi "Kangenan Points": checkbox untuk redeem poin, keterangan "1 Kangenan Point = 1 Rupiah".

Seksi "Pembayaran Langsung": pilihan metode pembayaran (blu by BCA Digital, QRIS, GoPay, dan lainnya), tombol "Hubungkan" untuk metode yang memerlukan koneksi, tautan "Lihat Semua".

Detail pesanan: daftar item, quantity, harga.

Opsi "Kantung Belanja" (donasi) dengan checkbox dan biaya Rp4.000.

Tombol "Pakai Kode Voucher".

Seksi "Beli Paket Voucher, Langsung Hemat" yang menampilkan paket voucher dengan harga asli, harga diskon, dan tombol "Buy Pack".

Ringkasan: Subtotal, Total Pembayaran.

Info: "Loyalty Cashback tidak berlaku dengan penggunaan Kangenan Point / promo lainnya".

Tombol "Jadwalkan" (dengan icon jam).

Tombol "Bayar - Rp[total]".

F31. Redeem Poin

Checkbox untuk menggunakan poin.

Poin dikonversi 1:1 dengan Rupiah.

Total pembayaran berkurang sesuai poin yang diredeem.

F32. Pakai Voucher

Input kode voucher manual.

Validasi kode voucher ke backend.

Voucher yang valid mengurangi total pembayaran.

Menampilkan pesan error jika voucher tidak valid atau sudah kadaluarsa.

F33. Beli Paket Voucher

Menampilkan daftar paket voucher yang tersedia.

Setiap paket menampilkan nama, deskripsi, jumlah voucher, harga asli, harga diskon, dan persentase penghematan.

Tombol "Buy Pack" untuk membeli paket.

Setelah dibeli, voucher ditambahkan ke akun pengguna.

F34. Metode Pembayaran

Pilihan: blu by BCA Digital, QRIS, GoPay, dan metode lain.

Setiap metode menampilkan logo dan keterangan (contoh: "Cashback 40% max. 25RB").

Untuk metode yang memerlukan koneksi (GoPay), tampilkan tombol "Hubungkan".

F35. Jadwalkan Pesanan

Tombol "Jadwalkan" membuka modal untuk memilih tanggal dan waktu pengambilan/pengiriman.

Simpan jadwal ke database.

F36. Proses Pembayaran

Tombol "Bayar" memproses pembayaran (simulasi).

Setelah berhasil, buat order di database dengan status "pending".

Arahkan pengguna ke halaman status pesanan.

5.7 Status & Riwayat Pesanan
F37. Halaman Status Pesanan

Menampilkan status terkini: Pending, Processing, Ready, Completed, Cancelled.

Estimasi waktu.

Detail pesanan: item, kustomisasi, total.

Tombol "Ambil di Outlet" atau tracking delivery (simulasi).

Tombol "Hubungi Outlet".

F38. Halaman Riwayat Pesanan

Daftar pesanan sebelumnya.

Setiap item menampilkan tanggal, status, total, dan outlet.

Tombol "Pesan Lagi" untuk memesan ulang item yang sama.

Filter berdasarkan status.

5.8 Membership & VIP
F39. Halaman VIP

Kartu level membership yang menampilkan:

Level: Silver, Gold, Black.

Nama pengguna.

Progress bar menuju level berikutnya.

Teks "Belanja Rp[X] lagi untuk naik ke Level [Y]".

Icon level (hati untuk Silver, kunci untuk Gold, kunci hitam untuk Black).

F40. Tab Voucher

Input kode voucher.

Filter chips: Semua, Diskon, Cashback, Delivery.

Daftar voucher tersedia: nama, deskripsi, min. pembelian, tanggal berlaku, tombol "Pakai Voucher".

Badge "Pakai di App" untuk voucher yang bisa digunakan langsung.

F41. Tab Voucher Pack

Daftar paket voucher yang bisa dibeli.

Setiap paket menampilkan nama, deskripsi, jumlah voucher, harga asli, harga diskon, persentase penghematan, dan tombol "Buy Pack".

F42. Tab Benefits

Daftar benefit per level:

Cashback (5% untuk Silver/Gold, 10% untuk Black).

Membership Voucher.

Birthday Treats.

Special Treats (Black only).

Exclusive Promotion (Black only).

Icon kunci untuk benefit yang belum terbuka.

F43. Level Membership

Silver: Level awal, cashback 5%.

Gold: Butuh belanja Rp700.000, cashback 5%, benefit tambahan.

Black: Butuh belanja Rp9.999.999, cashback 10%, semua benefit.

5.9 Daily Check-In & Poin
F44. Daily Check-In

Tampil di halaman profil.

6 hari check-in dengan reward berbeda:

Hari 1: +25 poin.

Hari 2: +25 poin.

Hari 3: Voucher.

Hari 4: +25 poin.

Hari 5: +25 poin.

Hari 6: Voucher.

Tombol "Check-In" untuk hari ini.

Hari yang sudah check-in ditandai.

Reset setiap bulan.

F45. Poin

Poin didapat dari transaksi (1 poin = 1 Rupiah).

Poin bisa diredeem saat checkout.

Riwayat poin: didapat dan digunakan.

5.10 Merchandise
F46. Halaman Merch

Katalog merchandise: Cuddly Pals, Sigma Slim Bottle, Little Sunshine Friends, Playsonality Grip Tumbler, Playsonality Classic Cup, Playsonality Press Tumbler.

Setiap item menampilkan gambar, nama, harga, dan badge "New".

Tombol untuk melihat detail.

F47. Detail Merchandise

Gambar, nama, deskripsi, harga.

Tombol "Tambah ke Keranjang".

Kustomisasi (jika ada).

F48. Scan Merchandise

Fitur scan QR code untuk merchandise (simulasi).

Menampilkan informasi merchandise setelah scan.

5.11 Pengaturan
F49. Ubah Bahasa

Pilihan bahasa: Indonesia, English.

Perubahan bahasa diterapkan ke seluruh aplikasi.

F50. Notifikasi

Pengaturan untuk mengaktifkan/menonaktifkan notifikasi promo dan pesanan.

## 6. Alur Pengguna
6.1 Alur Pemesanan Utama
```text
Buka Aplikasi → Splash Screen → Beranda (Guest)
→ Pilih Outlet → Menu → Pilih Produk → Kustomisasi
→ Tambah ke Keranjang → Konfirmasi Pesanan
→ Checkout → Pilih Pembayaran → Bayar
→ Status Pesanan → Selesai
6.2 Alur Login
```text
Beranda (Guest) → Tap "Masuk" → Input Nomor HP
→ Verifikasi OTP → Input Nama → Beranda (Member)
6.3 Alur Membership
```text
Profil → VIP → Lihat Level & Poin → Tab Voucher/Benefits
→ Pakai Voucher / Beli Paket Voucher
6.4 Alur Daily Check-In
```text
Profil → Daily Check-In → Tap "Check-In" → Dapat Poin/Voucher
## 7. Persyaratan Teknis
7.1 Teknologi
Komponen	Teknologi
Frontend	Flutter (Dart)
Backend	Laravel 11 (PHP)
Database	MySQL
Environment	Laragon
API	RESTful JSON
Autentikasi	Token-based (Laravel Sanctum)
7.2 Arsitektur
```text
Flutter App ↔ REST API (Laravel) ↔ MySQL Database
7.3 Endpoint API
Autentikasi

Method	Endpoint	Deskripsi
POST	/api/auth/register	Registrasi
POST	/api/auth/login	Login
POST	/api/auth/verify-otp	Verifikasi OTP
POST	/api/auth/logout	Logout
GET	/api/auth/me	Data user saat ini
Outlet

Method	Endpoint	Deskripsi
GET	/api/outlets	Daftar outlet
GET	/api/outlets/:id	Detail outlet
GET	/api/outlets/nearby	Outlet terdekat
Produk

Method	Endpoint	Deskripsi
GET	/api/categories	Daftar kategori
GET	/api/products	Daftar produk
GET	/api/products/:id	Detail produk + kustomisasi
GET	/api/products/search	Pencarian produk
Pesanan

Method	Endpoint	Deskripsi
POST	/api/orders	Buat pesanan
GET	/api/orders/:id	Detail pesanan
GET	/api/orders/user	Riwayat pesanan
POST	/api/orders/:id/cancel	Batalkan pesanan
Voucher

Method	Endpoint	Deskripsi
GET	/api/vouchers	Daftar voucher user
POST	/api/vouchers/validate	Validasi voucher
GET	/api/voucher-packages	Daftar paket voucher
POST	/api/voucher-packages/buy	Beli paket voucher
Membership

Method	Endpoint	Deskripsi
GET	/api/membership/status	Status membership
GET	/api/membership/benefits	Daftar benefit
POST	/api/membership/checkin	Daily check-in
GET	/api/membership/points	Riwayat poin
Pembayaran

Method	Endpoint	Deskripsi
GET	/api/payments/methods	Metode pembayaran
POST	/api/payments/process	Proses pembayaran
Pengguna

Method	Endpoint	Deskripsi
PUT	/api/users/profile	Update profil
GET	/api/users/addresses	Daftar alamat
POST	/api/users/addresses	Tambah alamat
PUT	/api/users/addresses/:id	Edit alamat
DELETE	/api/users/addresses/:id	Hapus alamat
Konten

Method	Endpoint	Deskripsi
GET	/api/banners	Banner promo
GET	/api/promos	Promo aktif
GET	/api/notifications	Notifikasi user
7.4 Skema Database
users

```sql
id, name, email, phone, password, avatar_url,
membership_level, total_spending, points,
created_at, updated_at
outlets

```sql
id, name, address, latitude, longitude,
open_time, close_time,
supports_pickup, supports_delivery, supports_dine_in,
brand, created_at
categories

```sql
id, name, slug, sort_order, is_active
products

```sql
id, category_id, name, description, base_price,
image_url, is_new, is_promo, promo_label,
is_available, sort_order, created_at
customization_groups

```sql
id, product_id, name, type, is_required, sort_order
customization_options

```sql
id, group_id, name, additional_price,
is_available, sort_order
orders

```sql
id, user_id, outlet_id, order_type, status,
subtotal, discount, delivery_fee, bag_fee,
points_redeemed, points_earned, total,
payment_method, voucher_code, pickup_time,
delivery_address, notes, created_at, updated_at
order_items

```sql
id, order_id, product_id, product_name, quantity,
base_price, customization_price, total_price,
customization_json, notes
vouchers

```sql
id, code, name, description, type, value,
max_discount, min_purchase, valid_from, valid_until,
is_active
user_vouchers

```sql
id, user_id, voucher_id, is_used, used_at
voucher_packages

```sql
id, name, description, original_price,
package_price, voucher_count, save_percentage,
is_active
membership_benefits

```sql
id, level, name, description, icon, sort_order
daily_checkins

```sql
id, user_id, day_number, reward_type,
reward_value, checked_in_at
banners

```sql
id, title, image_url, link_type, link_id,
sort_order, is_active
notifications

```sql
id, user_id, title, message, type,
is_read, created_at
addresses

```sql
id, user_id, label, address, note,
latitude, longitude, is_default
7.5 Persyaratan Non-Fungsional
Aspek	Target
Waktu respons API	< 500ms (lokal)
Waktu muat aplikasi	< 3 detik
Ukuran aplikasi	< 50MB
Keamanan	Password ter-hash, token autentikasi
Kompatibilitas	Android 8.0+
## 8. Desain Antarmuka
8.1 Panduan Visual
Warna Utama: Merah (#C62828)

Warna Sekunder: Krem (#FFF8E1)

Warna Aksen: Hijau (#4CAF50) untuk pickup, Biru (#2196F3) untuk delivery

Font: Poppins atau Inter

Logo: Ikon hati dengan garis

8.2 Komponen Navigasi
Bottom navigation dengan 5 tab: Beranda, Menu, VIP, Merch, Saya.

Tab aktif ditandai dengan warna merah dan icon terisi.

8.3 Daftar Halaman
No	Halaman	Prioritas
1	Splash Screen	Tinggi
2	Login / OTP	Tinggi
3	Beranda	Tinggi
4	Daftar Outlet	Tinggi
5	Menu + Kategori	Tinggi
6	Detail Produk + Kustomisasi	Tinggi
7	Konfirmasi Pesanan	Tinggi
8	Checkout	Tinggi
9	Status Pesanan	Tinggi
10	Profil / Saya	Tinggi
11	VIP / Membership	Sedang
12	Merch	Sedang
13	Riwayat Pesanan	Sedang
14	Daily Check-In	Sedang
15	Alamat Pengiriman	Sedang
16	Kotak Masuk	Rendah
17	Ubah Bahasa	Rendah
18	Scan Merchandise	Rendah
## 9. Data Seed
9.1 Outlet (Contoh)
Nama	Alamat	Jam Buka	Layanan
Diponegoro Surabaya	Jl. Diponegoro No.129A	07:00 - 22:00	Pickup, Delivery
Lippo Mall Puri	Lantai Lower Ground	10:00 - 22:00	Pickup, Delivery
Menara Standard Chartered	Lantai Ground Floor	07:00 - 21:00	Pickup, Delivery, Dine-In
Setiabudi One	Lantai 1 Unit B211	07:00 - 21:00	Pickup, Delivery
9.2 Kategori
Promo & Combo

Baru!

Coffee

Non Coffee

Kangenan Toast

Food

Manual Brew

Kangenan at Home

Special Merchandise

9.3 Produk (Contoh)
Coffee:

OG Aren Spesial Latte — Rp24.000

Dua Shot OG Aren — Rp28.000

Pistachio Aren Latte — Rp22.000

Cafe Malt Latte — Rp26.000

Kopi Kangenan Mantan — Rp22.000

Caramel Latte — Rp28.000

Non Coffee:

OG Thai Tea — Rp22.000

OG Aren Milky Spesial — Rp26.000

Butterscotch Sea Salt — Rp25.000

Babyccino — Rp22.000

Hazelnut Choco Milk Tea — Rp23.000

Avocado Caramel — Rp30.000

Kangenan Toast:

Adam Ayam Toast — Rp25.000

Wahyu Sapi Toast — Rp25.000

Food:

Triple Cheese Bagel — Rp22.000

Beef & Cheese Jalapeño — Rp24.000

Double Choco Bagel — Rp22.000

Butter Croissant — Rp15.000

Chocolate Croissant — Rp19.000

Chocolate Donut — Rp13.000

Manual Brew:

Drip Bag Coffee — Rp20.000

Kangenan at Home:

Drip Bag Coffee (Box) — Rp65.000

Special Merchandise:

Cuddly Pals — Rp59.000

Sigma Slim Bottle — Rp209.000

Little Sunshine Friends — Rp49.000

Playsonality Grip Tumbler — Rp179.000

Playsonality Classic Cup — Rp169.000

Playsonality Press Tumbler — Rp159.000

9.4 Kustomisasi (Contoh untuk OG Aren Spesial Latte)
Single Select:

Temperature: Ice, Hot

Size: Regular, Large

Beans: Kangenan Blend, Juwara Beans

Milk Option: Milk, Oatside

Sugar Level: Normal Sugar, Less Sugar

Ice Level: Normal Ice, Less Ice, No Ice

Multiple Select:

Syrup: Vanilla, Hazelnut, Caramel, Salted Caramel, Choco, Butterscotch (+Rp6.000)

Topping: Espresso Shot Kangenan, Espresso Shot Juwara, Golden Boba (Out of Stock), Grass Jelly (Out of Stock), Oreo, Whipped Cream Chocolate (+Rp6.000)

9.5 Voucher (Contoh)
Kode	Nama	Tipe	Nilai	Min. Belanja	Berlaku
CASHBACK30	Cashback 30%	Cashback	30% max 30RB	60RB	14 Okt 2026
DISKON35	Diskon 35%	Diskon	35% max 35RB	60RB	14 Okt 2026
9.6 Paket Voucher (Contoh)
Nama	Harga Asli	Harga Paket	Jumlah	Hemat
Langganan Voucher Rp9.000	Rp630.000	Rp9.000	65x	98%
Langganan Voucher Rp24.000	Rp680.000	Rp24.000	66x	96%
## 10. Rencana Pengembangan
10.1 Fase
Fase	Aktivitas	Durasi
1	Setup environment (Laragon, Laravel, Flutter)	2 hari
2	Backend: migration, model, auth, API dasar	4 hari
3	Frontend: auth, beranda, menu	4 hari
4	Frontend: detail produk, kustomisasi, keranjang	4 hari
5	Frontend: checkout, pembayaran, status	3 hari
6	Frontend: VIP, profil, merch, check-in	3 hari
7	Integrasi, testing, bug fixing	3 hari
8	Dokumentasi, video demo, pengumpulan	2 hari
10.2 Pembagian Tugas (5 Anggota)
Anggota	Tanggung Jawab
1	Backend: database, migration, model, auth, API
2	Frontend: auth, beranda, pilih outlet
3	Frontend: menu, detail produk, kustomisasi
4	Frontend: keranjang, checkout, pembayaran, status
5	Frontend: VIP, profil, merch, check-in, dokumentasi
## 11. Risiko & Mitigasi
Risiko	Dampak	Mitigasi
API tidak terhubung	Tinggi	Setup CORS, gunakan 10.0.2.2 untuk emulator, test awal
Kustomisasi terlalu kompleks	Tinggi	Mulai dari single select, tambahkan multiple select
Konflik topik	Tinggi	Konfirmasi ke PJ Kelas
Deadline mepet	Tinggi	Prioritaskan fitur MVP, fitur tambahan jika waktu cukup
Data seed tidak lengkap	Sedang	Siapkan data seed di awal
## 12. Definisi Selesai
Sebuah fitur dinyatakan selesai jika:

Berfungsi sesuai acceptance criteria.

Terintegrasi dengan backend dan database.

Tidak menyebabkan crash.

UI sesuai dengan panduan visual.

Diuji di emulator Android.

## 13. Lampiran
13.1 Struktur Proyek Flutter
```text
lib/
├── main.dart
├── config/
├── models/
├── services/
├── providers/
├── screens/
│   ├── splash/
│   ├── auth/
│   ├── home/
│   ├── outlet/
│   ├── menu/
│   ├── product/
│   ├── cart/
│   ├── checkout/
│   ├── order/
│   ├── vip/
│   ├── merch/
│   └── profile/
└── widgets/
13.2 Struktur Proyek Laravel
```text
app/
├── Http/
│   ├── Controllers/
│   ├── Middleware/
│   └── Requests/
├── Models/
├── Services/
database/
├── migrations/
├── seeders/
└── factories/
routes/
└── api.php
13.3 Konfigurasi Dasar
Backend berjalan di http://localhost:8000

Frontend mengakses API di http://10.0.2.2:8000/api (Android emulator)

Database: kopi_kangenan dengan charset utf8mb4_unicode_ci
```

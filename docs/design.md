# Design System — Kopi Kangenan

Dokumen ini adalah **sumber kebenaran desain** untuk project Flutter `kopken_clone`.

Seluruh nilai di dokumen ini **diextract langsung dari kode yang sudah ada** di `lib/`. Tujuannya: setiap layar/komponen baru wajib mengikuti token di sini supaya tampilan tetap konsisten.

> **Aturan emas #1 — UI yang ada sekarang adalah acuan, bukan PRD.**
> `Kopi_Kangenan_PRD.md` §8.1 menyebut warna primer `#C62828`, sekunder `#FFF8E1`, dan font Poppins/Inter. **Implementasi nyata memakai maroon `#7A263D` dan font default (Roboto).** Yang berlaku adalah `#7A263D`. Jangan "memperbaiki" warna ke `#C62828` karena itu akan mengubah desain yang sudah disetujui.

> **Aturan emas #2 — Jangan tambah warna baru.**
> Kalau butuh warna yang belum ada, pakai token terdekat dari daftar di §3, atau ajukan penambahan token di dokumen ini dulu. Lihat §14 untuk daftar anti-pola yang sudah terjadi (7 macam "merah brand", 8 macam "emas").

---

## Daftar Isi

1. [Cakupan & Status](#1-cakupan--status)
2. [Divergensi PRD vs UI](#2-divergensi-prd-vs-ui)
3. [Color Tokens](#3-color-tokens)
4. [Typography](#4-typography)
5. [Spacing](#5-spacing)
6. [Border Radius](#6-border-radius)
7. [Elevation & Shadow](#7-elevation--shadow)
8. [Layout, Frame & Breakpoint](#8-layout-frame--breakpoint)
9. [Ikonografi](#9-ikonografi)
10. [Komponen](#10-komponen)
11. [Layout per Halaman](#11-layout-per-halaman)
12. [Navigasi](#12-navigasi)
13. [Copywriting & Format Angka](#13-copywriting--format-angka)
14. [Anti-Pola yang Sudah Ditemukan](#14-anti-pola-yang-sudah-ditemukan)
15. [Checklist Sebelum Bikin Layar Baru](#15-checklist-sebelum-bikin-layar-baru)
16. [Konsolidasi Token](#16-konsolidasi-token)
17. [Keputusan & Batasan yang Disengaja](#17-keputusan--batasan-yang-disengaja)
18. [Integrasi REST API](#18-integrasi-rest-api)

---

## 1. Cakupan & Status

### 1.1 File yang dianalisis

> Angka **Baris** di bawah adalah jumlah baris saat dokumen ini diperbarui
> terakhir (setelah seluruh fitur selesai). Fungsinya hanya sebagai penanda
> ukuran file, bukan target.

**Inti & tema**

| File | Baris | Cakupan desain |
|---|---:|---|
| `lib/main.dart` | 22 | `KopkenApp` + Theme global, `home:` → `SplashScreen` |
| `lib/theme/app_colors.dart` | 193 | `AppColors` — **satu-satunya** sumber warna (§3) |
| `lib/utils/currency.dart` | 29 | `formatRupiah()` + `formatAngka()` — satu-satunya pemformat angka (§13.2) |
| `lib/utils/strings.dart` | 37 | `AppLanguage` + `Strings` — teks yang ikut bahasa (§17) |

**Model & data statis**

| File | Baris | Cakupan desain |
|---|---:|---|
| `lib/models/outlet.dart` | 55 | `Outlet`, `FulfilmentMode`, `kOutlets`, `kDefaultOutlet` |
| `lib/models/product.dart` | 216 | `Product` (+ `description`, `isDrink`), `kDrinkCategories`, `isDrinkCategory()`, `kProductCatalog`, `productsByCategory()` |
| `lib/models/cart.dart` | 87 | `CartItem` (dipakai keranjang & checkout); `hasDrinkOptions`, `customizationLines` |
| `lib/models/merch.dart` | 100 | `Merch` + `kMerchCatalog` |
| `lib/models/voucher.dart` | 115 | `Voucher`, `VoucherKind`, `VoucherPack`, `kVoucherPacks`, `vouchersFromPack()` |
| `lib/models/address.dart` | 38 | `Address` |
| `lib/models/inbox.dart` | 39 | `InboxMessage`, `InboxKind` |
| `lib/models/order.dart` | 64 | `Order`, `OrderStatus` |
| `lib/models/payment_method.dart` | 55 | `PaymentMethod` + `kPaymentMethods` (§11.6) |
| `lib/models/point_entry.dart` | 12 | `PointEntry` — satu baris riwayat poin |

**State in-memory** (semua `ValueNotifier`, tanpa package baru — §2)

| File | Baris | Cakupan desain |
|---|---:|---|
| `lib/services/auth_service.dart` | 237 | `AuthService` — validasi + akun **in-memory** |
| `lib/providers/auth_store.dart` | 97 | `AuthStore` — sesi login |
| `lib/providers/cart_store.dart` | 46 | `CartStore` — isi keranjang |
| `lib/providers/outlet_store.dart` | 26 | `OutletStore` — outlet & mode terpilih |
| `lib/providers/address_store.dart` | 84 | `AddressStore` — alamat pengiriman |
| `lib/providers/member_store.dart` | 120 | `MemberStore` — poin, level, daily check-in |
| `lib/providers/voucher_store.dart` | 84 | `VoucherStore` — voucher akun, promo, Buy Pack |
| `lib/providers/order_store.dart` | 122 | `OrderStore` — pesanan, status, riwayat |
| `lib/providers/inbox_store.dart` | 85 | `InboxStore` — kotak masuk |
| `lib/providers/payment_store.dart` | 29 | `PaymentStore` — metode pembayaran terpilih |
| `lib/providers/settings_store.dart` | 22 | `SettingsStore` — bahasa & preferensi notifikasi |

**Widget bersama**

| File | Baris | Cakupan desain |
|---|---:|---|
| `lib/widgets/ui.dart` | 387 | `AppPage`, `AppCard`, `AppPrimaryButton`, `AppEmptyState`, `AppBottomBar`, `AppSectionTitle`, `AppBadge`, … (§10.1, §10.5) |
| `lib/widgets/mobile_frame.dart` | 23 | `MobileFrame` — bingkai 390 × 844 untuk web (§8.2) |
| `lib/widgets/outlet_card.dart` | 77 | `OutletCard`, `OutletLogoTile` |
| `lib/widgets/category_tabs.dart` | 68 | `CategoryTabs` — tab kategori gaya teks + garis emas |
| `lib/widgets/section_header.dart` | 27 | `SectionHeader` — judul section Beranda/Menu |
| `lib/widgets/product_card.dart` | 181 | `ProductCardGrid`, `ProductCardHorizontal`, `PromoBadge`, `PricePill` |
| `lib/widgets/diskon_cashback_section.dart` | 192 | `DiskonCashbackSection` — dipakai Beranda **dan** Menu |
| `lib/widgets/auth_panel.dart` | 298 | `AuthPanel` + field/tombol bersama panel Login & Daftar (§10.25) |
| `lib/widgets/checkout_sheets.dart` | 255 | Sheet bersama checkout: konfirmasi Pickup & pilih jadwal |
| `lib/widgets/kangenan_coin.dart` | 42 | `KangenanCoin` — koin "K" emas untuk poin (Profil, Daily Check-In) |

**Layar**

| File | Baris | Cakupan desain |
|---|---:|---|
| `lib/screens/splash/splash_screen.dart` | 48 | `SplashScreen` — `logo.png`, latar putih, 3 detik |
| `lib/screens/navigation/login_home_screen.dart` | 40 | `LoginHomeScreen` — shell + pemanggil `showAuthSheet` |
| `lib/screens/navigation/main_navigation_screen.dart` | 187 | Bottom navigation 5 tab, pemilih halaman |
| `lib/screens/home/home_screen.dart` | 592 | Header beranda, banner, quick menu, voucher, Paket Hemat, **Spesial Hari Ini**, Diskon & Cashback, Baru! |
| `lib/screens/outlet/outlet_picker_screen.dart` | 216 | Pilih outlet + segmented Pickup/Delivery |
| `lib/screens/menu/menu_screen.dart` | 250 | Kartu outlet, tab kategori, Diskon & Cashback, 4 section produk |
| `lib/screens/product/product_detail_screen.dart` | 657 | Detail produk: nama + harga + deskripsi, opsi minuman (hanya kategori minuman), quantity, CTA, mode ubah (§11.4) |
| `lib/screens/cart/cart_screen.dart` | 342 | Keranjang: item, jumlah, ringkasan, tombol Checkout |
| `lib/screens/checkout/order_confirmation_screen.dart` | 1092 | Layar "Checkout": alamat/outlet, voucher, poin, kantung, pembayaran |
| `lib/screens/checkout/payment_methods_screen.dart` | 153 | Daftar metode pembayaran |
| `lib/screens/checkout/qris_payment_screen.dart` | 453 | QRIS + countdown + tombol "Kembali Ke Beranda" |
| `lib/screens/checkout/voucher_pack_screen.dart` | 187 | Detail paket voucher (Buy Pack) |
| `lib/screens/order/order_status_screen.dart` | 341 | Status & langkah pesanan |
| `lib/screens/order/order_history_screen.dart` | 260 | Riwayat pesanan + tab status |
| `lib/screens/vip/vip_screen.dart` | 898 | Kartu membership dinamis, tab voucher, Buy Pack, benefit |
| `lib/screens/merch/merch_screen.dart` | 215 | Grid merchandise |
| `lib/screens/merch/merch_detail_screen.dart` | 151 | Detail merchandise |
| `lib/screens/merch/scan_merch_screen.dart` | 152 | Scan QR untuk tukar poin |
| `lib/screens/profile/profile_screen.dart` | 802 | Header profil, promo, daily check-in, menu akun |
| `lib/screens/profile/data_diri_screen.dart` | 303 | Data diri + simpan ke `AuthStore` |
| `lib/screens/profile/address_screen.dart` | 358 | Daftar alamat (tambah/ubah/hapus/jadikan utama) |
| `lib/screens/profile/inbox_screen.dart` | 213 | Kotak Masuk |
| `lib/screens/profile/points_history_screen.dart` | 148 | Riwayat poin |
| `lib/screens/profile/checkin_screen.dart` | 172 | Daily check-in 6 hari |
| `lib/screens/profile/language_screen.dart` | 96 | Ubah bahasa aplikasi (§17) |
| `lib/screens/profile/notification_settings_screen.dart` | 79 | Pengaturan notifikasi |
| `lib/screens/profile/bulk_order_screen.dart` | 165 | Form pesanan dalam jumlah besar |
| `lib/screens/profile/static_page_screen.dart` | 263 | Halaman statis (Bantuan, Tentang, Syarat & Ketentuan, Kebijakan Privasi) |
| `lib/screens/auth/login_screen.dart` | 98 | Isi panel Login (`AuthPanel`) |
| `lib/screens/auth/register_screen.dart` | 103 | Isi panel Daftar (`AuthPanel`) |
| `lib/screens/auth/auth_sheet.dart` | 67 | `showAuthSheet()` + pemilih mode Login/Daftar |

**Tes**

| File | Baris | Cakupan |
|---|---:|---|
| `test/widget_test.dart` | 19 | Splash → Beranda, label bottom nav |
| `test/layout_test.dart` | 160 | Regresi overflow Beranda, Menu, & Profil di 390 × 844 + jarak kartu Profil |
| `test/auth_test.dart` | 455 | Validasi & alur Login/Daftar |
| `test/store_test.dart` | 348 | Semua store in-memory (§11.21) |
| `test/flow_test.dart` | 354 | Alur keranjang → checkout → QRIS → Beranda, opsi minuman vs makanan, Profil, check-in |

### 1.2 Struktur folder `lib/` (sesuai PRD §13.1)

```text
lib/
├── main.dart
├── config/            (kosong — untuk base URL & environment)
├── models/            (outlet, product, cart, merch, voucher, address, inbox,
│                       order, payment_method, point_entry)
├── services/          (auth_service.dart — validasi & akun in-memory)
├── providers/         (auth, cart, outlet, address, member, voucher, order,
│                       inbox, payment, settings — semua state in-memory)
├── theme/             (app_colors.dart — token warna §3)
├── utils/             (currency.dart — formatRupiah; strings.dart — bahasa)
├── widgets/           (ui.dart, mobile_frame, outlet_card, category_tabs,
│                       section_header, product_card, diskon_cashback_section,
│                       auth_panel, checkout_sheets, kangenan_coin)
└── screens/
    ├── splash/        (splash_screen.dart)
    ├── auth/          (auth_sheet.dart, login_screen.dart, register_screen.dart)
    ├── navigation/    (login_home_screen.dart, main_navigation_screen.dart)
    ├── home/          (home_screen.dart)
    ├── outlet/        (outlet_picker_screen.dart)
    ├── menu/          (menu_screen.dart)
    ├── product/       (product_detail_screen.dart)
    ├── cart/          (cart_screen.dart)
    ├── checkout/      (order_confirmation_screen.dart, payment_methods_screen.dart,
    │                    qris_payment_screen.dart, voucher_pack_screen.dart)
    ├── order/         (order_status_screen.dart, order_history_screen.dart)
    ├── vip/           (vip_screen.dart)
    ├── merch/         (merch_screen.dart, merch_detail_screen.dart,
    │                    scan_merch_screen.dart)
    └── profile/       (profile_screen.dart, data_diri_screen.dart,
                         address_screen.dart, inbox_screen.dart,
                         points_history_screen.dart, checkin_screen.dart,
                         language_screen.dart, notification_settings_screen.dart,
                         bulk_order_screen.dart, static_page_screen.dart)
```

> `screens/navigation/` adalah tambahan di luar daftar PRD, karena `main_navigation_screen.dart` (shell bottom nav) tidak termasuk folder fitur mana pun.
>
> `theme/` dan `utils/` juga tambahan di luar daftar PRD §13.1. Keduanya sudah direncanakan di §16.1 dan dipakai mulai dari pekerjaan Beranda/Menu: `theme/app_colors.dart` menampung token §3 supaya komponen bersama tidak menyalin hex, dan `utils/currency.dart` menampung satu-satunya `formatRupiah()` supaya format harga tidak disalin ke banyak file.
>
> `models/` berisi model murni + katalog statis, `providers/` berisi **seluruh** state aplikasi. Semua provider memakai pola yang sama seperti `AuthStore`: kelas statis dengan `ValueNotifier`, tidak ada package state-management baru, dan tidak ada data yang ditulis ke disk (§2, §11.21).

### 1.3 Konvensi penamaan isi dokumen

- **Nilai** selalu ditulis sebagai hex 8 digit ARGB: `0xFF7A263D`.
- **Nama token** = nama yang benar-benar ada di `lib/theme/app_colors.dart` (mis. `AppColors.maroon`). Sejak migrasi §16.3 selesai, kolom inilah yang dipakai — bukan lagi "usulan".
- **Nama lama** = nama variabel yang dulu ada di layar (mis. `kopi`, `vipRed`), dipertahankan hanya di §3 sebagai jejak asal-usul nilai.
- Layar **tidak boleh** menulis `Color(0x…)` langsung; semua warna lewat `AppColors` (§15).

---

## 2. Divergensi PRD vs UI

Tabel ini mencatat perbedaan antara PRD dan implementasi, **beserta keputusannya**. Semua keputusan: **UI menang**, kecuali ditandai lain.

| Aspek | PRD §8 | Implementasi nyata | Keputusan |
|---|---|---|---|
| Warna primer | `#C62828` | `#7A263D` (maroon) | **Pakai `#7A263D`** |
| Warna sekunder | `#FFF8E1` (krem) | Tidak dipakai sebagai warna dominan; `#F8DDE1` (pink pastel) untuk pill harga produk | **Pakai `#F8DDE1`** |
| Aksen pickup | Hijau `#4CAF50` | `#38B2AC` (mint) + dot `#64BDB6` | **Pakai mint** |
| Aksen delivery | Biru `#2196F3` | Tidak ada biru delivery; dot hijau `#75B879` | **Pakai `#75B879`** |
| Font | Poppins / Inter | Default Flutter (**Roboto**) | **Pakai Roboto**, tidak daftarkan font baru |
| Logo | Ikon hati bergaris | `Icon(Icons.favorite)` maroon + `assets/logo.png` | **Pakai `Icons.favorite`** |
| Tab aktif bottom nav | Merah | `#7A263D` + label bold | **Pakai `#7A263D`** |
| Platform | Android saja | Web (Chrome) jadi target verifikasi yang berjalan | Dicatat; jangan andalkan perilaku khusus Android |
| Warna tombol utama | — | `#B51F2D` (bukan maroon primer) | **Pertahankan `#B51F2D`** untuk tombol aksi |
| Susunan Beranda & Menu | Dua halaman | Dulu digabung dalam satu scroll | **Pakai dua halaman terpisah** (Beranda tetap menampilkan produk) |
| Kategori Menu | Daftar kategori | Tab teks + garis emas emas, semua section ditumpuk | **Pakai anchor scroll**, bukan filter |
| Splash | — | `assets/logo.png`, latar putih, 3 detik | **Pakai**; `assets/spark.logo.jpeg` tidak dipakai |
| Login & Daftar | Halaman tersendiri | Modal bottom sheet di atas Beranda; Daftar muncul di sheet yang sama, bukan route baru | **Pakai modal** (tampilan tidak diubah); logic-nya baru diisi (§11.10) |
| Penyimpanan akun | (tidak dibahas) | In-memory di `AuthService`, hilang saat aplikasi ditutup | **Pakai in-memory** — belum ada package/penyimpanan permanen |
| Seluruh state aplikasi | (tidak dibahas) | Keranjang, pesanan, poin, voucher, alamat, kotak masuk juga in-memory | **Pakai in-memory**; menutup aplikasi mengosongkan semuanya (§11.21) |
| Pencarian produk (PRD F17) | Ada | **Tidak dibuat** | **Dilewati** atas permintaan pemilik produk — jangan tambahkan ikon cari di Beranda/Menu |
| Login Google (PRD F2) | OAuth Google | Akun contoh in-memory (`AuthService.loginWithGoogle`) | **Simulasi**, tanpa SDK Google; tampilan tombol tetap sama |
| Banner Beranda | (tidak dibahas) | Satu gambar statis `assets/promo.png` | **Statis**, bukan carousel — jangan tambahkan indikator/dot (§11.2) |
| Bahasa (PRD F49) | Lokalisasi penuh | Hanya label bottom nav + beberapa teks global via `Strings` | **Sebagian**, dibatasi (`docs/design.md` §17) |
| Merch checkout | (tidak dibahas) | Merch bisa dibeli seperti produk (`+ Keranjang` di Detail Merchandise); Scan Merchandise hanya simulasi pemindaian | **Pakai alur keranjang yang sama**; scan menampilkan detail, bukan menukar poin |
| Header Profil | (tidak dibahas) | Mengikuti apps aslinya: band + avatar logo + "Edit Profil"; sapaan, level, dan poin jadi satu kartu tiga kolom; logout pindah ke section **Akun** | **Pakai tampilan apps asli** (§11.9) |

### 2.1 Catatan penting soal dua "merah"

Project ini secara konsisten memakai **dua merah** untuk dua peran berbeda. Ini sudah menjadi pola sadar, jangan diubah:

| Peran | Nilai | Digunakan untuk |
|---|---|---|
| **Brand / identitas** | `#7A263D` | Ikon nav aktif, judul, tab kategori aktif (teks), border terpilih, progress |
| **Aksi / CTA** | `#B51F2D` | Tombol "+ Keranjang", "Klaim", "Buy Pack", header VIP |

---

## 3. Color Tokens

### 3.1 Brand

| Nilai | `AppColors` | Nama lama | Pemakaian |
|---|---|---|---|
| `0xFF7A263D` | `maroon` | `kopi`, `detailKopi`, `kopiMerch` | Warna identitas utama — ikon nav aktif, judul, tab aktif, border terpilih, progress |
| `0xFFB51F2D` | `action` | `vipRed` | Tombol aksi utama (`+ Keranjang`, `Klaim`, `Buy Pack`, header VIP) |
| `0xFFF8DDE1` | `pink` | `pink` | Latar pill harga di kartu produk (§10.21) |

### 3.2 Merah semantik (peran khusus per layar)

| Nilai | `AppColors` | Nama lama | Dipakai di | Keterangan |
|---|---|---|---|---|
| `0xFFB3262D` | `red` | `profileRed` | Profil, umum | Teks pill harga, ikon hapus, ikon "Tentang Kopi Kangenan" |
| `0xFFB92429` | `checkoutRed` | `merah` | Checkout | Tombol Bayar, border voucher, chevron |
| `0xFFB82025` | `qrisRed` | `qrisRed` | QRIS | Total, countdown, ikon, reminder |

### 3.3 Emas / Gold

| Nilai | `AppColors` | Nama lama | Pemakaian |
|---|---|---|---|
| `0xFFB99565` | `gold` | `detailEmas` | Border opsi terpilih, garis bawah tab Menu, ikon minus/plus |
| `0xFFC6A577` | `goldBorder` | `emas` | Border kartu pembayaran terpilih, harga Menu |
| `0xFFD9B54A` | `goldProfile` | `profileGold` | Progress bar & chevron Profil |
| `0xFFC69A69` | `goldVipDot` | — | Dot indikator kartu membership VIP |
| `0xFFB89B65` | `goldVipIcon` | — | Ikon kartu benefit VIP |
| `0xFFB69A78` | `goldMerch` | — | Judul "Custom Merchandise" + divider Merch |
| `0xFFD2A36D` | `goldGift` | — | Ikon hadiah di kartu voucher Beranda |
| `0xFFA6783A` | `goldSubtitle` | — | Subjudul metode pembayaran di Checkout |
| `0xFFBE9B6D` | `goldQris` | — | Border tombol bawah QRIS |
| `0xFFC4A047` | `goldCoin` | — | Koin `KangenanCoin` di kartu header Profil & Daily Check-In; lingkaran koin di kartu membership |
| `0xFFB98050` | `goldVoucherBorder` | — | Border 2px kartu voucher Beranda |

### 3.4 Hijau

| Nilai | `AppColors` | Nama lama | Pemakaian |
|---|---|---|---|
| `0xFF218B55` | `green` | `profileGreen` | Tombol "Masuk", judul promo, badge "Baru" (Profil); badge `New` / `Promo Delivery` (§10.20) dan badge kartu promo (§10.24) |
| `0xFF278F59` | `greenVip` | `vipGreen` | Badge "Save 98%", harga paket voucher VIP |
| `0xFF20C96B` | `greenWhatsapp` | — | Ikon WhatsApp di dalam tombol "Ikuti Sekarang" (Profil) |
| `0xFF54A77D` | `greenIcon` | — | Bulatan ikon "Diskon & Cashback" (§10.24) |
| `0xFF75B879` | `greenDelivery` | — | Dot "Delivery" |
| `0xFF64BDB6` | `greenPickup` | — | Dot "Pickup" |
| `0xFF319795` | `greenStorefront` | — | Ikon storefront (latar `greenStoreBg`) |
| `0xFF38B2AC` | `mint` | `mint` | Ikon outlet terpilih (mint) |
| `0xFFEAF6EF` | `greenBadgeBg` | — | Latar badge "Gratis Ukir" |
| `0xFF65A486` | `greenBadgeText` | — | Teks badge "Gratis Ukir" |
| `0xFFEBF6F6` | `greenStoreBg` | — | Kotak ikon storefront |

### 3.5 Biru

| Nilai | `AppColors` | Nama lama | Pemakaian |
|---|---|---|---|
| `0xFF00A3C8` | `blueBlu` | `biru` | Brand blu by BCA Digital |
| `0xFF00AED6` | `blueGopay` | — | Brand GoPay |
| `0xFF3B82F6` | `blueLink` | — | Teks link "Lihat Semua" |
| `0xFFE0E7EE` | `blueGreyTab` | `vipBlueGrey` | Latar container tab VIP & toggle mode Pilih Outlet |
| `0xFFE4E5E8` | `blueTabBorder` | — | Border tab aktif VIP |

### 3.6 Warning / Amber

| Nilai | `AppColors` | Pemakaian |
|---|---|---|
| `0xFFF59E0B` | `warning` | Ikon warning / status Pending |
| `0xFFFFF8E7` | `warningBg` | Latar kotak ikon warning |

### 3.7 Teks (Netral)

| Nilai | `AppColors` | Nama lama | Pemakaian |
|---|---|---|---|
| `0xFF171717` | `textPrimary` | — | Judul & harga di halaman Merch |
| `0xFF252525` | `textQris` | `qrisText` | Teks utama QRIS |
| `0xFF303030` | `textVip` | `vipText` | Teks utama VIP |
| `0xFF38332B` | `textCountdown` | — | Teks kotak countdown QRIS |
| `0xFF555555` | `textVipHeader` | — | Judul header VIP |
| `0xFF55565B` | `textMembership` | — | Teks kartu membership |
| `0xFF66666B` | `textZero` | — | Angka "0" di kartu membership |
| `0xFF777777` | `textSecondary` | `abu` | **Teks sekunder standar** |
| `0xFF858585` | `textVipGrey` | `vipGrey` | Teks sekunder khusus VIP |
| `0xFF88888D` | `textTarget` | — | "/699.999" di kartu membership |
| `0xFF9E9E9E` | `textMuted` | — | Keterangan kustomisasi di kartu pesanan |
| `0xFFB8C0BD` | `textStrike` | — | Harga asli (strikethrough) |

> **Standar:** untuk teks sekunder di layar **baru**, pakai `textSecondary`. Jangan pakai `textVipGrey` / `textMuted` kecuali meniru layar yang sudah ada persis.

### 3.8 Permukaan / Background

| Nilai | `AppColors` | Pemakaian |
|---|---|---|
| `0xFFFFFFFF` | `Colors.white` *(bukan token)* | Kartu, bottom bar, panel, header — dipakai apa adanya |
| `0xFFFBFBFB` | `surfaceCheckout` | Scaffold `order_confirmation_screen` |
| `0xFFF8F9FA` | `surfaceQris` | Scaffold `qris_payment_screen` |
| `0xFFF7F7F7` | `surfaceProfile` | Scaffold `profile_screen` |
| `0xFFF1F4F8` | `surfaceVip` | Scaffold `vip_screen` |
| `0xFFF8F3EB` | `scaffoldBackground` | `MaterialApp.scaffoldBackgroundColor` (krem) |
| `0xFFE8E8E8` | `surfaceFrame` | Latar `MobileFrame` |
| `0xFFFAFAFA` | `surfaceOption` | Kotak opsi kustomisasi, kotak instruksi QRIS |
| `0xFFF8F8F8` | `surfaceOptionBorder` | Border opsi tidak terpilih (product_detail) |
| `0xFFF4F4F4` | `fieldFill` | Field input panel Login & Daftar |
| `0xFFF5F5F5` | `surfaceMuted` | Kotak jumlah voucher (Checkout) |
| `0xFFF2F2F2` | `surfaceMuted2` | Kotak jumlah voucher (VIP) |
| `0xFFF0F0F0` | `surfaceBand` | Band header Profil, border QRIS |
| `0xFFEAEAEA` | `surfaceTrack` | Latar progress bar membership, track progres bulat & garis pemisah kolom di kartu Profil |
| `0xFFE0E0E0` | `surfaceDisabled` | Latar baris *Out of Stock* |
| `0xFFFFC844` | `coinYellow` | Ikon koin di header Beranda |
| `0xFFFFE3E5` | `quickRed` | Quick menu "Order" |
| `0xFFFFE8C8` | `quickOrange` | Quick menu "Delivery Hemat" |
| `0xFFFFE1D5` | `quickPeach` | Quick menu "Chicken & Burger" |
| `0xFFE4F0D9` | `quickGreen` | Quick menu "Catering & Wedding" |
| `0xFFF8EFE4` | `countdownActiveBg` | Countdown QRIS (aktif) |
| `0xFFFFE8E8` | `countdownExpiredBg` | Countdown QRIS (kadaluarsa) |
| `0xFFEAF6EF` | `greenBadgeBg` | Latar badge "Gratis Ukir" |
| `0xFFEBF6F6` | `greenStoreBg` | Kotak ikon storefront |
| `0xFFC4C4C4` | `dotInactive` | Dot indikator VIP (non-aktif) |
| `0xFFBDBDBD` | `disabled` | Ikon/teks non-aktif |

### 3.9 Border & Garis

| Nilai | `AppColors` | Pemakaian |
|---|---|---|
| `0xFFEDEDED` | `border` | Border kartu checkout & metode pembayaran |
| `0xFFE5E5E5` | `borderSoft` | Garis atas bottom bar, border kotak jumlah, tombol "Klaim" |
| `0xFFE4E5E8` | `blueTabBorder` | Border tab aktif VIP |
| `0xFFE7E7E7` | `qrBorder` | Border kartu QRIS |
| `0xFFEEEEEE` | `instructionBorder` | Border kotak instruksi QRIS |
| `0xFFDDDDDD` | `borderBenefit` | Border kartu benefit VIP |
| `0xFFD9D9D9` | `outline` | Border tombol "Lanjutkan dengan Google" |
| `0xFFE1E1E6` | `navVipCircle` | Lingkaran tombol VIP di bottom nav |
| `0xFFC6C6C6` | `dashedLine` | Garis putus-putus kartu voucher VIP |
| `0xFFC4C4C4` | `dotInactive` | Dot indikator VIP (non-aktif) |
| `0xFFADB4BE` | `silverBorder` | Border kartu membership Silver |
| `0xFFB98050` | `goldVoucherBorder` | Border 2px kartu voucher Beranda |
| `0xFFF8F8F8` | `surfaceOptionBorder` | Border opsi tidak terpilih (product_detail) |
| `0x18000000` | `shadowSoft` | Bayangan tipis kartu voucher VIP |
| `Colors.black12` | *(bukan token)* | Border kartu outlet & Paket Hemat di Beranda |
| `Colors.grey.shade200` | *(bukan token)* | Garis atas bottom nav & bottom bar product_detail |
| `Colors.grey.shade300` | *(bukan token)* | Border kotak daily check-in (belum check-in) |
| `Colors.grey.shade400` | *(bukan token)* | Border kotak quantity di product_detail |

### 3.10 Membership

Kartu membership memakai **satu** gaya visual (Silver) apa pun level pemiliknya —
sesuai tampilan yang sudah ada. Yang berubah menurut level hanya **teks** di dalamnya
(nama level, poin, target), bukan gradien.

| Bagian | Nilai | `AppColors` |
|---|---|---|
| Gradient kartu (TL → BR) | `0xFFF9FBFF` → `0xFFD5DDE7` | `silverStart` → `silverEnd` |
| Border kartu 2px | `0xFFADB4BE` | `silverBorder` |
| Badge level | latar `0xFF55565B`, teks putih, radius 7 | `textMembership` |
| Aksen koin | `0xFFC4A047` (lingkaran + ikon hati putih) | `goldCoin` |
| Teks utama kartu | `0xFF55565B` | `textMembership` |

Level (dari `MemberStore`): Silver ≥ Rp0, Gold ≥ Rp700.000, Black ≥ Rp9.999.999.

### 3.11 Brand Pembayaran

| Metode | Nilai | `AppColors` | Tampilan |
|---|---|---|---|
| QRIS | — | — | Lingkaran putih + border `border`, ikon `Icons.qr_code_2` hitam |
| blu by BCA Digital | `0xFF00A3C8` | `blueBlu` | Lingkaran penuh, ikon putih |
| GoPay | `0xFF00AED6` | `blueGopay` | Lingkaran penuh, ikon putih |
| Kartu Debit/Kredit | — | — | Lingkaran netral, ikon kartu |

> Daftar di atas adalah **seluruh** metode pembayaran yang boleh tampil
> (`kPaymentMethods`). Jangan menambahkan merek lain (OVO, ShopeePay, dll.)
> karena belum ada warna brand resminya di §3 — itu melanggar Aturan emas #2.

---

## 4. Typography

**Font family:** Roboto (default Flutter). **Tidak ada** font kustom di `pubspec.yaml`. Jangan daftarkan Poppins/Inter tanpa persetujuan, karena akan mengubah seluruh tampilan.

### 4.1 Skala tipe (nilai nyata di kode)

| Token usulan | Size | Weight | Line-height / Letter-spacing | Dipakai di |
|---|---:|---|---|---|
| `displayPrice` | 30 | `w800` | ls `-0.7` | Total pembayaran QRIS |
| `displayScore` | 28 | normal | — | Angka poin di kartu membership + harga voucher VIP |
| `priceHero` | 27 | `w900` | — | Harga paket voucher VIP |
| `titleXXL` | 25 | `w800` / `w600` | italic (login) | "kopi kangenan" (login), "Merchandise" |
| `titleXL` | 24 | bold | — | *(tidak dipakai lagi — dulu judul "Menu" 24 maroon)* |
| `titleL` | 22 | `w800` | — | *(tidak dipakai lagi — dulu "Menu Kopi Kangenan")* |
| `titleL2` | 21 | `w800` | — | "Paket Hemat", nama produk di detail |
| `titleM` | 20 | `w800`/bold | — | "Diskon & Cashback", "Daily Check-In" |
| `titleM2` | 19 | bold / `w800` / `w700` | ls `-0.4` | Judul section detail, "Checkout", "Tersedia", header VIP |
| `titleS` | 18 | bold | — | "Hai, Guest", "0 pts" |
| `titleS2` | 17 | bold / `w700` | ls `-0.3` | Judul section profil, "Custom Merchandise", "Pembayaran Langsung" |
| `bodyL` | 16 | bold | ls `-0.3` | Judul "Beli Paket Voucher…", tombol Login |
| `bodyM` | 15 | bold / `w700` | — | "Pesan", "Pickup di Counter", "Hai, jibi", "Kopi Kangenan" |
| `body` | 14 | normal/bold | height `1.3`–`1.4` | Teks isi, tombol, harga merch |
| `bodyS` | 13 | `w600`/normal | — | Label opsi, "Melayani", harga menu, "Normal Ice" |
| `label` | 12 | `w600`/`w700`/`w800` | — | Label kecil, chip, badge, subjudul |
| `labelXS` | 11 | `w600`/`w700`/`w800` | ls `1` (khusus "SCAN UNTUK MEMBAYAR") | Badge, "Gratis Ukir", label bawah |
| `navLabel` | 10 | normal/bold | — | Label bottom nav, "Hari ke-N", badge "Save 98%" |
| `micro` | 9 | normal | — | Subjudul kartu metode pembayaran |

### 4.2 Bobot yang boleh dipakai

`FontWeight.normal`, `w500`, `w600`, `w700`, `w800`, `w900`, `bold` (= `w700`).

Gunakan `w800`/`w900` hanya untuk angka besar dan judul section, agar hierarki tetap terjaga.

### 4.3 Aturan

1. Judul section: **19–22** dengan `w800` atau `bold`.
2. Teks isi: **13–14**.
3. Label/badge: **10–12**.
4. Angka Rupiah besar: **27–30** dengan `w800`/`w900`.
5. Hindari `letterSpacing` kecuali untuk judul layar (`-0.3` s.d. `-0.7`) dan label kapital (`1`).

---

## 5. Spacing

Tidak ada skala formal di kode, **tetapi** nilai yang benar-benar dipakai berulang adalah:

**Skala yang terpakai:** `4, 5, 6, 7, 8, 10, 11, 12, 14, 15, 16, 18, 20, 22, 24, 26`

**Aturan padding halaman (pilih sesuai tipe layar, jangan campur):**

| Konteks | Padding | Dipakai di |
|---|---|---|
| Layar "konten" | `fromLTRB(20, …, 20, …)` | Beranda, Profil |
| Layar "form/checkout" | `fromLTRB(16, …, 16, …)` | Menu, Detail Produk, Checkout |
| Layar "padat" | `fromLTRB(14, …, 14, …)` | VIP |

**Jarak antar-section yang dipakai:** 16, 18, 20, 22, 24.

**Spacing horizontal dalam satu baris:** 6, 8, 10, 12, 14.

**Padding dalam kartu:** `all(10)`, `all(12)`, `all(14)`, `all(15)`, `all(16)`.

**Padding vertikal bottom bar:** `fromLTRB(16, 12, 16, 12)` sehingga tinggi tombol 48–52.

---

## 6. Border Radius

| Nilai | Nama token usulan | Pemakaian |
|---:|---|---|
| 6 | `r6` | Kotak ikon kecil (storefront) |
| 7 | `r7` | Badge level "0%" |
| 8 | `r8` | Tombol kecil, kotak countdown, tombol "Ikuti Sekarang", "Buy Pack", tombol keranjang |
| 9 | `r9` | Tab aktif VIP (di dalam container radius 15) |
| 10 | `r10` | Kartu multi-select, kotak jumlah VIP, tombol QRIS, kotak countdown |
| 12 | `r12` | Kartu voucher beranda, kotak opsi single-select, tombol Login, field input, reminder QRIS |
| 14 | `r14` | Kartu profil, kartu voucher/benefit VIP |
| 15 | `r15` | Quick menu beranda, kartu outlet, kartu Paket Hemat, container tab VIP |
| 16 | `r16` | Kartu checkout, kartu metode pembayaran |
| 18 | `r18` | Kartu QRIS |
| 20 | `r20` | Progress bar membership, badge "Save" |
| 22 | `r22` | Sudut bawah header beranda, panel VIP |
| 24 | `r24` | Sheet login (atas), tombol Google |
| 25 | `r25` | Kartu membership Silver |
| — | `circle` | Avatar, tombol VIP tengah, ikon brand pembayaran |

**Aturan:** tombol aksi utama memakai **8** (di dalam konten) atau **12** (form/checkout). Jangan pakai nilai lain untuk tombol.

---

## 7. Elevation & Shadow

Tidak ada satupun tempat yang memakai `elevation:` bawaan Material kecuali tombol "Bayar" (`elevation: 2`). Semua bayangan ditulis manual dengan `BoxShadow`.

**Pola resmi (5 pola):**

```dart
// A. Kartu standar (checkout, payment option)
BoxShadow(color: Colors.black.withValues(alpha: 0.025), blurRadius: 8, offset: Offset(0, 2))

// B. Kartu profil & header beranda
BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 3))

// C. Bottom bar (shadow ke atas)
BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: Offset(0, -4))

// D. Kartu QRIS (paling tebal)
BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: Offset(0, 5))

// E. Kartu voucher VIP (hard shadow, tanpa blur)
BoxShadow(color: Color(0x18000000), offset: Offset(0, 5), blurRadius: 0)
```

**Warna bayangan berwarna** (khusus border berwarna):

```dart
// Voucher alert checkout — bayangan mengikuti warna border
BoxShadow(color: merah.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))

// Tombol VIP tengah di bottom nav
BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6, offset: Offset(0, 2))
```

> Gunakan `.withValues(alpha: x)` — **bukan** `.withOpacity(x)` yang sudah deprecated.

---

## 8. Layout, Frame & Breakpoint

### 8.1 Batas lebar maksimum

Project memakai **3 nilai** `maxWidth` yang berbeda. Ini kondisi nyata kode; catat perannya agar tidak tertukar:

| Nilai | Dipakai di | Alasan |
|---:|---|---|
| **390** | Frame login, `MobileFrame`, halaman Merch, **semua halaman `AppPage`** | Meniru lebar iPhone/Android umum → **frame mobile standar** |
| **430** | Checkout, QRIS, VIP | Layar dengan konten lebih padat |
| **480** | Bottom navigation, Beranda+Menu, Profil | Frame "lebar" untuk desktop/web |

**Aturan untuk layar baru:** bungkus isinya dengan `AppPage` (§10.26) yang sudah memakai **390**. Pakai 480 hanya untuk tab yang punya bottom navigation. Gunakan 430 hanya kalau meniru salah satu dari 3 layar di atas.

### 8.2 Pola frame standar

Layar dengan bottom navigation (Beranda/Menu/VIP/Merch/Saya):

```
Scaffold(backgroundColor: Colors.white)
└─ SafeArea(bottom: false)
   └─ Column
      ├─ Expanded → konten
      └─ Center → ConstrainedBox(maxWidth: 480) → Container(height: 72)  ← bottom nav
```

Layar yang di-push (Detail Produk, Checkout, QRIS):

```
Scaffold
└─ SafeArea(bottom: false)          // atau SafeArea() untuk QRIS
   └─ Center
      └─ ConstrainedBox(maxWidth: 390 / 430)
         └─ Column
            ├─ Container  ← header dengan tombol back
            ├─ Expanded → ListView / CustomScrollView
            └─ Container  ← bottom bar (tombol aksi)
```

**Detail kunci:**
- `SafeArea(bottom: false)` dipakai di semua layar yang punya bottom bar sendiri; padding bawah dihitung manual: `12 + MediaQuery.of(context).padding.bottom` (pola di `order_confirmation_screen`).
- Bottom bar selalu `color: Colors.white` + `Border(top: BorderSide(...))`.
- Tinggi tombol utama: **48** (form/checkout) atau **52** (detail produk).

### 8.2.1 `AppPage` — pola default untuk layar baru

Semua layar yang **di-push** dari menu (keranjang, checkout, pesanan, profil, dsb.)
memakai satu widget bersama, `AppPage` (`lib/widgets/ui.dart`), yang membungkus
frame §8.2 di atas:

```dart
AppPage(
  title: 'Checkout',
  bottomBar: AppBottomBar(children: [...]),   // opsional
  children: [...],                            // otomatis dibungkus SingleChildScrollView
)
```

- `maxWidth: 390`, latar `surfaceProfile`, header `AppPageHeader` (tombol back + judul + `actions`).
- `bottomBar:` dan `scrollable:` **wajib ditulis sebelum** `children:` supaya lolos lint
  `sort_child_properties_last`.
- Tombol aksi tetap di bawah memakai `AppBottomBar` (garis atas `borderSoft` + bayangan tipis `shadowSoft`).

### 8.3 Tinggi elemen tetap

| Elemen | Tinggi |
|---|---:|
| Bottom navigation | 72 |
| Header Merch | 64 |
| Header VIP | 58 |
| Header QRIS | 56 |
| Tab kategori Menu (`CategoryTabs`) | 46 |
| Carousel "Promo & Combo" | 216 |
| Carousel Diskon & Cashback | 104 |
| Kartu promo Diskon & Cashback | 210 × auto |
| List "Paket Hemat" | 175 |
| List metode pembayaran | 142 |
| Kartu metode pembayaran | 124 × 150 |
| List Daily Check-In | 112 |
| Kartu daily check-in | 78 × (auto), margin kanan 7 |
| Header profil (beranda profil) | 220 |
| Banner QRIS image | 300 × 362 |

### 8.4 Grid

```dart
// Menu produk
SliverGrid-ish manual: itemWidth = (maxWidth - 12) / 2  // spacing 12
imageHeight = itemWidth * 0.9
// atau Wrap(spacing: 12, runSpacing: 16)

// Merch
GridView.builder(
  crossAxisCount: 2,
  crossAxisSpacing: 14,
  mainAxisSpacing: 24,
  childAspectRatio: 0.57,
)
```

---

## 9. Ikonografi

**Library:** Material Icons saja (`Icons.*`). Tidak ada paket ikon tambahan.

### 9.1 Ukuran yang dipakai

| Size | Pemakaian |
|---:|---|
| 10 | Dot status (Delivery/Pickup) |
| 12 | Ikon tag di pill harga (§10.21) |
| 16 | Ikon tag di bulatan "Diskon & Cashback" (§10.24) |
| 17 | Ikon countdown QRIS, ikon storefront |
| 18 | Ikon reminder QRIS |
| 19 | Ikon kecil di kartu membership |
| 20 | Ikon header beranda, ikon `schedule` tombol Jadwalkan |
| 21 | `assets/logo.png` di kartu pesanan, ikon WhatsApp |
| 23 | Ikon bottom nav, ikon chevron voucher alert, ikon close QRIS |
| 24 | Ikon daily check-in |
| 25 | Ikon outlet terpilih, ikon warning, `location_on` di kartu outlet (§10.18) |
| 26 | Ikon quick menu beranda |
| 27 | Ikon multi-select, ikon VIP tengah |
| 28 | Ikon "Diskon & Cashback" (di dalam bulatan 28×28), ikon voucher konter |
| 30 | Fallback `assets/logo.png` di kartu outlet Menu (§10.18) |
| 32 | `assets/logo.png` di kartu outlet Menu (§10.18), ikon kartu benefit VIP |
| 34 | Ikon avatar profil |
| 36 | Ikon hati di login |
| 38 | Fallback gambar Paket Hemat |
| 42 | Ikon hadiah kartu voucher beranda |
| 50 | Fallback gambar produk |
| 70 | Fallback gambar promo profil; ikon `AppEmptyState` (§10.27) |

### 9.2 Warna ikon

| Konteks | Warna |
|---|---|
| Ikon nav non-aktif | `Colors.grey` |
| Ikon nav aktif | `0xFF7A263D` |
| Ikon di dalam tombol berwarna | `Colors.white` |
| Ikon aksi (chevron, minus/plus) | emas — `0xFFB99565` / `0xFFD9B54A` |
| Ikon pending/warning | `0xFFF59E0B` |
| Ikon hati (brand) | `0xFF7A263D` atau `0xFFC4A047` (di kartu membership) |

### 9.3 Ikon brand penting

| Ikon | Peran |
|---|---|
| `Icons.favorite` / `Icons.favorite_border` | Logo Kopi Kangenan (hati) + tab VIP |
| `Icons.location_on` | Outlet |
| `Icons.qr_code_scanner` | Scan |
| `Icons.confirmation_number_outlined` | Voucher |
| `Icons.monetization_on` | Poin (masih dipakai di kartu outlet Beranda) |
| `KangenanCoin` (`lib/widgets/kangenan_coin.dart`) | Koin poin: kartu header Profil, Daily Check-In, `CheckInScreen` |
| `Icons.schedule` | Jadwalkan |
| `Icons.delivery_dining` | Delivery |
| `Icons.storefront` | Pickup |

---

## 10. Komponen

### 10.1 Kartu putih standar

```dart
// Varian profil
BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(14),
  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8, offset: const Offset(0, 3))],
)

// Varian checkout
BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: const Color(0xFFEDEDED)),
  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.025),
      blurRadius: 8, offset: const Offset(0, 2))],
)
```

> **Aturan wajib (`AppCard`):** kalau kartu putih ini memuat `ListTile` atau
> turunannya (`CheckboxListTile`, `SwitchListTile`, `RadioListTile`), tile itu
> harus berada di dalam `Material(type: MaterialType.transparency)`. Kalau tidak,
> Flutter melempar asersi *"ListTile background color or ink splashes may be
> invisible"* dan ripple-nya tidak kelihatan. `AppCard` (`lib/widgets/ui.dart`)
> sudah melakukan ini otomatis — jangan menyalin `Container` + `BoxDecoration`
> sendiri untuk kartu yang berisi tile.

### 10.2 Bottom Navigation (5 tab)

- Container: tinggi **72**, `Colors.white`, `Border(top: BorderSide(Colors.grey.shade200))`, `maxWidth: 480`.
- Item biasa: `Expanded` + `InkWell` + `Column` → `Icon(size: 23)` + `SizedBox(height: 3)` + `Text(fontSize: 10)`.
  - Aktif: `0xFF7A263D` + `FontWeight.bold`
  - Non-aktif: `Colors.grey` + normal
- Tab VIP (tengah): lingkaran **52×52**, `shape: BoxShape.circle`, `color: 0xFFE1E1E6`, border putih 3px, shadow `alpha 0.12 / blur 6 / (0,2)`, ditranslasi `Offset(0, -8)`; label ditranslasi `Offset(0, -6)`.

### 10.3 Tab kategori (Menu) — **menggantikan chip lama**

`CategoryTabs` (`lib/widgets/category_tabs.dart`).

- Wadah: `SizedBox(height: 46)`, `ListView` horizontal, `padding: horizontal 16`. Jarak antar tab **24**.
- Label: `fontSize: 15`; aktif `w800` + `0xFF171717`; non-aktif `w600` + `0xFF777777`.
- Garis bawah: tinggi **3**, `borderRadius: 2`; aktif `0xFFB99565` (emas), non-aktif transparan.
- Lebar garis bawah otomatis **selebar teks** (dibungkus `IntrinsicWidth`), bukan lebar tetap.
- Perubahan dari versi lama: pill `borderRadius: 24` dengan isian maroon **dihapus**. Sekarang tab berupa teks + garis emas, meniru aplikasi referensi.
- Tab di sini bersifat **anchor**: mengetuk tab menggulir ke section terkait, dan tab aktif ikut berpindah saat pengguna men-scroll (lihat §11.3).

### 10.4 Tab pill (VIP)

- Wadah: `padding: EdgeInsets.all(5)`, `color: 0xFFE0E7EE`, `borderRadius: 15`.
- Tab: tinggi **46**, aktif `Colors.white` + `borderRadius: 9` + `border: 0xFFE4E5E8`; non-aktif transparan.
- Label: `FittedBox(fit: BoxFit.scaleDown)` + `fontSize: 12` + `w700` + warna `0xFF303030`.

> **Dipakai ulang** oleh pemilih mode Pickup/Delivery di `outlet_picker_screen.dart`,
> hanya tingginya **44** dan jarak tabnya lebih rapat. Jangan bikin pola toggle kedua.

### 10.5 Tombol

| Varian | Konfigurasi |
|---|---|
| **Primer (form)** | `ElevatedButton`, tinggi 48, `backgroundColor: 0xFF7A263D`, radius 12, teks 16 bold putih |
| **Primer (aksi)** | `ElevatedButton`, tinggi 48–52, `backgroundColor: 0xFFB51F2D`, radius 8 atau 12, teks 14 bold putih |
| **Sekunder** | `OutlinedButton`, tinggi 48, `side: BorderSide(0xFFB92429)` (checkout) atau `0xFFBE9B6D` (QRIS), radius 10–12, teks 14 bold |
| **Ikon (IconButton)** | `padding: EdgeInsets.zero`, `constraints: BoxConstraints(minWidth: 32, minHeight: 40)` |
| **Teks** | `TextButton`, `minimumSize: Size.zero`, `tapTargetSize: MaterialTapTargetSize.shrinkWrap` |

> **Pakai `AppPrimaryButton`** (`lib/widgets/ui.dart`) untuk tombol aksi halaman
> baru: lebarnya penuh, tinggi **48**, radius **12** (form & checkout) atau **8**
> kalau tombolnya berada **di dalam konten**, bukan di bottom bar. Label otomatis
> `ellipsis`, jadi teks panjang tidak pernah overflow.

### 10.6 Kartu metode pembayaran

- Ukuran **124 × 150**, `padding: EdgeInsets.all(10)`, `borderRadius: 16`.
- Terpilih: `border: Border.all(color: 0xFFC6A577, width: 2)`; tidak: `0xFFEDEDED` width 1.
- Lingkaran brand **40×40** (warna brand, atau putih + border `0xFFEDEDED`).
- Judul: `SizedBox(height: 34)` + teks 12 bold, `maxLines: 2`.
- Subjudul: `SizedBox(height: 28)` + teks 9 `0xFF777777`, `maxLines: 2`.

### 10.7 Kartu voucher VIP

- `borderRadius: 14`, `border: Border.all(color: 0xFFC6C6C6, width: 1.3)`, shadow pola **E**.
- Bagian atas & bawah: `padding: EdgeInsets.all(12)`.
- Kotak jumlah: **58 × 68**, `color: 0xFFF2F2F2`, `borderRadius: 10`, angka `w800` `0xFFB51F2D` + ikon tiket 28.
- **Garis putus-putus:** `Row` berisi 35 `Expanded` dengan garis 1.2px berselang-seling (`index.isEven` → `0xFFC6C6C6`, ganjil → transparan). Ini pengganti efek "tiket".
- Harga: 27 `w900` `0xFF278F59`. Harga asli: 11 strikethrough `0xFFB8C0BD`. Badge hemat: bg `0xFF278F59`, radius 20, teks 10 `w700` putih.
- Tombol "Buy Pack": tinggi **43**, bg `0xFFB51F2D`, radius 8, teks 12 `w800`.

### 10.8 Kartu membership (Silver)

> **Isi kartu dinamis** (§11.7): nama level, sapaan, total belanja, target, dan persen
> progress dibaca dari `MemberStore` + `AuthStore`. **Gaya visualnya tetap Silver**
> untuk semua level — jangan membuat gradien Gold/Black baru.

- Tinggi: `(width * 0.78).clamp(255, 330)`.
- Padding: `width * 0.055`. Radius **25**, border `silverBorder` 2px.
- Gradient: `silverStart` → `silverEnd`, `topLeft` → `bottomRight`.
- Judul level: size `(width * 0.085).clamp(25, 34)`, `w900`, `textMembership`.
- Ilustrasi dekoratif diberi `Positioned(right: -width*0.02, top: cardHeight*0.15)` (ikon `workspace_premium`) + ikon hati putih di `right: width*0.09, top: cardHeight*0.30`.
- Progress bar: tinggi 10, radius 20, **border putih 2px**.
- Koin: lingkaran 29 `goldCoin` + ikon hati putih 19.
- Angka belanja memakai `formatAngka` (`350.000`), target disembunyikan saat level Black (§13.2).

### 10.9 Kartu promo beranda (Paket Hemat)

- Ukuran **150 × (parent height 175)**, `margin: EdgeInsets.only(right: 12)`, `padding: EdgeInsets.all(10)`.
- `borderRadius: 15`, `border: Border.all(color: Colors.black12)`, `color: Colors.white`.
- Isi: gambar (`BoxFit.contain` di dalam `Expanded`+`Center`) → `SizedBox(height: 5)` → judul bold → harga warna `0xFF7A263D`.
- Dibungkus `InkWell(borderRadius: 15)`.

### 10.10 Quick menu beranda

- `Expanded` di dalam `Row` + `Column`.
- Kotak ikon **52 × 52**, `borderRadius: 15`, warna latar per item, ikon warna `0xFF7A263D` size 26.
- Label: `SizedBox(height: 8)` + teks 11, `textAlign: center`.

### 10.11 Pilihan kustomisasi

**Single select** (`singleOptions`):
- Lebar dihitung merata: `(maxWidth - gap*(n-1)) / n`, `gap = 8`.
- Tinggi **82**, `padding: EdgeInsets.all(5)`, bg `0xFFFAFAFA`, radius 12.
- Terpilih: `border: 0xFFB99565` width 2, teks hitam. Tidak: `0xFFF8F8F8` width 1, teks `Colors.grey`.
- Teks 13 `w600`, `textAlign: center`.

**Multi select** (`multiOptions`):
- `padding: EdgeInsets.fromLTRB(16, 0, 16, 10)`, `constraints: BoxConstraints(minHeight: 62)`.
- Padding isi: `horizontal 12, vertical 10`, radius 10.
- Tersedia: bg `0xFFFAFAFA`. *Out of Stock*: bg `0xFFE0E0E0`, teks grey, `onTap: null`.
- Ikon hati `0xFF7A263D` 27 → teks 13 `w600` → label harga 11 grey → `Icons.check_box` / `check_box_outline_blank`.

### 10.12 Quantity selector

```dart
Container(
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey.shade400),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(mainAxisSize: MainAxisSize.min, children: [
    IconButton(onPressed: qty > 1 ? () => qty-- : null,
        icon: const Icon(Icons.remove, color: detailEmas)),
    Text('$qty', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
    IconButton(onPressed: () => qty++,
        icon: const Icon(Icons.add, color: detailEmas)),
  ]),
)
```

Minimum quantity: **1** (tombol minus di-disable saat `qty == 1`).

### 10.13 Badge

| Badge | Latar | Teks | Radius |
|---|---|---|---|
| "Baru" (profil) | `0xFF218B55` | putih 11 bold | 8, padding `h9 v4` |
| "Save 98%" | `0xFF278F59` | putih 10 `w700` | 20, padding `h6 v3` |
| "0%" (level) | `0xFF55565B` | putih 12 | 7, padding `h10 v5` |
| "Gratis Ukir" | `0xFFEAF6EF` | `0xFF65A486` 11 `w600` | 0 (kotak), padding `h7 v4` |
| "Out of Stock" | `0xFFE0E0E0` (baris) | grey 11 | — |
| `New` / `Promo Delivery` (produk) | `0xFF218B55` | putih 10 `w700` | **0 (kotak)**, padding `h8 v4` — lihat §10.20 |

### 10.14 Checkbox

```dart
Checkbox(value: v, activeColor: 0xFF7A263D, onChanged: ...)
```

Selalu dibungkus `InkWell` pada seluruh baris agar area tap besar.

### 10.15 Bottom Sheet (login)

- Lebar **390**, tinggi `MediaQuery.of(context).size.height * 0.75`.
- `borderRadius: BorderRadius.vertical(top: Radius.circular(24))`, `color: Colors.white`.
- Dipanggil dengan `showModalBottomSheet`: `isScrollControlled: true`, `useSafeArea: true`, `backgroundColor: Colors.transparent`, `barrierColor: Colors.black54`, `enableDrag: false`, `isDismissible: false`.
- Sejak pekerjaan Login/Daftar, kerangka di atas **hanya ada di satu tempat**: `AuthPanel` (`lib/widgets/auth_panel.dart`, §10.25), dan pembuka sheet-nya `showAuthSheet()` (`lib/screens/auth/auth_sheet.dart`). Halaman yang memanggil tidak boleh menulis ulang lebar/tinggi/radius-nya.

### 10.16 Field input

```dart
InputDecoration(
  filled: true,
  fillColor: AppColors.fieldFill,             // 0xFFF4F4F4 (login/daftar) — atau Colors.white untuk form baru
  prefixIcon: Icon(..., color: AppColors.textSecondary),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
)
```

Tinggi field efektif ~52. Jarak antar field: `SizedBox(height: 14)`.

Form **baru** memakai `AuthTextField` / `AuthPasswordField` (§10.25) supaya dekorasinya tidak disalin.

### 10.17 Progress bar (membership)

```dart
SizedBox(width: 120, child: LinearProgressIndicator(
  value: 0,
  color: profileGold,                        // 0xFFD9B54A
  backgroundColor: const Color(0xFFEAEAEA),
))
```
Label persentase: 11 grey di bawah bar.

### 10.18 Kartu outlet (`outlet_card.dart`)

Dipakai **bersama** oleh Beranda dan Menu supaya nama outlet dijamin sama.

- Container: `padding: EdgeInsets.all(12)`, `border: Border.all(Colors.black12)`, `borderRadius: 15`.
- Baris: ikon `location_on` maroon **25** → `SizedBox(width: 10)` → `Expanded` → (opsional) `SizedBox(width: 10)` + `trailing`.
- Kolom teks: nama outlet `bold` (`maxLines: 1`, `ellipsis`) → `SizedBox(height: 3)` → alamat `fontSize: 12`, `0xFF777777` (`maxLines: 1`, `ellipsis`).
- `trailing`:
  - Beranda → `keyboard_arrow_down` maroon + `SizedBox(width: 8)` + `qr_code_scanner` maroon.
  - Menu → `OutletLogoTile` = `assets/logo.png` **32×32**, `BoxFit.contain`.

### 10.19 Judul section (`section_header.dart`)

- `Text(fontSize: 18, fontWeight: FontWeight.w800, color: 0xFF171717)`.
- Padding default `fromLTRB(16, 0, 16, 12)` (Menu). Beranda memakai `fromLTRB(20, 0, 20, 14)`.

### 10.20 Badge promo (`PromoBadge`)

Badge yang menempel di sudut gambar produk. Dipakai untuk `New`, `Promo Delivery`, dan label promo lain.

- `padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4)`, latar `0xFF218B55`, **tanpa radius**.
- Teks putih, `fontSize: 10`, `w700`.
- Posisi: `Positioned(left: 0, bottom: 0)` di dalam `Stack` gambar.

### 10.21 Pill harga (`PricePill`)

- `padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4)`, latar `0xFFF8DDE1`, `borderRadius: 20`.
- Isi: `Icon(local_offer, size: 12, color: 0xFFB3262D)` → `SizedBox(width: 5)` → teks harga `fontSize: 12`, `w700`, `0xFFB3262D`.

### 10.22 Kartu produk grid (`ProductCardGrid`)

Dipakai untuk section berbentuk grid 2 kolom (`Baru!`, `Coffee`, `Non Coffee`, `Makanan`).

- `Column(crossAxisAlignment: start)` di dalam `InkWell`:
  1. `AspectRatio(1)` berisi `Stack`: gambar produk `BoxFit.contain` → badge `New` (`PromoBadge`) di `left: 0, bottom: 0` bila `isNew`.
  2. `SizedBox(height: 8)`.
  3. Nama produk `fontSize: 14`, `w700`, `0xFF171717`, `maxLines: 2`, `ellipsis`.
  4. `SizedBox(height: 6)`.
  5. Harga `fontSize: 14`, `w700`, `0xFF171717` — **teks biasa, bukan pill**.
- **Perubahan dari versi lama**: gambar tidak lagi dibungkus wadah pink `0xFFF8DDE1` radius 14 dengan `BoxFit.cover`. Sekarang gambar tampil polos di atas putih dengan `BoxFit.contain`, sehingga foto portrait 0.75 tidak terpotong.
- Tata letak grid: `Wrap` dengan `spacing: 14`, `runSpacing: 24`, lebar item `(maxWidth - 14) / 2`.

### 10.23 Kartu produk carousel (`ProductCardHorizontal`)

Dipakai untuk section horizontal (kategori `Promo & Combo`).

- `Container(width: 158, margin: EdgeInsets.only(right: 12))` di dalam `InkWell`.
- `Column(crossAxisAlignment: start)`:
  1. `SizedBox(height: 136)` berisi `Stack`: gambar `BoxFit.contain` → badge `promoLabel` di `left: 0, bottom: 0` (hanya bila `promoLabel` tidak kosong).
  2. `SizedBox(height: 8)`.
  3. Nama produk `fontSize: 14`, `w700`, `maxLines: 2`.
  4. `SizedBox(height: 6)`.
  5. `PricePill` (harga).
- Wadah carousel: `SizedBox(height: 216)` dengan `ListView` horizontal, `padding: EdgeInsets.only(left: 16)`.

### 10.24 Section Diskon & Cashback (`diskon_cashback_section.dart`)

Dipakai **di Beranda dan di Menu** — komponen yang sama, hanya insetnya berbeda.

- Judul: bulatan **28×28** `0xFF54A77D` berisi `Icon(local_offer, putih, 16)` → `SizedBox(width: 10)` → `Expanded(Text('Diskon & Cashback', fontSize: 20, w800, 0xFF171717, maxLines: 1, ellipsis))`.
- Wadah carousel: `SizedBox(height: 104)` dengan `ListView` horizontal.
- Parameter `horizontalPadding`: **16** (Menu), **20** (Beranda) — dipakai untuk padding judul dan padding kiri daftar.
- Kartu promo: lebar **210**, `margin: EdgeInsets.only(right: 12)`, putih, `borderRadius: 10`, `border: 0xFFEDEDED`.
  - Badge kiri atas: `padding: symmetric(horizontal: 9, vertical: 3)`, latar `0xFF218B55`, `borderRadius: only(topLeft: 9, bottomRight: 6)`, teks putih 10 `w700`.
  - `Column(mainAxisSize: min)` → badge → `Padding(10, 6, 10, 10)` → `Row`:
    - `Expanded` → `Column(mainAxisSize: min)`: nilai potongan `fontSize: 19`, `w800` → `SizedBox(height: 2)` → nama mitra `fontSize: 11`, `0xFF777777`.
    - `SizedBox(width: 6)` → `OutlinedButton('Klaim')`: tinggi **36**, `padding: horizontal 14`, `side: 0xFFE5E5E5`, `borderRadius: 6`, teks 13 `w600` `0xFF171717`.
- Isi promo saat ini:

| Badge | Nilai | Mitra |
|---|---|---|
| Diskon | `5.000` | OVO |
| Ongkir | `5.000` | GExpress |

- Menekan "Klaim" menampilkan `SnackBar('Promo <badge> berhasil diklaim!')`.

> **Penting:** tinggi kartu **tidak boleh** dipatok dengan `Expanded` di dalam `SizedBox` tetap. Versi pertama komponen ini memakai pola tersebut dan langsung overflow 4–20 px saat diuji dengan metrik font berbeda. Sekarang `mainAxisSize: MainAxisSize.min` dipakai supaya tinggi kartu selalu mengikuti isinya.

### 10.25 Panel auth bersama (`auth_panel.dart`)

Dipakai bersama oleh panel **Login** dan panel **Daftar** supaya keduanya tidak bisa berbeda tampilan. Isinya adalah bentuk panel Login yang sudah ada, dipindahkan apa adanya:

- `AuthPanel` — kerangka §10.15: `Align(Alignment.bottomCenter)` → `SizedBox(lebar 390, tinggi 75% layar)` → `Container` putih radius atas 24 → `SafeArea(top: false)` → `Column`: baris tombol X (`IconButton(Icons.close, AppColors.textSecondary)`, padding `16,8,8,0`, rata kanan) → `Expanded` → `SingleChildScrollView(padding: 24,0,24,24)`.
- `AuthBrandHeader(subtitle)` — `Icons.favorite` maroon **36** → `SizedBox(4)` → "kopi kangenan" **25** `w800` *italic* maroon → `SizedBox(8)` → subjudul **14** `0xFF777777`.
- `AuthTextField` / `AuthPasswordField` — dekorasi §10.16. `AuthPasswordField` menyimpan sendiri status lihat/sembunyikan (`visibility_off_outlined` ↔ `visibility_outlined`), jadi pemanggil tidak perlu ikut mengurusnya.
- `AuthPrimaryButton(label)` — tinggi **48**, radius **12**, `AppColors.maroon`, teks putih `bold` 16.
- `AuthOrDivider` — `Divider` + "atau" 12 `0xFF777777` (jarak horizontal 12).
- `AuthGoogleButton` — outlined tinggi **48**, `side: AppColors.outline`, radius **24**.
- `AuthSwitchText(question, action)` — 12; `question` `0xFF777777`, `action` maroon `bold`; dibungkus `Wrap(alignment: WrapAlignment.center)`.

> **Aturan:** perbedaan Login dan Daftar hanya **jumlah field** dan **teks tombolnya**. Ukuran, warna, dan jarak tidak boleh ditulis ulang di `login_screen.dart` / `register_screen.dart`.

### 10.26 `AppPage` — kerangka halaman dalam (`ui.dart`)

Semua halaman yang dibuka dari menu memakai `AppPage` supaya header, lebar, dan
bilah bawahnya identik.

| Bagian | Konfigurasi |
|---|---|
| Lebar | `maxWidth: 390`, `Center` |
| Latar | `AppColors.surfaceProfile` (`0xFFF7F7F7`) |
| `AppPageHeader` | tinggi **56**, putih; `IconButton(Icons.arrow_back, 24)` di kiri, judul 18 bold di tengah (`ellipsis`), slot `actions` di kanan |
| Isi | `SingleChildScrollView` (kecuali `scrollable: false`), padding default `16,16,16,24` |
| Bilah bawah | opsional lewat `bottomBar:` |

`AppBottomBar` — bilah tombol tetap: putih, `padding: 16,12,16,12+padding.bottom`,
`Border(top: borderSoft)` + bayangan `black alpha 0.04 / blur 12 / (0,-4)`.

### 10.27 Keadaan kosong (`AppEmptyState`)

Ikon **70** warna `borderSoft` → judul 17 bold → keterangan 13 `textSecondary`
(`height 1.5`) → (opsional) `AppPrimaryButton`. Dipakai di keranjang kosong,
riwayat kosong, kotak masuk kosong, dan hasil scan merch.

### 10.28 Sisa widget `ui.dart`

| Widget | Ringkas |
|---|---|
| `AppCard` | Kartu putih radius 16, border `border`, padding default 16; isinya dibungkus `Material(transparency)` (§10.1) |
| `AppPrimaryButton` | Tinggi **48**, lebar penuh, teks 15 bold putih ber-`ellipsis`, `background` bisa diganti, `radius` default 12 |
| `AppOutlineButton` | Tinggi **48**, `OutlinedButton.icon`, warna & border dari parameter (default `maroon`), radius 12 |
| `AppLabelValue` | Baris "label — nilai" untuk ringkasan/checkout; `bold: true` menaikkan ukuran ke 15 |
| `AppSectionLabel` | Judul kecil 15 bold `textPrimary`, padding `4,8,4,8` |
| `showAppMessage(context, msg)` | Satu-satunya cara menampilkan `SnackBar` di aplikasi |

### 10.29 Sheet bersama checkout (`checkout_sheets.dart`)

Dua sheet Checkout dipakai lewat fungsi, bukan `StatefulWidget` masing-masing:

| Fungsi | Isi |
|---|---|
| `showPickupConfirmSheet(context, outlet)` | Konfirmasi ganti outlet/mode ke Pickup |
| `showScheduleSheet(context, initial)` | Pilih tanggal + jam pengambilan, mengembalikan `DateTime?` |

Keduanya memakai radius atas 24 dan lebar maksimum 390, sama seperti §10.15.
Voucher **tidak** memakai sheet: kodenya diketik di field lalu divalidasi lewat
`VoucherStore.validateCode` (`_pakaiVoucher`), dan tukar poin memakai
`CheckboxListTile` di dalam `AppCard`.

---

## 11. Layout per Halaman

### 11.1 `main.dart` — Theme

```dart
MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Kopi Kangenan',
  theme: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,   // 0xFFF8F3EB
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.maroon),
  ),
  home: const SplashScreen(),
)
```

`SplashScreen` adalah layar pertama: latar putih, `assets/logo.png` **200×200** `BoxFit.contain` di tengah, lalu `pushReplacement` ke `LoginHomeScreen` setelah **3 detik**.

`MobileFrame` (`lib/widgets/mobile_frame.dart`): latar `surfaceFrame`, `SizedBox(390 × 844)` + `ClipRect`. **Tidak dipakai di alur aplikasi** — hanya tersedia untuk demo web (§14.3, §17).

### 11.2 Beranda (`home_screen.dart`)

Latar putih, `maxWidth: 480`, di dalam `SingleChildScrollView` milik tab 0 (§11.11).
Urutan dari atas:

1. **Header** (putih, radius bawah 22, shadow `alpha 0.1 / blur 8 / (0,3)`, padding `20,12,20,16`):
   - Baris 1: ikon hati grey 20 → "**{Level}  {progress}%**" (abu, bold) → `Spacer` → ikon `monetization_on` 20 `coinYellow` → "**{poin} pts**" bold → tombol keranjang
     - Level, persen, dan poin dibaca dari `MemberStore` lewat `ValueListenableBuilder`, jadi ikut berubah setelah check-in / belanja (§11.21). Sebelumnya angka ini `0%` / `0 pts` yang dipatok.
   - **Tombol keranjang** (`_cartButton`): `Icons.shopping_bag_outlined` 22 maroon + badge merah berisi `CartStore.totalQuantity` bila > 0; mengetuknya membuka `CartScreen`.
   - Kartu outlet: `OutletCard` (§10.18) dari `OutletStore.selected` — **bisa diketuk** → `OutletPickerScreen` (§11.16). Nama outlet tidak lagi dipatok `kDefaultOutlet`.
   - Baris "Melayani": teks 13 abu + dot `greenDelivery` + "Delivery" + dot `greenPickup` + "Pickup"
2. **Banner promo**: `Image.asset('assets/banner_promo.png')`, `BoxFit.fitWidth`, margin top 8 — **satu gambar statis, bukan carousel** (tidak ada `PageView`, tidak ada dot indikator; jangan ditambahkan).
3. **Menu pintas** (`_QuickMenu`, padding `12,14,12,12`) — keempatnya **berfungsi**:
   | Label | Ikon | Latar | Aksi |
   |---|---|---|---|
   | Order | `shopping_bag` | `quickRed` | pindah ke tab Menu |
   | Delivery Hemat | `delivery_dining` | `quickOrange` | set mode Delivery + buka `OutletPickerScreen` |
   | Chicken & Burger | `lunch_dining` | `quickPeach` | pindah ke tab Menu |
   | Catering & Wedding | `card_giftcard` | `quickGreen` | buka `BulkOrderScreen` |
4. **Kartu voucher Buy 1 Get 1** (PRD F10): border `goldVoucherBorder` 2px, radius 12, padding 10, ikon hadiah 42 `goldGift`, tombol "Klaim" bg `action`.
   - Setelah diklaim: label berubah **"Diklaim"**, tombolnya mati, dan muncul `SnackBar('Voucher Buy 1 Get 1 berhasil diklaim!')`. Status disimpan `VoucherStore.hasClaimedBuyOneGetOne`, jadi tidak bisa diklaim dua kali.
5. **"Paket Hemat"**: judul 21 `w800` padding `horizontal 22`, list horizontal tinggi 175, padding kiri 20.
6. **"Diskon & Cashback"**: `DiskonCashbackSection(horizontalPadding: 20)` (§10.24) — komponen yang sama dengan Menu; tombol "Klaim" menampilkan `SnackBar('Promo <badge> berhasil diklaim!')` dan mengingat labelnya di `VoucherStore.claimedPromos`.
7. **"Spesial Hari Ini"**: `SectionHeader` + carousel `ProductCardHorizontal` berisi `productsByCategory('Promo & Combo')` — ditambahkan supaya produk promo yang tadinya hanya ada di Menu juga tampil di Beranda.
8. **"Baru!"**: `SectionHeader` (padding `20,0,20,14`) + `ProductCardGrid` 2 kolom dari `productsByCategory('Baru!')`.
9. **"Makanan"**: `SectionHeader` (padding `20,0,20,14`) + `ProductCardGrid` 2 kolom dari `productsByCategory('Makanan')`.

Menu **bukan lagi** bagian dari scroll Beranda — lihat §11.11.

> **Pencarian produk (PRD F17) tidak dibuat** — jangan menambahkan ikon cari (§2).
>
> Tidak ada teks "Beranda" di dalam halaman ini (label itu hanya ada di bottom nav), supaya `layout_test.dart` tetap bisa membedakan tab.

### 11.3 Menu (`menu_screen.dart`) — **dibangun ulang mengikuti aplikasi referensi**

Latar putih, `SafeArea(bottom: false)`, `Center` + `ConstrainedBox(maxWidth: 480)`, lalu `Column`:

1. **Kartu outlet (tetap, tidak ikut scroll)**: padding `16,12,16,10` → `OutletCard` (§10.18) dengan `kDefaultOutlet` dan `trailing: OutletLogoTile()` (`assets/logo.png` 32×32).
   Nama outlet di sini dijamin sama dengan Beranda karena keduanya membaca `kDefaultOutlet` yang sama.
2. **`CategoryTabs`** (§10.3): `Promo & Combo`, `Baru!`, `Coffee`, `Non Coffee`, `Makanan`.
   Hanya kategori yang punya produk di `kProductCatalog` yang ditampilkan (label `Makanan` **tidak** diganti jadi "Food").
3. **`Divider(height: 1, thickness: 1, color: 0xFFEDEDED)`** — batas tetap dengan area scroll.
4. **`Expanded` → `SingleChildScrollView`** (padding bawah 24) berisi:
   - `SizedBox(height: 16)`
   - `DiskonCashbackSection()` (`horizontalPadding` default 16, §10.24)
   - `SizedBox(height: 24)`
   - Untuk setiap kategori: `SectionHeader` + isi + `SizedBox(height: 28)`
     - `Promo & Combo` → carousel, `SizedBox(height: 216)` + `ListView` horizontal, kartu `ProductCardHorizontal`
     - `Baru!`, `Coffee`, `Non Coffee`, `Makanan` → `Padding(horizontal 16)` + grid `ProductCardGrid` 2 kolom (`Wrap`, spacing 14 / runSpacing 24)

Semua harga & gambar berasal dari `kProductCatalog` (§11.12), bukan angka hardcode.

**Yang dihapus dari versi lama:**
- Judul "Menu" 24 bold maroon di dalam halaman.
- Pill chip kategori (§10.3 versi lama).
- Wadah gambar pink `0xFFF8DDE1` radius 14 dengan `BoxFit.cover` (diganti gambar polos `BoxFit.contain`, §10.22).
- Judul "Menu Kopi Kangenan" yang disisipkan oleh `main_navigation_screen.dart`.

**Tab sebagai anchor (scroll-spy):**
- Setiap `SectionHeader` diberi `GlobalKey` lewat map `_sectionKeys`.
- `ScrollController.addListener` mencari section **terakhir** yang header-nya sudah melewati tepi atas area scroll (`viewportTop + 8`) — `viewportTop` dihitung dari `GlobalKey` pada `SingleChildScrollView`, sehingga tidak bergantung tinggi layar.
- Mengetuk tab memanggil `Scrollable.ensureVisible(..., alignment: 0, duration: 350 ms, curve: easeInOut)`.
- Selama animasi itu, listener diabaikan lewat flag `_jumpLock`, supaya tab yang baru diketuk tidak langsung ditimpa hasil perhitungan scroll.
  Flag ini juga yang menjaga tab terakhir tetap benar pada kasus konten bawah tidak cukup panjang untuk mencapai tepi atas.

### 11.4 Detail Produk (`product_detail_screen.dart`)

- `maxWidth: 390` (kalau layar > 480), latar putih.
- **Header gambar**: `AspectRatio(1)` + `BoxFit.contain`; tombol back & share sebagai `CircleAvatar(backgroundColor: Colors.white)` di `top: 12, left/right: 12`.
- **Nama + harga**: padding `16,14,16,8`, `Row` berisi nama (21 bold hitam, `Expanded`) dan harga (`formatRupiah(basePrice)`, 20 bold hitam, rata kanan).
- **Deskripsi**: dari `product['description']`, padding `16,0,16,16`, teks 13 `line-height 1.5` `textSecondary`. Tidak dirender kalau deskripsinya kosong. Number format tetap `formatRupiah()` — jangan menulis pemisah ribuan sendiri.
- **Opsi minuman hanya untuk kategori minuman.** Section di bawah hanya dirender kalau `showDrinkOptions` bernilai `true`:
  - `showDrinkOptions = widget.drinkOptions ?? (product['is_drink'] != 'false')`. Layar katalog (Beranda, Menu, Paket Hemat) boleh mengandalkan `product['is_drink']`; layar yang membangun map sendiri (tombol "Ganti" di Keranjang & Checkout) **wajib** mengirim `drinkOptions` eksplisit.
  - Kategori minuman = `kDrinkCategories` di `lib/models/product.dart` (`Promo & Combo`, `Baru!`, `Coffee`, `Non Coffee`). `Product.isDrink` memakai daftar itu. **`Makanan` bukan kategori minuman.**
  - Saat `showDrinkOptions` `false`, `_simpan()` menyimpan `size/milk/sugar/ice` sebagai string **kosong** dan daftar topping/syrup kosong. Jangan menyimpan `'Standar'` atau `'-'`: itu yang dulu memunculkan baris `Standar · · · ·` di keranjang.
- `Divider(thickness: 4)`.
- Section **single select**: Temperature, Size, Milk Option, Sugar Level, Ice Level.
  - Judul section: padding `16,20,16,12`, teks 19 bold + subjudul 12 grey ("Select 1").
- `Divider(thickness: 5, height: 32)`.
- Section **multi select**: Topping, Syrup. Subjudul seragam: `'Optional · May select multiple'` (bahasa Inggris).
- **Catatan Tambahan** (PRD F21): `TextFormField` maksimal **100** karakter, placeholder abu, ikut tersimpan ke `CartItem.note`.
- `SizedBox(height: 20)`.
- **Bottom bar**: putih, border atas `Colors.grey.shade200`, padding `16,12,16,12` → quantity selector (radius 8) → `SizedBox(width: 12)` → tombol `+ Keranjang Rp…` tinggi 52 bg `appAction` radius 8.

**Mode ubah (dari tombol "Ganti" di keranjang):**
- Layar menerima `initial: CartItem?` dan `editIndex: int?`. Kalau keduanya terisi, semua pilihan, jumlah, dan catatan **diisi ulang** saat `initState` (`widget.initial`).
- Label tombol berubah dari `+ Keranjang Rp…` menjadi **"Simpan Perubahan"**, dan menyimpan memanggil `CartStore.replaceAt(editIndex, item)` — bukan menambah item baru.
- Tanpa mode ubah, menyimpan memanggil `CartStore.add(item)` lalu halaman ditutup.

### 11.5 Checkout (`order_confirmation_screen.dart`)

- Judul header: **"Checkout"** (bukan "Konfirmasi Pesanan"), 19 bold, `letterSpacing: -0.4`, dengan tombol back + `SizedBox(width: 32)` penyeimbang.
- `maxWidth: 430`, latar `surfaceCheckout`.
- Isi `ListView` padding `16,4,16,24`, urutan: `_outletCard` → `16` → `_paymentSection` → `16` → `_orderCard` → `16` → `_shoppingBagCard` → `16` → `_voucherCard` → `16` → `_pointsCard` → `16` → `_summaryCard` → `20` → `_voucherPackageCard`.
- **Sumber data: keranjang.** Subtotal = `CartStore.totalPrice`; `_orderCard` menampilkan setiap `CartItem` dengan tombol **Ganti** (buka ulang Detail Produk dalam mode ubah, §11.4) dan **Hapus**.
  - Baris kustomisasi hanya dirender kalau `item.customizationLines` **tidak kosong** (`customizationLines` sudah menyaring string kosong dan placeholder `'-'`), jadi item makanan/merchandise tidak menampilkan baris `Standar · · · ·`.
  - Tombol **Ganti** disembunyikan untuk merchandise (`!_isMerch(item)`). Merchandise tidak punya opsi kustomisasi, jadi hanya jumlahnya yang bisa diubah. Item makanan tetap punya "Ganti".
  - "Ganti" selalu mengirim `drinkOptions: item.hasDrinkOptions` supaya halaman detail tahu opsi mana yang perlu ditampilkan (§11.4).
- **Kantung belanja** (`_shoppingBagCard`): `CheckboxListTile` (+`bagFee = Rp200`).
- **Voucher** (`_voucherCard`): field kode + tombol "Pakai", divalidasi `VoucherStore.validateCode`; pesan gagal muncul di bawah field, bukan di `SnackBar`.
- **Poin** (`_pointsCard`): `CheckboxListTile` untuk menukar poin (1 poin = Rp1, maksimal sebanyak sisa pembayaran).
- **Ringkasan** (`_summaryCard`): subtotal, kantung, diskon voucher, potongan poin, total.
- **Bottom bar**: `OutlinedButton.icon` "Jadwalkan" (ikon `schedule` 20, border `checkoutRed`, tinggi 48 radius 12) + `SizedBox(width: 12)` + `ElevatedButton` "Bayar - Rp…" (bg `checkoutRed`, radius 12, elevation 2).
  - "Jadwalkan" membuka `showScheduleSheet` (§10.29) dan menampilkan tanggal terpilih di kartu outlet.
  - "Bayar" **tidak** membuat pesanan: kalau metode terpilih `qris` ia membuka `QrisPaymentScreen` dengan `onPaid: _selesaikanPesananKeBeranda`; kalau bukan, ia langsung memanggil `_selesaikanPesanan`.
- **Pembuatan pesanan dipusatkan di `_buatPesanan()`** (mengembalikan `Order`): memanggil `SyncService.createOrder` (server) atau `OrderStore.create` (lokal) lalu `CartStore.clear()`. Dua pembungkusnya:
  - `_selesaikanPesanan()` → `_buatPesanan()` lalu `pushReplacement` ke `OrderStatusScreen`. Dipakai metode pembayaran **non-QRIS**.
  - `_selesaikanPesananKeBeranda()` → `_buatPesanan()` lalu `popUntil(isFirst)`. Dipakai tombol **"Kembali Ke Beranda"** di QRIS.
- Kalau keranjang kosong, isi diganti `AppEmptyState` (§10.27) "Keranjangmu masih kosong" dan bottom bar disembunyikan.

### 11.6 QRIS (`qris_payment_screen.dart`)

- `maxWidth: 430`, latar `surfaceQris`, isi `Container(color: Colors.white)`.
- Header tinggi **56**: `Icons.close` 23 (kiri) + judul 17 `w700` `textQris` (tengah) + `SizedBox(width: 48)`.
- Konten (scroll) padding `20,22,20,20`:
  1. "Total pembayaran" 14 `textSecondary`
  2. Nominal 30 `w800` `qrisRed`, ls `-0.7`
  3. Kotak countdown radius 8, bg `countdownActiveBg` (aktif) / `countdownExpiredBg` (habis), ikon `access_time` 17, teks 12 `textCountdown`, timer 13 `w800` merah
  4. Kartu QRIS radius 18, border `qrBorder`, shadow **D**, padding 16:
     - `Icons.qr_code_2` 20 + "SCAN UNTUK MEMBAYAR" 11 `w800` ls 1
     - `SizedBox(height: 16)`
     - QR: `assets/qris_kopi.jpeg` **300 × 362**, `BoxFit.contain`, radius 12, opacity 0.35 saat kadaluarsa
     - "Kopi Kangenan" 15 `w700` + catatan 12 `textSecondary`
  5. Kotak reminder radius 12, bg merah (atau `textSecondary` saat habis), teks putih 12 `w600`
  6. Kotak instruksi radius 12, bg `surfaceOption`, border `instructionBorder`, padding 15, ikon `info_outline` 20 merah, judul 13 `w700`, isi 12 `line-height 1.5`
- **Bottom bar** (padding `20,14,20,16`, satu tombol selebar penuh): `OutlinedButton` tinggi 48, border `goldQris` 1.5px, radius 10, label **"Kembali Ke Beranda"**.
  - Menekan tombol memanggil `widget.onPaid` (Checkout membuat pesanan lebih dulu), lalu Checkout menjalankan `popUntil(isFirst)` sehingga pembeli mendarat di Beranda.
  - Tanpa `onPaid`, tombolnya hanya menutup halaman.
  - Label **tidak** berubah saat countdown habis (dulu berganti jadi `'Kembali'`; ternary dua-cabang itu sudah dihapus).
  - Tombol **X** di header tetap `Navigator.pop(context)` → kembali ke Checkout **tanpa** membuat pesanan, supaya metode pembayaran masih bisa diganti.
  - Halaman **Status Pesanan** tidak lagi dibuka dari QRIS, tetapi tetap dipakai metode pembayaran non-QRIS (§11.5).
- `onPaid` adalah `VoidCallback?` yang diberikan Checkout (§11.5). Halaman ini **tidak** tahu soal `OrderStore` — pemisahan ini yang membuat QRIS bisa dibuka dari mana pun.
- Logika: countdown **10 menit**, `Timer.periodic` 1 detik, di-`cancel` di `dispose()`.
  - **Catatan untuk tes:** timer ini membuat `pumpAndSettle()` tidak pernah selesai selama halaman QRIS terpasang. Di widget test, pakai `pump(Duration)` bertahap lalu pastikan halaman sudah dibuang (§11.21).

### 11.7 VIP (`vip_screen.dart`)

- Latar `surfaceVip`, `maxWidth: 430` (bukan 480 — perhatikan bedanya dari tab lain).
- Header tinggi **58**, judul "Kopi Kangenan VIP" 19 `w700` `textVipHeader`.
- Konten padding `14,12,14,24`:
  1. **Kartu membership** (§10.8) — sekarang **dinamis**, dibungkus `ValueListenableBuilder` atas `MemberStore.totalSpent` **dan** `AuthStore.currentUser`:
     - badge level = `MemberStore.level.label` (`SILVER`/`GOLD`/`BLACK`),
     - sapaan `Hai, ${AuthStore.displayName}` (mengikuti sesi login),
     - angka belanja `formatAngka(totalSpent)` / target `formatAngka(level.nextThreshold)`,
     - persen progress `(MemberStore.levelProgress * 100).round()`,
     - baris ajakan memakai `MemberStore.remainingToNextLevel` — kalau sudah Black, teksnya "…kamu di level tertinggi!".
     - Nilai awal apa pun **tidak** dipatok; sebelumnya kartu ini selalu Silver dengan `0 / 699.999`.
     - Nilai target disembunyikan (kosong) saat level sudah Black (`isHighest`).
  2. Indikator: 4 dot, aktif lebar 30 warna `goldVipDot`, non-aktif lebar 8 warna `dotInactive`, tinggi 7 radius 10, margin horizontal 4
  3. Panel putih radius **22**, padding `12,16,12,22`:
     - Tab pill (Voucher / Voucher Pack / Benefits) — default `selectedTab = 1` (**Voucher Pack**)
     - `SizedBox(height: 22)`
     - Judul 19 `w800` — "Tersedia" (tab 0 & 1) atau "Benefits Member" (tab 2)
     - `SizedBox(height: 16)`
     - Konten sesuai tab:

**Tab Voucher** — daftar `VoucherStore.userVouchers`:
- Ada field kode + tombol **"Pakai"** → `VoucherStore.validateCode` (kode salah → `SnackBar` pesan dari `VoucherException`).
- Setiap voucher punya tombol "Pakai"; menekannya menampilkan `SnackBar` berisi **kode** yang harus dimasukkan di halaman Checkout ("Masukkan kode ini di halaman Checkout → "Pakai Kode Voucher".") — sesuai alur Checkout §11.5.
- Kalau belum ada voucher → `AppEmptyState` "Belum ada voucher. Klaim promo di Beranda atau beli paket voucher.".

**Tab Voucher Pack** — daftar `kVoucherPacks`:
- Setiap paket punya tombol **"Buy Pack"**; kalau paket sudah dimiliki labelnya berubah **"Beli Lagi"**.
- Menekan tombol memanggil `VoucherStore.buyPack(pack)` → voucher paket langsung masuk `userVouchers` (3 voucher per paket: 10%, 15%, dan B1G1), dan `ownedPacks` bertambah.

**Tab Benefits** — dibungkus `ValueListenableBuilder` atas `MemberStore.totalSpent`:
- Kartu pertama menyebut level saat ini dan berapa lagi yang perlu dibelanjakan (`formatRupiah(remainingToNextLevel)`), atau "Kamu sudah di level tertinggi dan mendapat semua benefit.".
- Kartu-kartu berikutnya menjelaskan benefit; gaya kartu = `AppColors.borderBenefit` (§3.9).

### 11.8 Merch (`merch_screen.dart`)

- Latar putih, `maxWidth: 390`.
- Header tinggi **64**, "Merchandise" 25 `w600` `textPrimary`, dengan ikon scan di kanan → `ScanMerchScreen`.
- Banner `assets/merch/promo.tumbler.png` full width `BoxFit.fitWidth`, margin bottom 24.
- Judul section "Custom Merchandise" 17 `w700` `goldMerch`, padding `horizontal 16`.
- Divider dekoratif: `SizedBox(width: 180)` + `Divider(thickness: 4, color: goldMerch)`, lalu `SizedBox(height: 22)`.
- Grid 2 kolom (lihat §8.4), datanya `kMerchCatalog` (`models/merch.dart`). Setiap item: gambar `BoxFit.contain` (di `Expanded`) → `SizedBox(height: 8)` → badge "Gratis Ukir" → `SizedBox(height: 7)` → nama 14 `w700` → `SizedBox(height: 6)` → harga 14 `w700`.
- Mengetuk item membuka `MerchDetailScreen` (§11.18).

### 11.9 Profil (`profile_screen.dart`)

- Latar `0xFFF7F7F7`, `maxWidth: 480`.
- **Header** memakai alur biasa (`Column`), **bukan** tinggi tetap + `Positioned`:
  - Band atas `SizedBox(height: 90)` + `Stack` berisi `Container(color: 0xFFF0F0F0)` (polos, tanpa pola), avatar, dan aksi kanan.
  - Avatar di `top: 8, left: 20`: lingkaran putih **74 × 74**, border 3 px `goldProfile`, isinya `assets/logo.png` (`ClipOval`, `BoxFit.contain`, `errorBuilder` → `Icons.local_cafe`).
  - Aksi kanan atas, tegak di tengah tinggi band (`right: 20`):
    - Belum masuk → tombol "Masuk" bg `0xFF218B55` yang membuka `showAuthSheet()` (§11.10).
    - Sudah masuk → `TextButton.icon` **"Edit Profil"** (`Icons.edit_outlined`) menuju `DataDiriScreen`.
      - Dulu tombol inilah yang berganti menjadi "Keluar"; sekarang logout pindah ke item **"Keluar"** di section **Akun** (lihat bawah).
  - **Kartu sapaan + level + poin** tepat di bawah band (margin kiri/kanan 20, padding `16,12,16,12`, radius 14) — satu `Row` tiga kolom yang dipisah garis vertikal 1 px (`surfaceTrack`, tinggi 34):
    1. `Hai,` 11 `textSecondary` + nama 16 bold (`maxLines: 1` + `ellipsis` supaya nama panjang tidak menabrak kolom sebelahnya)
    2. `Level` 11 `textSecondary` + `CircularProgressIndicator` 14 px (`strokeWidth` 2.5, warna `goldProfile`, track `surfaceTrack`) + `{Silver/Gold/Black}` 12 `w600` + `{0–100}%` 11
    3. `Kangenan Points` 11 `textSecondary` + `KangenanCoin` 15 px + `{poin} pts` 15 bold
    - Semuanya dari `MemberStore` lewat `ValueListenableBuilder`, jadi ikut berubah setelah check-in/belanja. Menekan kartunya membuka `PointsHistoryScreen`.
  - Tinggi header **mengikuti isi** kartunya. Ini disengaja: sebelumnya header dipatok `SizedBox(height: 220)` dengan kartu di `top: 100`, sehingga kartu berakhir tepat di batas 220 px dan kartu promo (margin atas 0) ikut menempel tanpa jarak. Sekarang jarak itu dijaga tes tata letak (`layout_test.dart`).
- **Promo Spesial**: `Padding` `20,16,20,18` — **jarak atas 16 px** ke kartu level/poin di atasnya (dipasang lewat `Padding`, bukan `margin`, supaya batas kartunya terukur oleh tes tata letak) — padding 16, judul `✨ Promo Spesial Buat Kamu!` 17 bold `green`, deskripsi 13 `line-height 1.4`, gambar `assets/images.png` tinggi 140, tombol `ElevatedButton.icon` "Ikuti Sekarang" tinggi 46 radius 8 bg `greenWhatsapp` dengan ikon **di dalam tombol** (menampilkan `SnackBar` ajakan mengikuti WhatsApp — simulasi).
  - Baris "WhatsApp Channel" sudah dihapus; ikonnya pindah ke tombol. Material Icons tidak punya glyph WhatsApp dan proyek ini tidak menambah package, jadi ikonnya memakai `Icons.chat`.
- **Daily Check-In**: margin `20,0,20,20`, padding 15, judul 20 bold + `TextButton` "Detail" (→ `CheckInScreen`), subjudul "Berakhir 31 Okt 2026" 14 grey, list horizontal tinggi 112 berisi **6** kartu 78px (`MemberStore.maxCheckInDays`).
  - Kartu hari yang sudah check-in atau berikutnya memakai border `goldProfile` 2px; sisanya `Colors.grey.shade300` 1px.
  - Ikon kartu: hari biasa `KangenanCoin` 24 px (`goldCoin`; abu-abu kalau belum berjalan), hari selesai `Icons.check_circle`, hari hadiah voucher `Icons.confirmation_num_outlined`.
  - Baris judul memakai `Expanded` untuk judulnya. Tanpa itu, judul 20px + tombol "Detail" overflow 72 px saat diuji dengan metrik font yang lebih lebar (§14.4).
- **Section menu** (`_section`): margin `20,0,20,16`, padding `16,14,16,4`, judul section 17 bold, kartu radius 14. **Semua item sudah membuka halaman** (tidak ada lagi yang cuma `SnackBar`):
  - **Akun**: Data Diri → `DataDiriScreen`, Alamat Pengiriman → `AddressScreen`, Scan Merchandise → `ScanMerchScreen`, Aktifkan Biometric ID (sakelar `SettingsStore.biometric`), Ubah Bahasa Aplikasi → `LanguageScreen`, **Keluar** (`Icons.logout`, warna `red`) → `AuthStore.logout()` + `SnackBar('Anda telah keluar.')`.
    - Item "Keluar" hanya muncul saat sudah masuk, dibungkus `ValueListenableBuilder` di atas `AuthStore.currentUser` (tamu mendapat `SizedBox.shrink()`).
  - **Pesan**: Kotak Masuk → `InboxScreen` (+badge jumlah belum dibaca dari `InboxStore.unreadCount`), Riwayat Pesanan → `OrderHistoryScreen`, Metode Pembayaran → `PaymentMethodsScreen`, Pesanan Jumlah Besar → `BulkOrderScreen` (+badge "Baru")
  - **Kopi Kangenan**: Bantuan, Kebijakan Privasi, Ketentuan Layanan, Lapor Masalah, Layanan WhatsApp, dan Tentang Kopi Kangenan → semuanya halaman statis (§11.20), dibangun di atas `StaticPageScreen`.
- Kartu sapaan + level + poin membaca `MemberStore`, dan kartunya membuka `PointsHistoryScreen`. Persen progress memakai `MemberStore.levelProgress` (bukan angka statis).
  - Baris "Belanja Rp… lagi untuk naik ke Level …" **sudah tidak ada** di kartu header (mengikuti apps aslinya). Info itu tetap lengkap di halaman VIP (§11.12).
- **Footer**: "Kopi Kangenan • Versi 1.0.0" 12 grey, padding `bottom 24, top 2`

> **PENTING (bug yang pernah terjadi):** item section memakai `ListTile` di dalam `Container` berwarna. Ini memicu assertion *"ListTile background color or ink splashes may be invisible"* — sudah diperbaiki dengan membungkus `ListTile` dalam `Material(type: MaterialType.transparency)`. **Wajib diikuti untuk item list baru di dalam kartu berwarna.**

### 11.10 Login & Daftar (`auth_sheet.dart`, `login_screen.dart`, `register_screen.dart`)

Ketiganya satu kesatuan. `showAuthSheet()` menampilkan **satu** bottom sheet, dan isinya berpindah antara `LoginScreen` ↔ `RegisterScreen` **tanpa membuka route baru** — kalau memakai `push`, latarnya akan teredup dua kali dan desainnya berubah.

**Kerangka panel** — `AuthPanel` (§10.25): lebar 390, tinggi 75% layar, putih, radius atas 24, padding konten `24,0,24,24`, tombol X di kanan atas. Menerima parameter `onClose` (tutup sheet → masuk sebagai tamu), `onSuccess(AuthUser)`, dan `onRegister` / `onLogin` untuk pindah mode.

- Isi **Login**: `AuthBrandHeader('Masuk untuk melanjutkan')` → `26` → field "Email atau Nomor HP" → `14` → field "Password" (toggle visibility) → `20` → tombol **Login** (48, maroon, radius 12) → `20` → divider "atau" → `18` → tombol "Lanjutkan dengan Google" (outlined, border `AppColors.outline`, radius 24) → `18` → "Belum punya akun? **Daftar di sini**".
- Isi **Daftar**: `AuthBrandHeader('Daftar untuk mulai memesan')` → `26` → "Nama Lengkap" → `14` → "Email atau Nomor HP" → `14` → "Password (minimal 6 karakter)" → `14` → "Ulangi Password" → `20` → tombol **Daftar** (gaya sama dengan Login) → `18` → "Sudah punya akun? **Masuk di sini**".

**Logic**
- Validasi dan penyimpanan akun ada di `AuthService`; sesi login ada di `AuthStore` (§11.14).
- Gagal validasi / password salah / akun tidak ada → `SnackBar` berisi pesan dari `AuthException` (**bukan** `errorText` inline), dan panel **tetap terbuka** supaya bisa diperbaiki.
- Berhasil masuk atau daftar → **sheet ditutup**, lalu `SnackBar('Berhasil masuk. Selamat datang, [Nama]!')`. Tidak ada lagi `pushReplacement(MainNavigationScreen)` yang dulu menumpuk shell aplikasi kedua di atas yang pertama.
- Akun demo: **`demo@kangenan.com` / `123456`** (nama `Demo`), supaya login bisa dicoba tanpa mendaftar dulu.
- Tombol **"Lanjutkan dengan Google"** sekarang **berfungsi** sebagai simulasi: `AuthStore.loginWithGoogle()` membuat/memakai akun contoh `pengguna.google@gmail.com` (nama "Pengguna Google") di `AuthService`, lalu menutup sheet lewat `onSuccess` yang sama — `SnackBar('Berhasil masuk. Selamat datang, Pengguna Google!')`. Tidak ada SDK Google di proyek ini (§2).
- Sesi hanya di memori: menutup aplikasi membuat pengguna kembali menjadi tamu. Karena itu masuk sebagai tamu **tetap** jalur yang sah (menutup sheet dengan X).

### 11.11 Bottom Navigation (`main_navigation_screen.dart`)

- `Scaffold(backgroundColor: Colors.white)` → `SafeArea(bottom: false)` → `Column`
  - `Expanded`: halaman sesuai `selectedIndex`, dipilih oleh `_page()`
    - `0` → `SingleChildScrollView` → `Center` → `ConstrainedBox(480)` → `HomeScreen`
    - `1` → `MenuScreen` (**halaman sendiri**, tidak lagi menempel di bawah Beranda)
    - `2` → `VipScreen`
    - `3` → `MerchScreen`
    - `4` → `ProfileScreen`
  - `Center` → `ConstrainedBox(480)` → `Container(height: 72)` bottom nav
- **Scroll-linked tab dihapus.** Dulu ada `ScrollController` + `_menuKey` + `_updateActiveTab()` yang memindahkan tab 0 → 1 otomatis saat pengguna men-scroll melewati judul "Menu Kopi Kangenan" (`menuTop <= screenHeight * 0.45`). Karena Beranda dan Menu sekarang halaman terpisah, semuanya dihapus, termasuk `_goToMenu()` dan judul "Menu Kopi Kangenan" yang dirender shell.
- Setiap tab sekarang **punya area scroll sendiri**; `_select(index)` hanya melakukan `setState`.
- **Label tab mengikuti bahasa** (`SettingsStore.language` → `Strings.beranda/menu/vip/merch/saya`). Untuk tab yang namanya sama di kedua bahasa tetap "Menu"/"VIP"/"Merch". Kalau tidak ada permintaan lain, **label default tetap Indonesia** dan urutannya tidak berubah (§17).
- `HomeScreen` menerima `onSelectTab` supaya menu pintas "Order"/"Chicken & Burger" bisa memindahkan tab tanpa perlu `GlobalKey` (§11.2).
- Bottom navigation sendiri **tidak berubah** sedikit pun (lihat §10.2).

### 11.12 Katalog produk bersama (`models/product.dart`)

`kProductCatalog` dipakai **bersama** oleh Beranda dan Menu; `productsByCategory(nama)` menyaringnya.
Satu produk boleh muncul di beberapa kategori, sama seperti katalog aslinya.

| Kategori | Produk | Harga | Gambar |
|---|---|---:|---|
| Promo & Combo | PaHe 1 | 19.000 | `assets/pahe1.png` |
| Promo & Combo | PaHe 2 — badge `Promo Delivery` | 27.000 | `assets/pahe2.png` |
| Promo & Combo | PaHe 3 | 29.000 | `assets/pahe3.png` |
| Baru! | Taro Cloud Matcha — badge `New` | 28.000 | `assets/Taro cloud matcha.png` |
| Baru! | Taro Milk — badge `New` | 25.000 | `assets/taro milk.png` |
| Baru! | Taro Cloud Latte — badge `New` | 28.000 | `assets/taro cloud latte.png` |
| Baru! | Taro Cloud Milk Tea — badge `New` | 25.000 | `assets/taro cloud milktea.png` |
| Coffee | Taro Cloud Latte | 28.000 | `assets/taro cloud latte.png` |
| Non Coffee | Taro Cloud Matcha | 28.000 | `assets/Taro cloud matcha.png` |
| Non Coffee | Taro Milk | 25.000 | `assets/taro milk.png` |
| Non Coffee | Taro Cloud Milk Tea | 25.000 | `assets/taro cloud milktea.png` |
| Makanan | Triple Cheese Bagel | 22.000 | `assets/triple cheeze bagel.png` |
| Makanan | Beef and Cheese Jalapeno Bagel | 28.000 | `assets/beef and cheese jalapeno bagel.png` |
| Makanan | Double Choco Bagel | 22.000 | `assets/double choco bagel.png` |

- Harga asli proyek ini dipakai apa adanya — **bukan** angka dari tangkapan layar referensi.
- Harga disimpan sebagai `int` lalu ditampilkan lewat `Product.priceLabel` → `formatRupiah()` (§13.2).
- `Product.toProductMap()` mengembalikan `Map<String, String>` dengan kunci `name` / `price` / `image` / `description` — **struktur yang sama** dengan yang dulu di-hardcode di `menu_screen.dart`, sehingga `ProductDetailScreen` tidak perlu diubah sama sekali.
- Badge `Promo Delivery` sengaja hanya di PaHe 2, meniru kartu yang ditandai pada aplikasi referensi.

### 11.13 Splash (`splash_screen.dart`)

- `Scaffold(backgroundColor: Colors.white)` → `Center` → `Image.asset('assets/logo.png', width: 200, height: 200, fit: BoxFit.contain)`.
- `errorBuilder` menyediakan fallback `Icon(Icons.favorite, size: 120, color: 0xFF7A263D)` bila aset gagal dimuat.
- `initState` → `Future.delayed(Duration(seconds: 3))` → `Navigator.pushReplacement` ke `LoginHomeScreen`.
- Sebelumnya layar ini memakai `assets/spark.logo.jpeg` dengan `BoxFit.cover`, dan tidak terhubung ke alur mana pun.

### 11.14 Auth: akun & sesi (`services/auth_service.dart`, `providers/auth_store.dart`)

Logic dipisah dari widget supaya bisa diuji tanpa me-render layar, dan supaya bisa diganti menjadi panggilan API nanti tanpa menyentuh UI.

**`AuthService`** — validasi + penyimpanan akun. Semuanya `static`, disimpan di `Map<String, _Account>` **di memori saja**: semua akun hilang saat aplikasi ditutup, dan tidak ada package baru yang ditambahkan.

| Method | Aturan |
|---|---|
| `validateName` | tidak boleh kosong, minimal **3** karakter |
| `validateIdentifier` | email (`nama@domain.titik`) atau nomor HP **9–15** digit setelah spasi/`-` dibersihkan; boleh diawali `+` |
| `validatePassword` | minimal **6** karakter (`minimumPasswordLength`) |
| `login` | identifier harus valid → password diisi → akun terdaftar → password cocok |
| `register` | nama → identifier → password → konfirmasi harus sama → identifier belum terdaftar |

- Kunci akun = identifier yang sudah di-`trim` dan di-lowercase, jadi email tidak peka huruf besar/kecil.
- Pesan gagal memakai `AuthException.message` yang sudah berbahasa Indonesia dan siap ditampilkan di `SnackBar`.
- Akun demo disemai langsung: `demoIdentifier` / `demoPassword` = **`demo@kangenan.com` / `123456`** (nama `Demo`).
- `registeredAccountCount` dan `reset()` bertanda `@visibleForTesting` dan hanya dipakai `test/auth_test.dart`.

**`AuthStore`** (`providers/auth_store.dart`) — sesi login, tanpa UI. `currentUser` adalah `ValueNotifier<AuthUser?>`, pola yang sama dengan `CartStore`, jadi halaman lain cukup memakai `ValueListenableBuilder` untuk ikut berubah. Menyediakan `isLoggedIn`, `displayName` (`'Guest'` saat tamu), `login`, `register`, `loginWithGoogle`, dan `logout`. Kelas ini juga me-`export` `AuthUser` dan `AuthException`, sehingga layar tidak perlu mengimpor `services/` sendiri.

### 11.15 Keranjang (`cart_screen.dart`)

- `AppPage(title: 'Keranjang')`, latar `surfaceProfile`.
- Kalau kosong: `AppEmptyState` — ikon `shopping_bag_outlined` 70, judul **"Keranjangmu masih kosong"**, tombol **"Mulai Pesan"** (`Navigator.maybePop`).
- Kalau terisi:
  - **Strip outlet** (`_outletStrip`): `AppCard` berisi ikon `location_on` maroon, "Ambil di", nama outlet dari `OutletStore.selected`, mode (`Pickup`/`Delivery`), chevron. Mengetuknya membuka `OutletPickerScreen` (§11.16).
  - **Kartu item** untuk setiap `CartItem`: nama, ringkasan kustomisasi (`size` · `milk` · `sugar` · `ice` · topping · syrup), catatan (bila ada), harga `formatRupiah(item.unitPrice)`, quantity stepper (`-` / jumlah / `+`), lalu tombol **"Ganti"** dan **"Hapus"**.
    - `Ganti` → `ProductDetailScreen(product:…, initial: item, editIndex: index)` (§11.4).
    - `Hapus` → `CartStore.removeAt(index)`.
  - Kotak peringatan `warningBg` + `info_outline` `warning` di bawah daftar (informasi ketersediaan outlet).
- **Bottom bar** (`AppBottomBar`): kolom kiri "Subtotal" 12 `textSecondary` + total 17 bold; kanan `AppPrimaryButton` selebar **170** berlabel **"Checkout (n)"** (`CartStore.totalQuantity`) → `OrderConfirmationScreen`.
- Item yang diubah/dihapus langsung tercermin karena seluruh halaman dibungkus `ValueListenableBuilder` atas `CartStore.items`.

### 11.16 Pilih Outlet (`outlet_picker_screen.dart`)

- `AppPage(title: 'Pilih Outlet')`.
- **Pemilih mode** memakai tab pill §10.4: container `blueGreyTab` radius 15, dua tab tinggi **44**, tab aktif putih radius 9 + border `blueTabBorder`, label 12 `w700` di `FittedBox(scaleDown)`. Mengetuk tab memanggil `OutletStore.setMode` (tidak menutup halaman).
- **Mode Delivery** menampilkan `AppCard` alamat di atas daftar: "Kirim ke {label}" + detail alamat (2 baris, `ellipsis`) + chevron → `AddressScreen`. Kalau belum ada alamat: "Belum ada alamat".
- **Daftar outlet** dari `kOutlets`: setiap baris `AppCard` (border `maroon` bila terpilih, `borderSoft` bila tidak) berisi nama, alamat, dan indikator pilihan.
  - Mengetuk baris memanggil `OutletStore.select(outlet)` lalu **`Navigator.maybePop`** — halaman ini selalu ditutup setelah memilih.
- Nama outlet di Beranda, Menu, Keranjang, dan Checkout semuanya membaca `OutletStore.selected`, jadi tidak mungkin berbeda.

### 11.17 Pesanan (`order_status_screen.dart`, `order_history_screen.dart`)

**Status Pesanan** — `AppPage(title: 'Status Pesanan')`, menerima `orderId` (bukan objek `Order`) supaya selalu membaca data terbaru dari `OrderStore`:
- `AppEmptyState` "Pesanan tidak ditemukan" bila id tidak ada.
- Kartu status: ikon + label (`Menunggu` / `Diproses` / `Siap Diambil` / `Selesai` / `Dibatalkan`).
- Kartu langkah: 4 langkah `pending → processing → ready → completed`, dengan penanda selesai/aktif.
- Kartu item + kartu ringkasan (`AppLabelValue`: subtotal, kantung, voucher, poin, total, pembayaran, tipe, jadwal).
- `AppOutlineButton` **"Hubungi Outlet"** → `SnackBar` info.
- `AppOutlineButton` **"Batalkan Pesanan"** (warna `red`) selama status belum final → `OrderStore.cancel`.
- **Bottom bar** (hanya bila belum final): `AppPrimaryButton` **"Perbarui Status Pesanan"**, atau **"Pesanan Sudah Saya Ambil"** saat status `ready`. Keduanya memanggil `OrderStore.advance`, lalu `SnackBar` status baru.
- `OrderStore.advance` tidak melakukan apa-apa pada status final, dan `cancel` hanya berlaku untuk pesanan yang belum final (§11.21).

**Riwayat Pesanan** — `AppPage(title: 'Riwayat Pesanan')`:
- Chip filter per `OrderStatus` (termasuk "Semua").
- Daftar kartu pesanan: id, tanggal, status, jumlah item, total (`formatRupiah`), tombol menuju Status Pesanan.
- Kosong → `AppEmptyState` dengan ajakan memesan.
- Pesanan contoh `#1001` (status selesai) disemai sekali oleh `OrderStore` supaya halaman ini tidak kosong saat pertama dibuka. Nomor pesanan baru mulai dari **`#1002`**.

### 11.18 Merch: detail & scan (`merch_detail_screen.dart`, `scan_merch_screen.dart`)

**Detail Merchandise** — `AppPage(title: 'Detail Merchandise', padding: zero)`:
- Gambar `AspectRatio(1)` `BoxFit.contain` di atas putih → nama 21 bold → harga `formatRupiah` → deskripsi.
- **Bottom bar**: `AppPrimaryButton` **"Tambah ke Keranjang"** (ikon `shopping_bag_outlined`) → `CartStore.add(CartItem(...))`, `SnackBar`, lalu membuka `CartScreen`.

**Scan Merchandise** — `AppPage(title: 'Scan Merchandise')`:
- Kotak hitam 220px "kamera", ikon `qr_code_scanner` 58, teks "Arahkan kamera ke QR di produk".
- Tombol **"Mulai Scan"** → status `_scanning` 1,2 detik (`CircularProgressIndicator`) → memilih satu `Merch` dari `kMerchCatalog` secara acak → "QR berhasil dipindai".
- Hasil: kartu berisi gambar 56, nama, harga, deskripsi, dan tombol **"Lihat Detail Merchandise"** → `MerchDetailScreen`.
- **Simulasi** — tidak ada akses kamera dan tidak ada package QR; jangan menambahkan `mobile_scanner` tanpa persetujuan.

### 11.19 Metode pembayaran & paket voucher

**Metode Pembayaran** — `AppPage` dengan judul **"Pilih Pembayaran"** saat dibuka dari Checkout (`selectMode: true`) atau **"Metode Pembayaran"** saat dibuka dari Profil. Bukan `ListTile`, tetapi baris khusus di dalam `AppCard`:
- Setiap metode = `AppCard` (padding `14,12`) berisi lingkaran 40 (`brandColor` atau putih + border `border`), ikon 22, nama 14 bold, subjudul 11 `textSecondary`, lalu di kanan salah satu dari: tombol **"Hubungkan"** (`blueLink`) untuk metode yang belum terhubung, `check_circle` `maroon` bila terpilih, atau `radio_button_unchecked` `borderSoft`.
- Metode yang butuh koneksi (GoPay) harus dihubungkan dulu; mengetuk baris yang belum terhubung hanya menampilkan pesan, tidak memilih (`PaymentStore.select` menolak).
- Mode pilih: memilih metode menutup halaman (`maybePop`). Mode pengaturan: tetap di halaman dan menampilkan `SnackBar` "Metode utama: …".
- Daftar **hanya** `kPaymentMethods`: QRIS, blu by BCA Digital, GoPay, Kartu Debit/Kredit (§3.11). Merek lain **tidak boleh** ditambahkan.
- Default `qris`. Pilihan dibaca Checkout dan disimpan ke `Order.paymentMethod`.

**Paket Voucher** (`voucher_pack_screen.dart`) — `AppPage(title: 'Paket Voucher')`:
- Detail paket: judul, daftar isi, harga asli dicoret (`textStrike`), harga (`greenVip`), badge hemat, tombol **"Buy Pack"**.
- `VoucherStore.buyPack(pack)` menambahkan paket ke `ownedPacks` dan voucher-voucher paket ke `userVouchers` (`vouchersFromPack`).

### 11.20 Halaman Profil tambahan

Semua memakai `AppPage` (§10.26) dan hanya membaca/menulis store in-memory.

| Halaman | Isi & aturan |
|---|---|
| `DataDiriScreen` | Nama, email/nomor HP, tanggal lahir; menyimpan ke `AuthStore`/`AuthService` (akun yang sedang login). Tombol **"Simpan"** di bottom bar. |
| `AddressScreen` | Daftar `AddressStore.addresses`; tambah/ubah lewat form, jadikan utama (`setDefault`), hapus. Alamat pertama berlabel **"Rumah"** dan menjadi utama. |
| `InboxScreen` | Daftar `InboxStore.messages`; pesan belum dibaca punya penanda. Mengetuk pesan memanggil `markRead`. Tombol "Tandai Semua Dibaca". |
| `PointsHistoryScreen` | Riwayat `MemberStore.history` (`PointEntry`: judul, tanggal, `+/-` poin) + saldo poin di atas. |
| `CheckInScreen` | 6 kartu hari (`MemberStore.dailyRewards`), status hari ini, tombol **"Check-In Hari Ini"**, total hadiah 100 poin + 2 voucher. |
| `LanguageScreen` | `RadioListTile` Indonesia / English → `SettingsStore.language`; label bottom nav ikut berubah (§17). |
| `NotificationSettingsScreen` | Dua `SwitchListTile` (promo & pesanan) di dalam `AppCard` → `SettingsStore`. |
| `BulkOrderScreen` | Form pesanan jumlah besar (nama, instansi, jumlah porsi, tanggal, catatan) + `AppPrimaryButton` kirim → `SnackBar`. |
| `StaticPageScreen` | Kerangka satu halaman statis dari daftar `StaticSection` (judul + isi), sehingga teks tidak diduplikasi. Dipakai oleh `HelpScreen`, `PrivacyPolicyScreen`, `TermsScreen`, `ReportProblemScreen`, `WhatsappServiceScreen`, dan `AboutScreen`. |

> **Aturan `ListTile`:** semua `ListTile`/`CheckboxListTile`/`SwitchListTile`/`RadioListTile` di halaman-halaman ini berada di dalam `AppCard`, yang sudah menyediakan `Material(transparency)` (§10.1). Jangan mengganti `AppCard` dengan `Container` berwarna tanpa `Material`.

### 11.21 State in-memory & aturan pengujian

**Pola store.** Semua state memakai pola yang sama, tanpa package baru:

```dart
class XStore {
  XStore._();
  static final ValueNotifier<T> value = ValueNotifier<T>(initial);
  static void reset() { ... }   // dipakai test
}
```

| Store | Isi | Dipakai di |
|---|---|---|
| `AuthStore` | sesi login | Profil, VIP, semua form |
| `CartStore` | `List<CartItem>` | Beranda (badge), Keranjang, Checkout |
| `OutletStore` | outlet & mode terpilih | Beranda, Menu, Keranjang, Checkout |
| `AddressStore` | alamat | Pilih Outlet (Delivery), Checkout, Alamat |
| `MemberStore` | poin, level, check-in, riwayat poin | Beranda, Profil, VIP, Checkout |
| `VoucherStore` | voucher akun, promo diklaim, paket dibeli | Beranda, VIP, Checkout |
| `OrderStore` | pesanan + status | Checkout, Status, Riwayat |
| `InboxStore` | pesan | Profil (badge), Kotak Masuk |
| `PaymentStore` | metode terpilih & yang terhubung | Checkout, Metode Pembayaran |
| `SettingsStore` | bahasa, notifikasi, biometric | Bottom nav, Pengaturan Notifikasi, Bahasa |

**Tidak ada persistensi.** Menutup aplikasi mengosongkan semuanya, termasuk akun dan sesi login (§2).

**Aturan tes** (`flutter test`):
1. Ukuran layar default tes adalah **800 × 600** — selalu set `tester.view.physicalSize = Size(390, 844)` + `devicePixelRatio = 1` untuk menguji tata letak ponsel.
2. `QrisPaymentScreen` punya `Timer.periodic` 1 detik → **jangan** `pumpAndSettle()` selama halaman itu terpasang. Pakai `pump()` + `pump(Duration)` sampai halaman dibuang.
3. Font tes membuat setiap glif selebar 1em, jadi label panjang bisa overflow hanya di tes. Layar dengan label panjang (VIP) tidak diuji; jangan menambah teks panjang ke layar yang sudah diuji.
4. Setelah `SnackBar` muncul, tunggu **5 detik** (`pump` + `pumpAndSettle`) sebelum mengetuk bottom nav, karena SnackBar menutupinya.
5. `test/store_test.dart` menguji semua store; `test/flow_test.dart` menguji alur keranjang → checkout → QRIS → Beranda, opsi minuman vs makanan, item merchandise di keranjang, Profil, Pilih Outlet, dan Daily Check-In. Jalankan reset store di `setUp` supaya tes tidak saling memengaruhi.

---

## 12. Navigasi

### 12.1 Peta rute aktual

```
main()
└─ KopkenApp → home: SplashScreen              (latar putih, logo.png, 3 detik)
   └─ pushReplacement → LoginHomeScreen
      ├─ MainNavigationScreen                  (bottom nav, 5 tab)
      │  ├─ tab 0 → HomeScreen                 (punya scroll sendiri)
      │  ├─ tab 1 → MenuScreen                 (punya scroll sendiri)
      │  ├─ tab 2 → VipScreen
      │  ├─ tab 3 → MerchScreen
      │  └─ tab 4 → ProfileScreen
      └─ showAuthSheet() → LoginScreen ⇄ RegisterScreen   (satu sheet yang sama)
```

Semua layar lain **di-push** dengan `MaterialPageRoute`:

| Dari | Ke |
|---|---|
| HomeScreen | `OutletPickerScreen`, `ScanMerchScreen`, `CartScreen` (ikon keranjang), `BulkOrderScreen` (Catering & Wedding), `ProductDetailScreen` |
| MenuScreen | `ProductDetailScreen`, `OutletPickerScreen` (kartu outlet) |
| ProductDetailScreen | `CartScreen` (setelah `+ Keranjang` / `Simpan Perubahan`) |
| CartScreen | `OutletPickerScreen` (strip outlet), `ProductDetailScreen` (mode ubah), `OrderConfirmationScreen` |
| OrderConfirmationScreen | `OutletPickerScreen` (ganti outlet/alamat), `PaymentMethodsScreen(selectMode: true)`, `VoucherPackScreen`, `ProductDetailScreen` (Ganti), `QrisPaymentScreen`, lalu `OrderStatusScreen` (hanya metode non-QRIS) |
| QrisPaymentScreen | Beranda lewat `popUntil(isFirst)` di `onPaid`; tombol X kembali ke Checkout |
| OrderStatusScreen | — (hanya `maybePop`) |
| OrderHistoryScreen | `OrderStatusScreen`, `CartScreen` (keadaan kosong) |
| MerchScreen | `ScanMerchScreen` (ikon scan), `MerchDetailScreen` |
| MerchDetailScreen | `CartScreen` |
| ScanMerchScreen | `MerchDetailScreen` |
| ProfileScreen | `DataDiriScreen`, `AddressScreen`, `ScanMerchScreen`, `LanguageScreen`, `InboxScreen`, `OrderHistoryScreen`, `PaymentMethodsScreen`, `BulkOrderScreen`, `PointsHistoryScreen`, `CheckInScreen`, `NotificationSettingsScreen`, halaman statis |
| OutletPickerScreen | `AddressScreen` (mode Delivery) |
| BulkOrderScreen | `WhatsappServiceScreen` |

- Setiap layar produk dipanggil dengan `ProductDetailScreen(product: p.toProductMap())`.
- `OrderConfirmationScreen` **tidak** menerima produk; ia membaca `CartStore` (§11.5).
- Setelah pesanan dibuat, Checkout memakai `pushReplacement` supaya back tidak kembali ke halaman checkout yang sudah kosong.

### 12.2 Aturan transisi

- Semua perpindahan antar-halaman memakai `MaterialPageRoute` (transisi default). **Tidak ada** `PageRouteBuilder` atau animasi kustom di project ini.
- Tidak ada lagi impor ber-prefix antar-layar (dulu `order_confirmation_screen.dart` mengimpor detail produk dengan prefix untuk menghindari tabrakan nama warna). Setelah semua warna pindah ke `AppColors` (§16.3), tabrakan itu tidak ada.
- Tombol back header memakai `Navigator.maybePop(context)`; tombol yang memang harus menutup halaman memakai `Navigator.pop(context)`.
- Satu-satunya `popUntil` ada di QRIS ("Kembali Ke Beranda", lewat `_selesaikanPesananKeBeranda` di Checkout), karena pembayaran harus kembali ke Beranda dan bukan menumpuk halaman.
- Login/Daftar **tidak** memakai route: `showAuthSheet()` menampilkan bottom sheet, dan perpindahan Login ⇄ Daftar hanya `setState` di dalam sheet.

### 12.3 Pola penamaan variabel warna

**Satu cara, tanpa pengecualian:** ambil warna dari `AppColors` di `lib/theme/app_colors.dart`.

```dart
import '../theme/app_colors.dart';

color: AppColors.maroon,   // 0xFF7A263D
color: AppColors.textSecondary,
```

- **Migrasi selesai:** `grep "Color(0x" lib/**/*.dart` hanya menemukan `lib/theme/app_colors.dart`. Tidak ada lagi `const Color detailKopi`, `vipRed`, `kopi`, `abu`, dan sejenisnya di layar.
- `Colors.white`, `Colors.transparent`, `Colors.black12`, `Colors.grey.shade200/300/400/600`, `Colors.black54/87` masih dipakai apa adanya untuk putih/transparan/border netral — ini **bukan** token warna baru dan sudah dicatat di §3.8/§3.9. Jangan menambah nuansa abu baru di luar daftar itu.
- Warna brand/metrik **wajib** token, mis. jangan menulis `Color(0xFF7A263D)` di layar baru.

---

## 13. Copywriting & Format Angka

### 13.1 Bahasa

**Bahasa Indonesia, gaya kasual.** Contoh yang sudah ada:
- "Hai," + nama ("Guest" saat belum masuk) — dua baris terpisah di kartu Profil
- "Masuk untuk melanjutkan"
- "Edit Profil" (menggantikan tombol "Keluar" di header Profil)
- "Ga perlu paper" (placeholder catatan tambahan — **sudah dipakai** di Detail Produk)
- "Belanja Rp700.000 lagi untuk naik ke Level Gold"
- "Kantung Belanja"
- "Ambil pesananmu di Area Pickup di dalam outlet"
- "Belum punya akun? Daftar di sini"

**Tambahan dari fitur baru:**

| Konteks | Teks |
|---|---|
| Keranjang kosong | "Keranjangmu masih kosong" + tombol "Mulai Pesan" |
| Checkout kosong | "Keranjangmu masih kosong" + tombol "Kembali" |
| Keranjang | "Subtotal", "Checkout (n)", "Ganti", "Hapus" |
| Checkout | "Jadwalkan", "Bayar - Rp…", "Pakai kantung belanja (+Rp200)", "Pakai Kode Voucher" |
| QRIS | "Kembali Ke Beranda", "SCAN UNTUK MEMBAYAR" |
| Pesanan | "Status Pesanan", "Perbarui Status Pesanan", "Pesanan Sudah Saya Ambil", "Batalkan Pesanan", "Hubungi Outlet" |
| Pilih Outlet | "Pilih Outlet", "Ambil di", "Kirim ke {label}" |
| Daily Check-In | "Check-In Hari Ini", "n / 6 hari" |
| Profil (header) | "Edit Profil", "Keluar" (item section Akun), "Hai," + nama, "Level", "Kangenan Points" |
| Profil (promo) | "✨ Promo Spesial Buat Kamu!", "Ikuti Sekarang" |
| Scan Merch | "Mulai Scan", "Arahkan kamera ke QR di produk", "QR berhasil dipindai" |

**Panel Login & Daftar** (dipakai apa adanya oleh `AuthService`/`AuthStore`):

| Konteks | Teks |
|---|---|
| Subjudul Login | "Masuk untuk melanjutkan" |
| Subjudul Daftar | "Daftar untuk mulai memesan" |
| Field | "Email atau Nomor HP", "Password", "Nama Lengkap", "Ulangi Password", "Password (minimal 6 karakter)" |
| Tombol | "Login", "Daftar", "Lanjutkan dengan Google", "Masuk", "Keluar" |
| Tautan pindah mode | "Belum punya akun? **Daftar di sini**" / "Sudah punya akun? **Masuk di sini**" |
| Sukses | "Berhasil masuk. Selamat datang, [Nama]!" (juga untuk akun Google) |
| Keluar | "Anda telah keluar." |
| Gagal | "Email atau nomor HP harus diisi.", "Format email tidak valid. Contoh: nama@email.com", "Format nomor HP tidak valid. Contoh: 08123456789", "Password harus diisi.", "Password minimal 6 karakter.", "Nama harus diisi.", "Nama minimal 3 karakter.", "Akun belum terdaftar. Silakan daftar terlebih dahulu.", "Password salah.", "Konfirmasi password tidak sama.", "Email atau nomor HP sudah terdaftar. Silakan masuk." |

**Pengecualian** — beberapa teks memang berbahasa Inggris dan **jangan diterjemahkan** karena sudah jadi bagian desain:
- `'Optional · May select multiple'` (subjudul kustomisasi)
- `'Buy Pack'` (tombol paket voucher)
- `'Save 98%'` (badge hemat)
- `'SCAN UNTUK MEMBAYAR'` (huruf kapital semua, `letterSpacing: 1`)
- `'Out of Stock'`
- `'Total 1 Items'` (di kartu pesanan)
- `'Custom Merchandise'`
- `'Delivery'` / `'Pickup'`

### 13.2 Format Rupiah — **SATU GAYA: TANPA SPASI**

| Gaya | Contoh | Dipakai di |
|---|---|---|
| **Tanpa spasi** (satu-satunya) | `Rp19.000`, `Rp28.000` | `formatRupiah()`, `Product.priceLabel`, semua layar |
| **Angka berkelompok** (tanpa `Rp`) | `700.000` | `formatAngka()`, target belanja di kartu membership VIP |

**Aturan:** semua nominal memakai `formatRupiah()` dari `lib/utils/currency.dart` → **tanpa spasi**.
Kalau satuannya sudah jelas dari konteks (mis. "/ 700.000" di kartu membership), pakai `formatAngka()` — fungsi yang sama tanpa awalan `Rp`.

```dart
String formatRupiah(int value) => 'Rp${formatAngka(value)}';

String formatAngka(int value) { ... }   // pemisah ribuan manual, hasil "700.000"
```

Gaya `'Rp 28.000'` (dengan spasi) yang dulu ada sebagai data statis di `menu_screen.dart` sudah **dihapus**; harga sekarang berasal dari `Product.price` (`int`) dan dirender lewat `priceLabel`.

**Duplikasi sudah dibersihkan:** fungsi `rupiah()` lokal yang dulu disalin di `product_detail_screen.dart`, `order_confirmation_screen.dart`, dan `qris_payment_screen.dart` sekarang **tidak ada lagi** — semuanya memakai `formatRupiah()`. Jangan menulis ulang logika pemisah ribuan di layar baru.

### 13.3 Format lain

| Format | Contoh | Catatan |
|---|---|---|
| Points | `28 pts` | angka + spasi + `pts` (angka mentah, bukan Rupiah) |
| Persentase level | `50%` | `(MemberStore.levelProgress * 100).round()` |
| Timer | `09:59` | `padLeft(2, '0')` untuk menit & detik |
| Tanggal | `31 Okt 2026` | format `d MMM yyyy`, bahasa Indonesia |
| Jumlah item | `1 x` (kartu pesanan), `Total 1 Items` | dua gaya berbeda |
| Jumlah voucher | `66x` / `66×` | dua gaya berbeda (`x` vs `×`) |
| Check-in | `1 / 6 hari` | `'$done / ${MemberStore.maxCheckInDays} hari'` |

### 13.4 Aturan teks

1. Semua teks panjang wajib punya `maxLines` + `overflow: TextOverflow.ellipsis`.
2. Judul section: `w800`/`bold`, ukuran 19–22.
3. Jangan pakai titik di akhir label tombol/badge. Kalimat penuh boleh pakai titik.
4. Label tombol pakai Title Case ("Buy Pack", "Ikuti Sekarang", "Klaim").

---

## 14. Anti-Pola yang Sudah Ditemukan

Daftar ini adalah **hal yang tidak boleh ditambah lagi**. Setiap poin sudah ada di kode dan menjadi utang desain.

### 14.1 Warna — terlalu banyak varian untuk peran yang sama

Nilai-nilai di bawah **sudah** dikonsolidasikan menjadi token bernama (§3, §16.2)
dengan nilai yang dipertahankan persis. Tabel ini disimpan supaya jelas **mengapa**
tokennya banyak: setiap nilai memang berasal dari layar yang berbeda dan tidak boleh
disatukan.

| Peran | Jumlah varian | Nilai-nilai |
|---|---:|---|
| "Merah brand" | **5** | `0xFF7A263D`, `0xFFB92429`, `0xFFB51F2D`, `0xFFB82025`, `0xFFB3262D` |
| "Emas / gold" | **11** | `0xFFB99565`, `0xFFC6A577`, `0xFFD9B54A`, `0xFFC69A69`, `0xFFB89B65`, `0xFFB69A78`, `0xFFD2A36D`, `0xFFA6783A`, `0xFFBE9B6D`, `0xFFC4A047`, `0xFFB98050` |
| "Hijau" | **9** | `0xFF218B55`, `0xFF278F59`, `0xFF20C96B`, `0xFF54A77D`, `0xFF65A486`, `0xFF75B879`, `0xFF64BDB6`, `0xFF319795`, `0xFF38B2AC` |
| "Teks abu" | **6** | `0xFF777777`, `0xFF858585`, `0xFF9E9E9E`, `0xFF666666`, `0xFF555555`, `0xFFB8C0BD` |
| "Latar netral" | **14** | `0xFFFBFBFB`, `0xFFF8F9FA`, `0xFFF7F7F7`, `0xFFF1F4F8`, `0xFFF8F3EB`, `0xFFE8E8E8`, `0xFFFAFAFA`, `0xFFF8F8F8`, `0xFFF4F4F4`, `0xFFF5F5F5`, `0xFFF2F2F2`, `0xFFF0F0F0`, `0xFFEAEAEA`, `0xFFEAF6EF` |

**Aturan:** untuk kode **baru**, pilih dari §3 saja. **Jangan menambah varian ke-12 untuk
emas atau ke-6 untuk merah** — kalau butuh nilai yang tidak ada, tambahkan ke dokumen
ini dulu sebelum dipakai.

### 14.2 Radius

Nilai yang dipakai: **6, 7, 8, 9, 10, 12, 14, 15, 16, 18, 20, 22, 24, 25, 40, 360** — tidak ada skala resmi. Untuk kode baru, pakai **8 / 12 / 14 / 16 / 24 / circle**.

### 14.3 Kode mati & duplikasi

| Masalah | Lokasi / status |
|---|---|
| `MobileFrame` belum dipakai di layar mana pun | `lib/widgets/mobile_frame.dart` — tersedia untuk mode demo web; **bukan** bagian alur aplikasi |
| Status "Out of Stock" di-hardcode lewat string | `lib/screens/product/product_detail_screen.dart` → `option == 'Golden boba'`; idealnya jadi field data |
| Semua produk hardcoded di widget | **Sudah diperbaiki** → `lib/models/product.dart` (`kProductCatalog`) |
| Semua merch hardcoded di widget | **Sudah diperbaiki** → `lib/models/merch.dart` (`kMerchCatalog`), dibaca `merch_screen.dart` |
| `rupiah()` diduplikasi 3× | **Sudah diperbaiki** → semua memakai `formatRupiah()` (`lib/utils/currency.dart`) |
| Banyak tombol `onPressed: () {}` (tidak berfungsi) | **Sudah diperbaiki** — Profil, VIP, Beranda, dan Checkout sekarang membuka halaman/menjalankan aksi |
| Semua warna dideklarasikan ulang per file | **Sudah diperbaiki** → `lib/theme/app_colors.dart`; `grep "Color(0x"` di luar file itu = 0 |
| Nama outlet ditulis di dua tempat dengan nilai berbeda | **Sudah diperbaiki** → `kDefaultOutlet` + `OutletStore.selected` dipakai Beranda, Menu, Keranjang, Checkout |
| Ternary dengan dua cabang identik | **Sudah diperbaiki** (ternary label tombol QRIS sudah dihapus bersama tombol "Nanti Saja"/"Saya Sudah Bayar") |
| `SizedBox(width: 12)` dua kali berturut-turut | **Sudah diperbaiki** |
| `const Color pink` tidak dipakai | **Sudah diperbaiki** (token `AppColors.pink`) |

**Yang sudah diselesaikan pada pekerjaan Beranda/Menu:**
- `SplashScreen` tidak lagi kode mati — sekarang jadi `home:` di `main.dart`.
- Produk tidak lagi hardcoded di dalam widget; seluruh katalog ada di `kProductCatalog`.
- Nama outlet tidak lagi berbeda antar layar; semuanya membaca `OutletStore.selected`.
- Kartu outlet, tab kategori, badge, pill harga, judul section, dan section Diskon & Cashback tidak lagi ditulis ulang per halaman — sudah jadi komponen di `lib/widgets/`.

**Yang sudah diselesaikan pada pekerjaan Login & Daftar:**
- Panel Login tidak lagi `pushReplacement(MainNavigationScreen)` setelah berhasil masuk — dulu ini menumpuk shell aplikasi kedua di atas yang pertama. Sekarang sheet-nya ditutup (§11.10).
- Login & Daftar benar-benar berfungsi (validasi, akun demo, pesan kesalahan) — dulu `_masuk()` hanya memeriksa field kosong.
- Form Daftar yang dulu cuma `SnackBar('Halaman daftar belum dibuat.')` sekarang ada sebagai `register_screen.dart`.
- Tombol "Masuk" di halaman Profil tidak lagi `onPressed: () {}` — membuka panel login.
- Sapaan header Profil tidak lagi dipatok "Hai, Guest"; dibaca dari `AuthStore.currentUser`.
- Kerangka panel yang dulu disalin di dalam `login_screen.dart` sekarang tinggal satu tempat (`AuthPanel`).
- Judul "Daily Check-In" dibungkus `Expanded` supaya barisnya tidak overflow saat metrik fontnya lebih lebar.

**Yang sudah diselesaikan pada pekerjaan fitur lengkap (keranjang → pesanan):**
- Keranjang (`cart_screen.dart`) dan seluruh alur Checkout baru berbasis `CartStore` — tidak lagi menerima satu produk.
- `OrderConfirmationScreen` membuat `Order` sungguhan di `OrderStore`; halaman Status Pesanan dan Riwayat Pesanan membaca store yang sama.
- QRIS memakai satu tombol "Kembali Ke Beranda" (`onPaid`) — membuat pesanan lewat `_selesaikanPesananKeBeranda()` lalu kembali ke Beranda. Dulu hanya countdown tanpa cara menyelesaikan pembayaran, lalu sempat punya tombol "Nanti Saja"/"Saya Sudah Bayar".
- Voucher, poin, kantung belanja, dan jadwal benar-benar memengaruhi total (`OrderStore.create`).
- Daily Check-In, Data Diri, Alamat, Kotak Masuk, Riwayat Poin, Pilih Outlet, dan Metode Pembayaran tidak lagi layar kosong.
- Kartu membership VIP membaca level/poin/belanja nyata (dulu selalu Silver `0 / 699.999`).
- Nomor pesanan baru mulai `#1002` supaya tidak bertabrakan dengan pesanan contoh `#1001`.
- `AppCard` membungkus isinya dengan `Material(transparency)` — asersi `ListTile` tidak lagi muncul di Checkout, Alamat, dan Pengaturan Notifikasi.

**Yang sudah diselesaikan pada revisi halaman Profil:**
- Header tidak lagi memakai tinggi tetap `SizedBox(height: 220)` + `Positioned`. Tingginya sekarang mengikuti isi kartunya, jadi kartu promo di bawahnya benar-benar berjarak **16 px** (dulu 0 px karena kartu berakhir tepat di batas 220). Jaraknya dikunci tes tata letak (`layout_test.dart`).
- Tombol "Keluar" pindah dari header ke item section **Akun** (hanya tampil saat sudah masuk); header sekarang menampilkan "Edit Profil" → `DataDiriScreen`.
- Sapaan, level, dan poin digabung menjadi satu kartu tiga kolom. Progress bar panjang + baris "Belanja Rp… lagi untuk naik ke Level …" diganti ikon progres bulat + "{Level} {0%}" — info sisa belanja tetap lengkap di halaman VIP.
- Avatar memakai `assets/logo.png` dengan ring emas (dulu ikon `person` abu), dan ikon koin memakai `KangenanCoin` ("K") alih-alih `Icons.monetization_on` ("$").
- Baris "WhatsApp Channel" dihapus dan ikon WhatsApp pindah ke dalam tombol "Ikuti Sekarang"; judul promo diawali ✨.

### 14.4 Jangan lakukan ini di kode baru

```dart
// ❌ JANGAN — ListTile di dalam Container berwarna → assertion
Container(decoration: BoxDecoration(color: Colors.white), child: ListTile(...))

// ✅ LAKUKAN
Container(
  decoration: BoxDecoration(color: Colors.white),
  child: Material(type: MaterialType.transparency, child: ListTile(...)),
)

// ❌ JANGAN — withOpacity deprecated
Colors.black.withOpacity(0.04)

// ✅ LAKUKAN
Colors.black.withValues(alpha: 0.04)

// ❌ JANGAN — teks lebar + tombol dalam Row tanpa Expanded
//    (nyata terjadi di "Daily Check-In": overflow 72 px)
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [Text('Daily Check-In', style: TextStyle(fontSize: 20)), TextButton(...)],
)

// ✅ LAKUKAN — biarkan teks menyusut; hasilnya sama di font normal
Row(children: [Expanded(child: Text('Daily Check-In', ...)), TextButton(...)])

// ❌ JANGAN — menampilkan opsi minuman untuk makanan / merchandise
//    (nyata terjadi: ColorPop Cup memunculkan baris "Standar · · · ·")
ProductDetailScreen(product: {'name': 'Triple Cheese Bagel', ...})

// ✅ LAKUKAN — opsi minuman hanya lewat Product.isDrink / CartItem.hasDrinkOptions
ProductDetailScreen(product: product.toProductMap())            // katalog
ProductDetailScreen(product: {...}, drinkOptions: item.hasDrinkOptions)

// ❌ JANGAN — menyimpan placeholder sebagai nilai opsi
CartItem(size: 'Standar', milk: '-', sugar: '-', ice: '-')

// ✅ LAKUKAN — makanan & merchandise menyimpan string kosong
CartItem(size: '', milk: '', sugar: '', ice: '')

// ❌ JANGAN — header dengan tinggi tetap + Positioned, lalu kartu berikutnya
//    bermargin atas 0. Kartunya "pas" di batas tinggi itu sehingga kartu
//    berikutnya menempel tanpa jarak (nyata terjadi di header Profil dulu:
//    SizedBox(height: 220) + Positioned(top: 100) + margin atas promo 0)
SizedBox(
  height: 220,
  child: Stack(children: [..., Positioned(top: 100, child: KartuLevel())]),
),

// ✅ LAKUKAN — biarkan tinggi header mengikuti isinya, jarak jadi margin
//    kartu berikutnya. Uji dengan getRect + Key supaya tidak kambuh.
Column(children: [BandDanAvatar(), KartuSapaanLevelPoin(), KartuPromo()])
```

---

## 15. Checklist Sebelum Bikin Layar Baru

**Fondasi**
- [ ] Untuk halaman yang di-push, pakai **`AppPage`** (§10.26) — jangan menyusun `Scaffold` + header + `ConstrainedBox` sendiri.
- [ ] Kalau tidak memakai `AppPage`: `Scaffold` + `SafeArea(bottom: false)` + `Center` + `ConstrainedBox(maxWidth: 390/430/480)` sesuai §8.1.
- [ ] Ambil warna dari §3 lewat `AppColors` (`lib/theme/app_colors.dart`). **Tidak ada** `Color(0x…)` literal baru di luar file itu.
- [ ] Font: Roboto (default). Jangan daftarkan font baru.
- [ ] Urutan parameter `AppPage`: `bottomBar:` dan `scrollable:` **sebelum** `children:` (lint `sort_child_properties_last`).

**Komponen**
- [ ] Kartu: `AppCard` (radius 16, border `border`), bukan `Container` baru.
- [ ] Tombol primer: `AppPrimaryButton` (tinggi 48, radius 12; radius 8 kalau di dalam konten) atau `AppOutlineButton`.
- [ ] Keadaan kosong: `AppEmptyState` (§10.27), ikon 70.
- [ ] Judul section: 19–22, `w800`/`bold`.
- [ ] Teks sekunder: `AppColors.textSecondary`.
- [ ] `ListTile` di dalam kartu berwarna → bungkus `Material(type: MaterialType.transparency)` (`AppCard` sudah begitu).
- [ ] Bayangan pakai `.withValues(alpha:)`, bukan `.withOpacity()`.
- [ ] Baris "teks panjang + tombol di kanan" → bungkus teksnya dengan `Expanded`.
- [ ] Panel login/daftar baru → pakai `AuthPanel` + `showAuthSheet()` (§10.25, §11.10), jangan menyalin lebar/tinggi/radius-nya.
- [ ] SnackBar → `showAppMessage(context, ...)`, bukan `ScaffoldMessenger` langsung.

**Ikon & Gambar**
- [ ] Hanya `Icons.*` dari Material.
- [ ] Ukuran ikon dari daftar §9.1.
- [ ] Semua `Image.asset` punya `errorBuilder`.
- [ ] `assets/` baru harus didaftarkan di `pubspec.yaml` (folder `assets/` sudah terdaftar penuh, `assets/merch/` juga).

**Teks & angka**
- [ ] Nominal pakai `formatRupiah()` dari `lib/utils/currency.dart` → `Rp19.000` (tanpa spasi).
- [ ] Angka tanpa satuan yang butuh pemisah ribuan → `formatAngka()` (`700.000`).
- [ ] `maxLines` + `overflow: TextOverflow.ellipsis` untuk teks panjang.
- [ ] Bahasa Indonesia kasual; jangan terjemahkan istilah desain di §13.1.

**State**
- [ ] Data baru disimpan di store `ValueNotifier` (`lib/providers/`), bukan di `State` lokal, kalau dipakai lintas halaman.
- [ ] Tambahkan `reset()` di store supaya bisa dipakai `setUp` tes.
- [ ] Jangan menulis ke disk / menambah package penyimpanan (§2).

**Verifikasi**
- [ ] `flutter analyze` → harus `No issues found!`
- [ ] `flutter test` → semua tes lulus (termasuk `store_test.dart` dan `flow_test.dart`).
- [ ] `flutter build web --release --no-wasm-dry-run` → exit 0.
- [ ] Jalankan di Chrome (`flutter run -d chrome`) dan pastikan **0 exception** di console.
- [ ] Cek di lebar sempit (≤390) dan lebar (≥480) — tidak ada overflow.

---

## 16. Konsolidasi Token

**Status: SELESAI untuk seluruh `lib/`.** Setiap warna yang dipakai layar, model, dan
widget sudah menjadi konstanta di `theme/app_colors.dart`; tidak ada lagi `Color(0x…)`
di luar file itu. `utils/currency.dart` menjadi satu-satunya pemformat angka.

Tujuannya sejak awal: memindahkan seluruh token ke satu sumber **tanpa mengubah satu
pixel pun** — nilainya dipertahankan persis, hanya namanya yang distandarkan.

### 16.1 Struktur aktual

```
lib/
├── theme/
│   └── app_colors.dart      // ✅ 73 token warna (§3)
├── utils/
│   ├── currency.dart        // ✅ formatRupiah() + formatAngka()
│   └── strings.dart         // ✅ label yang ikut bahasa (§17)
└── ... (layar, model, provider, widget)
```

`app_text_styles.dart`, `app_spacing.dart`, dan `app_theme.dart` **tidak dibuat** —
tipografi dan spacing cukup didokumentasikan di §4/§5 dan belum perlu abstraksi baru.
Jangan menambahkannya tanpa kebutuhan nyata.

### 16.2 Pemetaan nama token

Nama `AppColors` sekarang sama dengan kolom **`AppColors`** di §3.1–§3.11. Pemetaan
nama lama → token (contoh yang paling sering dipakai):

| Nama lama (per layar) | Token sekarang |
|---|---|
| `kopi`, `detailKopi`, `kopiMerch` | `maroon` |
| `vipRed`, `merah` (CTA) | `action` |
| `merah` (checkout) | `checkoutRed` |
| `qrisRed` | `qrisRed` |
| `profileRed` | `red` |
| `detailEmas` | `gold` |
| `emas` | `goldBorder` |
| `profileGold` | `goldProfile` |
| `vipGreen` | `greenVip` |
| `abu` | `textSecondary` |
| `vipText` | `textVip` |
| `vipGrey` | `textVipGrey` |
| `qrisText` | `textQris` |
| `mint` | `mint` |

> Nilai tidak pernah disatukan. `0xFFB92429` (`checkoutRed`) dan `0xFFB82025`
> (`qrisRed`) tetap dua token berbeda karena memang berbeda di layar aslinya.

### 16.3 Urutan pengerjaan (semua selesai)

1. ✅ `lib/theme/app_colors.dart` dibuat dan dipakai semua widget bersama.
2. ✅ `lib/utils/currency.dart` dibuat; `formatRupiah()` dipakai semua nominal, dan
   `formatAngka()` ditambahkan untuk target belanja di kartu membership.
3. ✅ Migrasi warna per layar — termasuk `merch`, `vip`, `profile`, `checkout`, `qris`,
   `product_detail`, `home`, dan `menu`.
4. ✅ Verifikasi visual per layar sambil membandingkan dengan nilai §3 (nilai tidak
   berubah, hanya nama).
5. ✅ `const Color` lokal dihapus; semua file mengimpor `AppColors`.
6. ✅ Tiga salinan `rupiah()` dihapus; `qris_payment_screen.dart` sekarang memakai
   `formatRupiah()`.

**Cek cepat:**

```bash
# harus 0 hasil
rg "Color\(0x" lib --glob "!lib/theme/app_colors.dart"

# harus 0 hasil
rg "withOpacity\(" lib
```

### 16.4 Kenapa nilainya tidak boleh digabung

Kalau token digabung tanpa mempertahankan nilai, tampilan akan bergeser (contoh:
menyatukan 5 merah jadi 1 akan mengubah tombol "Bayar" dari `0xFFB92429` menjadi
`0xFF7A263D`). **Konsolidasi = menggabungkan nama, bukan menggabungkan nilai.**

---

## 17. Keputusan & Batasan yang Disengaja

Bagian ini merangkum hal-hal yang **tampak belum lengkap** tetapi memang diputuskan
begitu. Jangan "memperbaikinya" tanpa persetujuan pemilik produk.

| Hal | Keputusan | Aturan untuk kontributor |
|---|---|---|
| **Pencarian produk (PRD F17)** | Tidak dibuat | Jangan menambahkan ikon cari, kolom cari, atau halaman hasil pencarian di Beranda/Menu |
| **Bahasa (PRD F49)** | Sebagian: hanya label bottom nav + beberapa teks global lewat `Strings` | Teks baru yang perlu diterjemahkan masuk ke `lib/utils/strings.dart` dengan getter ber-`AppLanguage`; jangan menaruh dua bahasa inline di layar. Konten halaman tetap Bahasa Indonesia |
| **Penyimpanan data** | In-memory (`ValueNotifier`); token API hanya di memori | Jangan menambah `shared_preferences`, `sqflite`, `hive`, atau menulis file. Menutup aplikasi = semua data kembali ke awal, dan pengguna harus login lagi |
| **Login Google (PRD F2)** | Simulasi akun contoh | Jangan menambah `google_sign_in` atau kredensial OAuth; tampilan tombol tidak boleh berubah |
| **Banner Beranda** | Satu gambar statis `assets/banner_promo.png` | Jangan mengubahnya menjadi carousel / `PageView` / dot indikator |
| **Scan Merchandise** | Simulasi (timer 1,2 detik lalu memilih merch acak) | Jangan menambah akses kamera atau package QR tanpa persetujuan |
| **Metode pembayaran** | Hanya QRIS, blu by BCA Digital, GoPay, Kartu Debit/Kredit (§3.11) | Merek lain butuh warna brand resmi yang dicatat di §3 lebih dulu |
| **Merch** | Dibeli lewat keranjang yang sama seperti produk | Bukan sistem tukar poin; scan hanya menampilkan detail |
| **`MobileFrame`** | Tersedia tetapi tidak dipakai di alur aplikasi | Hanya untuk demo web; jangan dijadikan `home:` |
| **Bottom navigation** | 5 tab, urutan & gaya tetap | Label boleh ikut bahasa; ikon, ukuran, dan urutan tidak boleh berubah |

**Cara memverifikasi bahwa batasan ini masih dipegang:**

```bash
# harus 0 hasil
rg "Icons\.search" lib
rg "PageView" lib/screens/home
rg "google_sign_in|shared_preferences|sqflite|hive" pubspec.yaml
```

---

## 18. Integrasi REST API

Aplikasi ini **offline-first**: setiap store sudah punya nilai awal yang benar
dari `lib/models/`, lalu disegarkan dari REST API. Jadi tampilan tetap normal
walau server mati — yang hilang hanya kesegaran data, bukan halamannya.

### Berkas

| Berkas | Peran |
|---|---|
| `lib/config/api.dart` | `ApiConfig` — alamat dasar (`API_BASE_URL`), `enabled`, `token`, `canSync` |
| `lib/services/api_client.dart` | Pembungkus `http` + `ApiException` berbahasa Indonesia, `dataOf`/`listOf` |
| `lib/services/sync_service.dart` | Semua tarik-data dan kirim-perubahan ke API |
| `lib/providers/catalog_store.dart` | Katalog menu/merch/outlet yang bisa diperbarui dari API |
| `lib/providers/auth_store.dart` | Jalur daring (`signIn`, …) dan jalur lokal (`login`, …) |

### Aturan untuk kontributor

1. **Widget tidak boleh memanggil HTTP.** Layar hanya membaca store; perubahan
   dikirim lewat `SyncService.push…` dari dalam store.
2. **Store lokal adalah sumber kebenaran tampilan.** Ubah nilai lokal lebih
   dulu supaya UI langsung berubah, baru kirim ke API tanpa menunggu
   (`unawaited`).
3. **Setiap panggilan API harus lewat `ApiConfig.canSync`** (`enabled &&
   hasToken`). Ini yang membuat pengujian widget tidak pernah menyentuh
   jaringan; `test/widget_test.dart`, `layout_test.dart`, `flow_test.dart`, dan
   `auth_test.dart` mengeset `ApiConfig.enabled = false` di `setUp`.
4. **Jangan menambah penyimpanan token.** Token Sanctum hidup di
   `ApiConfig.token` (memori) dan hilang saat aplikasi ditutup — sama seperti
   seluruh data lain.
5. **Jangan menambahkan migration Laravel.** Skema dimiliki
   `docs/database/kopi_kangenan.sql`; lihat `docs/database/README.md`.
6. **Alamat API diubah lewat dart-define**, bukan dengan mengedit kode:
   `flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.1.10:8000/api`.

### Alur saat aplikasi dibuka

1. `SplashScreen` menjalankan `SyncService.bootstrap()` **bersamaan** dengan
   jeda 3 detik, lalu lanjut ke `LoginHomeScreen`.
2. `bootstrap()` menarik katalog (menu, merch, outlet). Outlet default dari
   server hanya dipakai kalau pengguna belum memilih outlet lain.
3. Popup login muncul di atas `MainNavigationScreen`; menutupnya berarti
   memakai aplikasi sebagai Guest (tanpa sinkronisasi).
4. Setelah login, `SyncService.refreshUserData()` menarik membership, poin,
   riwayat pesanan, voucher, alamat, kotak masuk, pengaturan, dan metode
   pembayaran.

### Titik integrasi per fitur

| Fitur | Arah | Fungsi |
|---|---|---|
| Katalog menu/merch/outlet | tarik | `SyncService.loadCatalog` |
| Masuk / daftar / Google | dua arah | `AuthStore.signIn` / `signUp` / `signInWithGoogle` |
| Data diri & password | kirim | `AuthStore.saveProfile` / `savePassword` |
| Buat pesanan (checkout) | kirim | `SyncService.createOrder` → jatuh ke `OrderStore.create` kalau gagal |
| Status pesanan | kirim | `OrderStore.advance` / `cancel` → `pushOrderAdvance` / `pushOrderCancel` |
| Daily Check-In | kirim | `MemberStore.checkIn` → `pushCheckIn` |
| Klaim promo / beli paket / kode voucher | kirim | `VoucherStore` → `pushPromoClaim` / `pushBuyVoucherPack` / `pushVoucherCode` |
| Alamat | kirim | `AddressStore.add` / `remove` → `pushAddressCreate` / `pushAddressDelete` |
| Kotak masuk | kirim | `InboxStore.markRead` / `markAllRead` → `pushInboxRead` / `pushInboxReadAll` |
| Pengaturan | kirim | `SettingsStore.setLanguage` / `setNotifPromo` / `setNotifPesanan` / `setBiometric` → `pushSettings` |
| Metode pembayaran | kirim | `PaymentStore.select` / `connect` → `pushPaymentSelect` / `pushPaymentConnect` |

**Keranjang sengaja tidak disinkronkan.** `CartItem` di Flutter tidak menyimpan
`product_id`, jadi keranjang tetap murni di sisi klien; server menyimpan
snapshot item saat pesanan dibuat. Tabel `carts`/`cart_items` tetap tersedia di
API bagi klien yang ingin sinkron penuh.

### Dokumentasi terkait

- `docs/api.md` — daftar endpoint, contoh permintaan, cara menjalankan.
- `docs/database/README.md` — skema 29 tabel dan peta model Dart → tabel.
- `docs/postman/kopi_kangenan.postman_collection.json` — koleksi siap impor.

### Cara memverifikasi integrasi masih utuh

```bash
flutter analyze
flutter test                       # 57 tes, tanpa jaringan
flutter build web --release --no-wasm-dry-run
```

```powershell
cd D:\laragon\www\kopi-kangenan-api
php artisan test                   # 42 tes fitur
```

---

*Dokumen ini dibuat dari analisis kode pada 19 Oktober 2026. Setiap kali ada komponen atau warna baru, perbarui dokumen ini **sebelum** menulis kodenya.*

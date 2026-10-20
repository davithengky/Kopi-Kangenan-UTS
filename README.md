# Kopi Kangenan

Proyek UTS **Rekayasa Perangkat Lunak / Pemrograman Mobile** berupa aplikasi pemesanan kopi
yang meniru (clone) aplikasi **Kopi Kenangan**, dengan nama plesetan **Kopi Kangenan**.

Repo ini berisi tiga bagian:

| Folder | Isi |
|---|---|
| `Frontend/` | Aplikasi klien **Flutter** (Android, iOS, Web, Windows, macOS, Linux) |
| `Backend/` | REST API **Laravel 13 + Laravel Sanctum** |
| `Script Database/` | Skema & data awal database **MySQL** (`kopi_kangenan.sql`) |

---

## 1. Daftar Anggota Kelompok

| No | Nama | NIM |
|---|---|---|
| 1 | Khan Nasywa Zibrij Habibi | 24051214212 |
| 2 | Bindi Achmad | 24051214234 |
| 3 | M. Fauzan Bintang Perdana | 24051214233 |
| 4 | Davit Hengky Saputra | 24051214244 |

---

## 2. Aplikasi Asli dan Plesetannya

| Keterangan | Nama |
|---|---|
| Aplikasi asli | **Kopi Kenangan** |
| Nama plesetan (proyek ini) | **Kopi Kangenan** |

---

## 3. Panduan Singkat Menjalankan Proyek

### 3.1 Prasyarat

- **Flutter SDK** versi stable 3.x + Dart 3.x
- **PHP** >= 8.3 dan **Composer**
- **MySQL** (mis. XAMPP / Laragon) — opsional, backend juga bisa memakai SQLite
- Git

### 3.2 Menyiapkan Database

Skema database (29 tabel) beserta data awalnya sudah tersedia di file
`Script Database/kopi_kangenan.sql`. File ini sekaligus membuat database `kopi_kangenan`.

Lewat phpMyAdmin: buat/import file tersebut melalui menu **Import**.
Atau lewat terminal:

```bash
mysql -u root -p < "Script Database/kopi_kangenan.sql"
```

> Catatan: repo ini tidak menyertakan folder migrasi Laravel, jadi skema dibuat dari
> file SQL di atas (tidak perlu `php artisan migrate`).

### 3.3 Menjalankan Backend (Laravel)

```bash
cd Backend

composer install

# Windows
copy .env.example .env
# Linux/macOS
cp .env.example .env

php artisan key:generate
```

Sesuaikan bagian database di file `Backend/.env`:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=kopi_kangenan
DB_USERNAME=root
DB_PASSWORD=
```

Jalankan server:

```bash
php artisan serve
```

API tersedia di `http://127.0.0.1:8000/api` (autentikasi memakai Bearer token Sanctum).
Seeder akun demo bersifat opsional: `php artisan db:seed`.

### 3.4 Menjalankan Frontend (Flutter)

```bash
cd Frontend

flutter pub get
flutter run -d chrome        # Web
flutter run -d windows       # Windows desktop
flutter run                  # Android/iOS pada perangkat/emulator
```

Secara default aplikasi mengarah ke `http://127.0.0.1:8000/api`. Kalau alamat API berbeda
(misalnya dijalankan di HP yang terhubung ke WiFi satu jaringan), ubah tanpa mengedit kode:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
```

### 3.5 Akun Demo

| Field | Nilai |
|---|---|
| Email | `demo@kangenan.com` |
| Password | `123456` |

Aplikasi juga tetap bisa dipakai dalam mode lokal (tanpa backend), data contoh sudah
tersedia di dalam aplikasi.

---

## 4. Dokumentasi Lain

- `Frontend/docs/arsitektur.md` — arsitektur aplikasi Flutter
- `Frontend/docs/design.md` — design system
- `Frontend/docs/api.md` — daftar endpoint API
- `Backend/docs/arsitektur-sistem.md` — arsitektur backend Laravel
- `Backend/docs/rest-api.md` — dokumentasi REST API

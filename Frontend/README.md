# Kopi Kangenan — Frontend (Flutter)

Aplikasi mobile/web/desktop untuk pemesanan produk Kopi Kangenan, dibangun dengan Flutter.

## Fitur
- Autentikasi (login/register)
- Katalog produk & menu
- Keranjang & checkout (QRIS, voucher)
- Riwayat pesanan & status
- Profil, alamat, poin, inbox
- VIP & merchandise

## Prasyarat
- Flutter SDK (stable)
- Dart SDK
- Android Studio / Xcode (untuk build mobile)
- Java 17+ (untuk build Android)

## Instalasi
```bash
git clone https://github.com/davithengky/Kopi-Kangenan-Frontend-Flutter.git
cd Kopi-Kangenan-Frontend-Flutter
flutter pub get
```

## Menjalankan
```bash
# Web
flutter run -d chrome

# Windows desktop
flutter run -d windows

# Android (perangkat terhubung)
flutter run
```

## Struktur Proyek
```
lib/
  config/        # konfigurasi API
  models/        # model data
  providers/     # state management
  screens/       # halaman UI
  services/      # service API
  theme/         # tema & warna
  utils/         # utilitas
  widgets/       # komponen reusable
```

## Build
```bash
flutter build apk        # Android
flutter build web        # Web
flutter build windows     # Windows
```

## Catatan
Jika build Android gagal karena memori (Gradle daemon), perbesar virtual memory (page file) Windows dan set `JAVA_HOME` ke JDK 17 (mis. JBR Android Studio).

## Lisensi
Private / internal project.
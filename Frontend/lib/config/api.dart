/// Konfigurasi koneksi ke REST API Kopi Kangenan (Laravel).
///
/// Alamat dasar bisa diubah tanpa mengedit kode, misalnya saat aplikasi
/// dijalankan di perangkat lain:
///
/// ```
/// flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
/// ```
class ApiConfig {
  const ApiConfig._();

  /// Alamat dasar API, diakhiri `/api` (lihat `routes/api.php` di Laravel).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );

  /// `true` kalau aplikasi memakai REST API; `false` untuk mode lokal penuh.
  ///
  /// Pengujian widget menyetel ini ke `false` supaya tidak memerlukan jaringan.
  static bool enabled = true;

  /// Token Sanctum pengguna yang sedang masuk.
  ///
  /// Hanya hidup di memori, sama seperti seluruh data aplikasi: menutup
  /// aplikasi berarti pengguna keluar (lihat `docs/design.md` §17).
  static String? token;

  /// `true` kalau sudah ada token yang bisa dipakai.
  static bool get hasToken => token != null && token!.isNotEmpty;

  /// `true` kalau permintaan ke API sebaiknya dikirim.
  static bool get canSync => enabled && hasToken;
}

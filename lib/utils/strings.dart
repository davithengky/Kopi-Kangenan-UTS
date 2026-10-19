/// Pilihan bahasa aplikasi (PRD F49).
enum AppLanguage {
  indonesia('Indonesia'),
  english('English');

  const AppLanguage(this.label);

  final String label;
}

/// Kumpulan teks yang ikut berubah saat bahasa diganti.
///
/// Cakupannya sengaja dibatasi pada label global (bottom navigation dan judul
/// halaman utama), karena menambahkan paket lokalisasi resmi dilarang di fase
/// ini. Lihat `docs/design.md` §17.
class Strings {
  const Strings._();

  static String beranda(AppLanguage language) =>
      language == AppLanguage.english ? 'Home' : 'Beranda';

  static String menu(AppLanguage language) =>
      language == AppLanguage.english ? 'Menu' : 'Menu';

  static String vip(AppLanguage language) =>
      language == AppLanguage.english ? 'VIP' : 'VIP';

  static String merch(AppLanguage language) =>
      language == AppLanguage.english ? 'Merch' : 'Merch';

  static String saya(AppLanguage language) =>
      language == AppLanguage.english ? 'Account' : 'Saya';

  static String keranjang(AppLanguage language) =>
      language == AppLanguage.english ? 'Cart' : 'Keranjang';

  static String halamanTidakDitemukan(AppLanguage language) =>
      language == AppLanguage.english ? 'Page not found' : 'Halaman tidak ditemukan';

  static String belumMasuk(AppLanguage language) =>
      language == AppLanguage.english ? 'Not signed in' : 'Belum masuk';

  static String masuk(AppLanguage language) =>
      language == AppLanguage.english ? 'Sign in' : 'Masuk';

  static String keluar(AppLanguage language) =>
      language == AppLanguage.english ? 'Sign out' : 'Keluar';

  static String haiGuest(AppLanguage language) =>
      language == AppLanguage.english ? 'Hi, Guest' : 'Hai, Guest';
}

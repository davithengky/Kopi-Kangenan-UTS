/// Format angka Rupiah dengan pemisah ribuan berupa titik, tanpa spasi.
///
/// ```dart
/// formatRupiah(19000); // "Rp19.000"
/// ```
///
/// Ini menggantikan fungsi `rupiah()` yang sebelumnya disalin di beberapa file
/// layar (lihat `docs/design.md` §14.3).
String formatRupiah(int value) => 'Rp${formatAngka(value)}';

/// Sama seperti [formatRupiah] tetapi **tanpa** awalan `Rp`.
///
/// ```dart
/// formatAngka(700000); // "700.000"
/// ```
///
/// Dipakai untuk angka besar yang sudah jelas satuannya, mis. target belanja
/// di kartu membership VIP (`docs/design.md` §11.7).
String formatAngka(int value) {
  final text = value.toString();
  final result = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    result.write(text[i]);

    final remaining = text.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      result.write('.');
    }
  }

  return result.toString();
}

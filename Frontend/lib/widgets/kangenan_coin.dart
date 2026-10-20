import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Koin Kangenan: lingkaran emas berisi huruf "K" putih.
///
/// Menggantikan `Icons.monetization_on` (ikon bawaan itu bundaran bertanda
/// dolar) agar sesuai apps aslinya, sekaligus dipakai seragam di kartu header
/// Profil, kartu Daily Check-In, dan halaman detail `CheckInScreen`.
class KangenanCoin extends StatelessWidget {
  /// Diameter lingkaran. Sesuaikan dengan tinggi baris di sekitarnya.
  final double size;

  /// Warna lingkaran. Hari yang belum check-in memakai abu-abu.
  final Color color;

  const KangenanCoin({
    super.key,
    this.size = 18,
    this.color = AppColors.goldCoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        'K',
        style: TextStyle(
          // Huruf ikut mengecil saat koinnya kecil supaya tetap di tengah.
          fontSize: size * 0.62,
          height: 1,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

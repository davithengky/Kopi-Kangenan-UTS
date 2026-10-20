import 'package:flutter/material.dart';

import '../models/outlet.dart';
import '../theme/app_colors.dart';

/// Kartu outlet yang dipakai bersama oleh Beranda dan Menu.
///
/// Jadi satu-satunya tempat desain kartu outlet ditulis, sehingga nama outlet
/// di Beranda dan Menu dijamin sama karena keduanya membaca objek [Outlet]
/// yang sama.
///
/// Tampilannya mengikuti kartu outlet di Beranda: radius 15, border
/// [Colors.black12], padding 12.
class OutletCard extends StatelessWidget {
  final Outlet outlet;

  /// Ikon atau tombol di sisi kanan. Beranda memakai panah bawah + tombol scan,
  /// Menu memakai logo Kopi Kangenan.
  final Widget? trailing;

  const OutletCard({super.key, required this.outlet, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppColors.maroon, size: 25),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outlet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  outlet.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: 10),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Logo Kopi Kangenan untuk sisi kanan kartu outlet di halaman Menu.
class OutletLogoTile extends StatelessWidget {
  final double size;

  const OutletLogoTile({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.favorite, color: AppColors.maroon, size: 30),
    );
  }
}

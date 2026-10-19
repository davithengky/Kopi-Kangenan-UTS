import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Judul section pada Beranda dan Menu, mis. "Baru!" atau "Makanan".
class SectionHeader extends StatelessWidget {
  final String title;

  /// Beranda memakai inset 20, Menu memakai 16.
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

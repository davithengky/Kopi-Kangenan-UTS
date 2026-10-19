import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Frame bergaya ponsel (390 x 844) untuk menjalankan aplikasi di layar
/// desktop/web tanpa tampilan melebar.
///
/// Dibungkus [ClipRect] supaya konten yang keluar dari frame tidak terlihat.
class MobileFrame extends StatelessWidget {
  final Widget child;

  const MobileFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceFrame,
      body: Center(
        child: SizedBox(
          width: 390,
          height: 844,
          child: ClipRect(child: child),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/sync_service.dart';
import '../../theme/app_colors.dart';
import '../navigation/login_home_screen.dart';

/// Layar pembuka: menampilkan logo Kopi Kangenan selama 3 detik,
/// lalu berpindah ke [LoginHomeScreen].
///
/// Memakai aset asli `assets/logo.png` (512 × 512, persegi) sehingga
/// ditampilkan dengan `BoxFit.contain` di tengah latar putih agar tidak
/// terpotong.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    unawaited(_bukaBeranda());
  }

  /// Menunggu splash 3 detik sambil mengambil katalog dari REST API.
  ///
  /// Kalau API lambat atau mati, [SyncService.bootstrap] tetap kembali dan
  /// aplikasi memakai data bawaan dari `models/`.
  Future<void> _bukaBeranda() async {
    await Future.wait<void>([
      Future<void>.delayed(const Duration(seconds: 3)),
      SyncService.bootstrap(),
    ]);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
          errorBuilder: _logoFallback,
        ),
      ),
    );
  }

  static Widget _logoFallback(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const Icon(Icons.favorite, size: 120, color: AppColors.maroon);
  }
}

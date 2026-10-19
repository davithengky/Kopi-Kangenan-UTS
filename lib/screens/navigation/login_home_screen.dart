import 'package:flutter/material.dart';

import '../auth/auth_sheet.dart';
import 'main_navigation_screen.dart';

/// Shell utama setelah splash.
///
/// Menampilkan [MainNavigationScreen] sebagai latar, lalu langsung membuka
/// panel Login lewat [showAuthSheet] saat frame pertama selesai dirender.
/// Popup ini hanya bisa ditutup lewat tombol X (tidak bisa di-drag maupun
/// ditutup dengan mengetuk area gelap), dan menutupnya berarti masuk sebagai
/// tamu.
class LoginHomeScreen extends StatefulWidget {
  const LoginHomeScreen({super.key});

  @override
  State<LoginHomeScreen> createState() => _LoginHomeScreenState();
}

class _LoginHomeScreenState extends State<LoginHomeScreen> {
  /// Menandai popup sudah ditutup, supaya tidak terbuka lagi setelah ditutup
  /// atau setelah berhasil masuk.
  bool _popupDitutup = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bukaPopupLogin();
    });
  }

  Future<void> _bukaPopupLogin() async {
    if (!mounted || _popupDitutup) return;

    await showAuthSheet(
      context,
      onClosed: () {
        _popupDitutup = true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen();
  }
}

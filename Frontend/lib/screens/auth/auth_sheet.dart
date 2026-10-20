import 'package:flutter/material.dart';

import '../../providers/auth_store.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Menampilkan panel Login/Daftar sebagai bottom sheet di atas halaman yang
/// sedang terbuka.
///
/// Setelan sheet-nya sama persis dengan sebelumnya:
/// - latar diredupkan (`barrierColor` hitam 54%),
/// - tidak bisa di-drag (`enableDrag: false`),
/// - tidak bisa ditutup dengan mengetuk area gelap (`isDismissible: false`),
///   hanya lewat tombol X atau setelah berhasil masuk.
///
/// Dipakai oleh `LoginHomeScreen` (otomatis setelah splash) dan oleh tombol
/// "Masuk" di halaman Profil.
Future<void> showAuthSheet(BuildContext context, {VoidCallback? onClosed}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    enableDrag: false,
    isDismissible: false,
    builder: (sheetContext) => _AuthSheet(
      onClose: () {
        Navigator.of(sheetContext).pop();
        onClosed?.call();
      },
    ),
  );
}

/// Isi sheet: berpindah antara form Login dan form Daftar tanpa membuka route
/// baru, sehingga latarnya tidak menumpuk dan tombol X tetap menutup semuanya.
class _AuthSheet extends StatefulWidget {
  final VoidCallback onClose;

  const _AuthSheet({required this.onClose});

  @override
  State<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<_AuthSheet> {
  bool _tampilkanDaftar = false;

  void _berhasil(AuthUser user) {
    // Ambil messenger sebelum sheet ditutup, supaya pesannya tetap tampil di
    // halaman aplikasi setelah panel hilang.
    final messenger = ScaffoldMessenger.of(context);

    widget.onClose();
    messenger.showSnackBar(
      SnackBar(content: Text('Berhasil masuk. Selamat datang, ${user.name}!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tampilkanDaftar) {
      return RegisterScreen(
        onClose: widget.onClose,
        onLogin: () => setState(() => _tampilkanDaftar = false),
        onSuccess: _berhasil,
      );
    }

    return LoginScreen(
      onClose: widget.onClose,
      onRegister: () => setState(() => _tampilkanDaftar = true),
      onSuccess: _berhasil,
    );
  }
}

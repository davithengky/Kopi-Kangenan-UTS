import 'package:flutter/material.dart';

import '../../providers/auth_store.dart';
import '../../widgets/auth_panel.dart';

/// Panel **Login**.
///
/// Desainnya tidak berubah dari sebelumnya: panel putih melengkung radius 24 di
/// bawah, lebar 390, tinggi 75% layar, tombol X di kanan atas.
///
/// Yang berubah hanya logic-nya:
/// - Login sungguh-sungguh divalidasi dan diperiksa ke [AuthStore].
/// - Pesan kesalahan muncul lewat `SnackBar`, sama seperti sebelumnya.
/// - Berhasil masuk tidak lagi menumpuk `MainNavigationScreen` baru, tetapi
///   menutup panel lewat [onSuccess] sehingga pengguna langsung kembali ke
///   aplikasi yang sudah ada di belakangnya.
class LoginScreen extends StatefulWidget {
  /// Dipanggil saat tombol X ditekan: masuk sebagai tamu, tanpa akun.
  final VoidCallback onClose;

  /// Dipanggil saat "Daftar di sini" ditekan.
  final VoidCallback onRegister;

  /// Dipanggil setelah berhasil masuk.
  final ValueChanged<AuthUser> onSuccess;

  const LoginScreen({
    super.key,
    required this.onClose,
    required this.onRegister,
    required this.onSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _masuk() async {
    try {
      final user = await AuthStore.signIn(
        identifier: _identifierController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      widget.onSuccess(user);
    } on AuthException catch (error) {
      if (!mounted) return;
      _tampilkanPesan(error.message);
    }
  }

  /// Simulasi "Lanjutkan dengan Google": langsung masuk memakai akun Google
  /// contoh, tanpa meminta password.
  Future<void> _google() async {
    try {
      final user = await AuthStore.signInWithGoogle();
      if (!mounted) return;
      widget.onSuccess(user);
    } on AuthException catch (error) {
      if (!mounted) return;
      _tampilkanPesan(error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPanel(
      onClose: widget.onClose,
      children: [
        const AuthBrandHeader(subtitle: 'Masuk untuk melanjutkan'),
        const SizedBox(height: 26),
        AuthTextField(
          controller: _identifierController,
          hintText: 'Email atau Nomor HP',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        AuthPasswordField(
          controller: _passwordController,
          hintText: 'Password',
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _masuk(),
        ),
        const SizedBox(height: 20),
        AuthPrimaryButton(label: 'Login', onPressed: _masuk),
        const SizedBox(height: 20),
        const AuthOrDivider(),
        const SizedBox(height: 18),
        AuthGoogleButton(onPressed: _google),
        const SizedBox(height: 18),
        AuthSwitchText(
          question: 'Belum punya akun? ',
          action: 'Daftar di sini',
          onTap: widget.onRegister,
        ),
      ],
    );
  }
}

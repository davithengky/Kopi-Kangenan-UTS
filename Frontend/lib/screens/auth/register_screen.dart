import 'package:flutter/material.dart';

import '../../providers/auth_store.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_panel.dart';

/// Panel **Daftar**.
///
/// Halaman ini sebelumnya belum ada. Kerangkanya memakai [AuthPanel] yang sama
/// dengan panel Login, jadi tampilannya menyatu dengan desain yang sudah ada —
/// tidak ada gaya baru yang diperkenalkan.
class RegisterScreen extends StatefulWidget {
  /// Dipanggil saat tombol X ditekan.
  final VoidCallback onClose;

  /// Dipanggil saat "Masuk di sini" ditekan.
  final VoidCallback onLogin;

  /// Dipanggil setelah pendaftaran berhasil (langsung dianggap masuk).
  final ValueChanged<AuthUser> onSuccess;

  const RegisterScreen({
    super.key,
    required this.onClose,
    required this.onLogin,
    required this.onSuccess,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _daftar() async {
    try {
      final user = await AuthStore.signUp(
        name: _nameController.text,
        identifier: _identifierController.text,
        password: _passwordController.text,
        confirmPassword: _confirmController.text,
      );
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
        const AuthBrandHeader(subtitle: 'Daftar untuk mulai memesan'),
        const SizedBox(height: 26),
        AuthTextField(
          controller: _nameController,
          hintText: 'Nama Lengkap',
          icon: Icons.person_outline,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
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
          hintText:
              'Password (minimal ${AuthService.minimumPasswordLength} karakter)',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        AuthPasswordField(
          controller: _confirmController,
          hintText: 'Ulangi Password',
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _daftar(),
        ),
        const SizedBox(height: 20),
        AuthPrimaryButton(label: 'Daftar', onPressed: _daftar),
        const SizedBox(height: 18),
        AuthSwitchText(
          question: 'Sudah punya akun? ',
          action: 'Masuk di sini',
          onTap: widget.onLogin,
        ),
      ],
    );
  }
}

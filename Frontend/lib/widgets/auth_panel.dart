import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Kerangka panel putih melengkung yang dipakai panel **Login** dan **Daftar**.
///
/// Semua nilai di sini diambil apa adanya dari panel Login yang sudah ada, jadi
/// memindahkannya ke komponen terpisah tidak mengubah tampilan sedikit pun.
/// Tujuannya supaya form Login dan Daftar punya kerangka yang benar-benar sama.
///
/// Susunannya: panel selebar 390, tinggi 75% layar, menempel di bawah, sudut
/// atas radius 24, dengan tombol X di kanan atas.
class AuthPanel extends StatelessWidget {
  /// Dipanggil saat tombol X ditekan.
  final VoidCallback onClose;

  /// Isi form, sudah termasuk jarak antar elemennya.
  final List<Widget> children;

  const AuthPanel({super.key, required this.onClose, required this.children});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: 390,
        height: MediaQuery.of(context).size.height * 0.75,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: children,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Blok identitas di atas form: ikon hati, "kopi kangenan", dan subjudul.
class AuthBrandHeader extends StatelessWidget {
  /// Kalimat di bawah nama brand, mis. "Masuk untuk melanjutkan".
  final String subtitle;

  const AuthBrandHeader({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/logo.png', width: 56, height: 56),
        const SizedBox(height: 4),
        const Text(
          'kopi kangenan',
          style: TextStyle(
            color: AppColors.maroon,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}

/// Field isian bergaya panel Login: latar abu `0xFFF4F4F4`, radius 12, tanpa
/// garis tepi, dengan ikon di kiri.
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.fieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// Field password dengan tombol lihat/sembunyikan.
///
/// Status lihat/sembunyikan disimpan di dalam widget ini, jadi pemanggilnya
/// tidak perlu ikut mengurusnya.
class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: widget.controller,
      hintText: widget.hintText,
      icon: Icons.lock_outline,
      obscureText: _obscurePassword,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Tombol utama panel auth: tinggi 48, radius 12, latar maroon, teks putih bold.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.maroon,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Pembatas dengan tulisan "atau" di tengah.
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}

/// Tombol "Lanjutkan dengan Google".
class AuthGoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AuthGoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: const BorderSide(color: AppColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text('Lanjutkan dengan Google'),
      ),
    );
  }
}

/// Kalimat ajakan untuk berpindah antara Login dan Daftar, mis.
/// "Belum punya akun? **Daftar di sini**".
class AuthSwitchText extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback onTap;

  const AuthSwitchText({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text(
          question,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: AppColors.maroon,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

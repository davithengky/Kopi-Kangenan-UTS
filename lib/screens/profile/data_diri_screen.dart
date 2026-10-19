import 'package:flutter/material.dart';

import '../../providers/auth_store.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ui.dart';
import '../auth/auth_sheet.dart';

/// Halaman Data Diri (PRD F3): lihat dan ubah nama, email/nomor HP, dan
/// password.
class DataDiriScreen extends StatefulWidget {
  const DataDiriScreen({super.key});

  @override
  State<DataDiriScreen> createState() => _DataDiriScreenState();
}

class _DataDiriScreenState extends State<DataDiriScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _identifier = TextEditingController();
  final TextEditingController _oldPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool _editData = false;
  bool _gantiPassword = false;

  @override
  void initState() {
    super.initState();
    _isiUlang();
  }

  void _isiUlang() {
    final user = AuthStore.currentUser.value;
    _name.text = user?.name ?? '';
    _identifier.text = user?.identifier ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _identifier.dispose();
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _simpanData() async {
    try {
      await AuthStore.saveProfile(
        name: _name.text,
        identifier: _identifier.text,
      );
      if (!mounted) return;
      setState(() => _editData = false);
      showAppMessage(context, 'Data diri berhasil diperbarui.');
    } on AuthException catch (error) {
      if (!mounted) return;
      showAppMessage(context, error.message);
    }
  }

  Future<void> _simpanPassword() async {
    try {
      await AuthStore.savePassword(
        currentPassword: _oldPassword.text,
        newPassword: _newPassword.text,
        confirmPassword: _confirmPassword.text,
      );
      if (!mounted) return;
      setState(() => _gantiPassword = false);
      _oldPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
      showAppMessage(context, 'Password berhasil diganti.');
    } on AuthException catch (error) {
      if (!mounted) return;
      showAppMessage(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthUser?>(
      valueListenable: AuthStore.currentUser,
      builder: (context, user, _) {
        if (user == null) {
          return AppPage(
            title: 'Data Diri',
            scrollable: false,
            children: [
              Expanded(
                child: AppEmptyState(
                  icon: Icons.person_off_outlined,
                  title: 'Belum masuk',
                  message:
                      'Masuk dulu untuk melihat dan mengubah data dirimu.',
                  actionLabel: 'Masuk',
                  onAction: () => showAuthSheet(context),
                ),
              ),
            ],
          );
        }

        return AppPage(
          title: 'Data Diri',
          children: [
            AppCard(
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceBand,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.identifier,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Data Akun',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_editData) {
                            _isiUlang();
                          }
                          setState(() => _editData = !_editData);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.maroon,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(_editData ? 'Batal' : 'Ubah'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!_editData) ...[
                    const AppLabelValue(label: 'Nama', value: ''),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Email / Nomor HP',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user.identifier,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    _field(_name, 'Nama Lengkap'),
                    const SizedBox(height: 12),
                    _field(
                      _identifier,
                      'Email atau Nomor HP',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    AppPrimaryButton(
                      label: 'Simpan Data',
                      onPressed: _simpanData,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => _gantiPassword = !_gantiPassword),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.maroon,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(
                          _gantiPassword ? 'Batal' : 'Ganti Password',
                        ),
                      ),
                    ],
                  ),
                  if (_gantiPassword) ...[
                    const SizedBox(height: 8),
                    _field(
                      _oldPassword,
                      'Password lama',
                      obscure: true,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      _newPassword,
                      'Password baru (min ${AuthService.minimumPasswordLength} karakter)',
                      obscure: true,
                    ),
                    const SizedBox(height: 12),
                    _field(_confirmPassword, 'Ulangi password baru', obscure: true),
                    const SizedBox(height: 14),
                    AppPrimaryButton(
                      label: 'Simpan Password',
                      onPressed: _simpanPassword,
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Password dipakai untuk masuk ke akunmu.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
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

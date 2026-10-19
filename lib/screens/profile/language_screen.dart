import 'package:flutter/material.dart';

import '../../providers/settings_store.dart';
import '../../theme/app_colors.dart';
import '../../utils/strings.dart';
import '../../widgets/ui.dart';

/// Halaman Ubah Bahasa (PRD F49).
///
/// Pilihan bahasa langsung dipakai oleh label bottom navigation, sehingga
/// perubahannya terlihat di seluruh aplikasi.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: SettingsStore.language,
      builder: (context, current, _) {
        return AppPage(
          title: 'Ubah Bahasa Aplikasi',
          children: [
            const Text(
              'Pilih bahasa yang dipakai di seluruh aplikasi.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            for (final language in AppLanguage.values) ...[
              _languageTile(context, language, current == language),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            AppCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Contoh penerapan: ${Strings.beranda(current)} / '
                      '${Strings.saya(current)} pada bottom navigation.',
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.5,
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

  Widget _languageTile(
    BuildContext context,
    AppLanguage language,
    bool selected,
  ) {
    return GestureDetector(
      onTap: () {
        SettingsStore.setLanguage(language);
        showAppMessage(context, 'Bahasa diubah ke ${language.label}.');
      },
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                language.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.maroon : AppColors.borderSoft,
            ),
          ],
        ),
      ),
    );
  }
}

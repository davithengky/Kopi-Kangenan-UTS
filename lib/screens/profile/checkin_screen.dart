import 'package:flutter/material.dart';

import '../../providers/member_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/kangenan_coin.dart';
import '../../widgets/ui.dart';

/// Halaman Daily Check-In (PRD F44).
class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: MemberStore.checkedDays,
      builder: (context, checkedDays, _) {
        final done = checkedDays.length;

        return AppPage(
          title: 'Daily Check-In',
          bottomBar: AppBottomBar(
            child: AppPrimaryButton(
              label: done >= MemberStore.maxCheckInDays
                  ? 'Sudah Check-In 6 Hari'
                  : 'Check-In Hari Ini',
              onPressed: done >= MemberStore.maxCheckInDays
                  ? null
                  : () {
                      final reward = MemberStore.checkIn();
                      showAppMessage(
                        context,
                        'Check-In berhasil! Hadiah: $reward',
                      );
                    },
            ),
          ),
          children: [
            AppCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.maroon,
                    size: 34,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$done / ${MemberStore.maxCheckInDays} hari',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Check-in setiap hari untuk mengumpulkan poin dan voucher. '
                    'Periode berakhir 31 Okt 2026.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const AppSectionLabel(text: 'Hadiah 6 hari'),
            for (int i = 0; i < MemberStore.maxCheckInDays; i++) ...[
              _dayRow(context, i, done, checkedDays.contains(i + 1)),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 6),
            const Text(
              'Reward diklaim otomatis ke akunmu dan dicatat di Riwayat Poin.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dayRow(BuildContext context, int index, int done, bool checked) {
    final isToday = index == done;
    final voucher = MemberStore.dailyRewards[index].contains('Voucher');

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: checked
                  ? AppColors.gold.withValues(alpha: 0.16)
                  : AppColors.fieldFill,
              shape: BoxShape.circle,
            ),
            child: checked || voucher
                ? Icon(
                    checked ? Icons.check : Icons.confirmation_num_outlined,
                    size: 20,
                    color: checked ? AppColors.gold : AppColors.textSecondary,
                  )
                // Koin "K" Kangenan, bukan lagi ikon dolar.
                : KangenanCoin(
                    size: 22,
                    color: checked
                        ? AppColors.goldCoin
                        : AppColors.textSecondary,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hari ke-${index + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  MemberStore.dailyRewards[index],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (checked)
            const Text(
              'Selesai',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.green,
              ),
            )
          else if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.pink,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Hari ini',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maroon,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

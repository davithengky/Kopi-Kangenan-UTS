import 'package:flutter/material.dart';

import '../../models/point_entry.dart';
import '../../providers/member_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ui.dart';

/// Riwayat poin (PRD F45).
class PointsHistoryScreen extends StatelessWidget {
  const PointsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: MemberStore.points,
      builder: (context, points, _) {
        return ValueListenableBuilder<List<PointEntry>>(
          valueListenable: MemberStore.history,
          builder: (context, history, _) {
            return AppPage(
              title: 'Kangenan Points',
              children: [
                AppCard(
                  child: Column(
                    children: [
                      const Text(
                        'Poin kamu',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$points pts',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: AppColors.maroon,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '1 Kangenan Point = Rp1 saat checkout.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const AppSectionLabel(text: 'Riwayat poin'),
                if (history.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: AppEmptyState(
                      icon: Icons.monetization_on_outlined,
                      title: 'Belum ada riwayat poin',
                      message:
                          'Poin didapat dari pesanan dan Daily Check-In. '
                          'Riwayatnya akan tampil di sini.',
                    ),
                  )
                else
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < history.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1, color: AppColors.border),
                          _entry(history[i]),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _entry(PointEntry entry) {
    final positive = entry.delta >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (positive ? AppColors.green : AppColors.red).withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              positive ? Icons.add : Icons.remove,
              size: 18,
              color: positive ? AppColors.green : AppColors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  entry.date,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            entry.delta == 0
                ? 'Voucher'
                : '${positive ? '+' : ''}${entry.delta}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: entry.delta == 0
                  ? AppColors.maroon
                  : positive
                  ? AppColors.green
                  : AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/outlet.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ui.dart';

/// Modal konfirmasi pickup (PRD F26).
///
/// Menampilkan ikon pickup, nama outlet, dan instruksi pengambilan. Dipakai saat
/// pembeli mengetuk baris "Pickup di Counter" di Checkout.
Future<void> showPickupConfirmSheet(
  BuildContext context, {
  required Outlet outlet,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.greenStoreBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront,
                  color: AppColors.greenStorefront,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pickup di Counter',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              outlet.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.maroon,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Ambil pesananmu di Area Pickup di dalam outlet. Tunjukkan '
              'nomor pesanan ke kasir, pesanan akan dipanggil sesuai nomor.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            AppPrimaryButton(
              label: 'Ya, Sudah Benar',
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      );
    },
  );
}

/// Modal penjadwalan pesanan (PRD F35).
///
/// Mengembalikan waktu yang dipilih, atau `null` kalau dibatalkan.
Future<DateTime?> showScheduleSheet(
  BuildContext context, {
  DateTime? initial,
}) {
  final now = DateTime.now();
  final days = List<DateTime>.generate(
    7,
    (index) => DateTime(now.year, now.month, now.day).add(Duration(days: index)),
  );

  const slots = <String>[
    '07.00 - 08.00',
    '09.00 - 10.00',
    '11.00 - 12.00',
    '13.00 - 14.00',
    '15.00 - 16.00',
    '17.00 - 18.00',
    '19.00 - 20.00',
  ];

  int selectedDay = 0;
  int selectedSlot = 1;

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Jadwalkan Pesanan',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pilih tanggal dan jam pengambilan atau pengiriman.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                const AppSectionLabel(text: 'Tanggal'),
                SizedBox(
                  height: 76,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: days.length,
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final active = selectedDay == index;

                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => selectedDay = index),
                        child: Container(
                          width: 62,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.maroon
                                : AppColors.surfaceProfile,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: active
                                  ? AppColors.maroon
                                  : AppColors.border,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                index == 0
                                    ? 'Hari ini'
                                    : index == 1
                                    ? 'Besok'
                                    : '${day.day}/${day.month}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: active
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                const [
                                  'Sen',
                                  'Sel',
                                  'Rab',
                                  'Kam',
                                  'Jum',
                                  'Sab',
                                  'Min',
                                ][day.weekday - 1],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: active
                                      ? Colors.white70
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const AppSectionLabel(text: 'Jam'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(slots.length, (index) {
                    final active = selectedSlot == index;

                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedSlot = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.pink
                              : AppColors.surfaceProfile,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: active
                                ? AppColors.maroon
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          slots[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? AppColors.maroon
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 22),
                AppPrimaryButton(
                  label: 'Simpan Jadwal',
                  onPressed: () {
                    final slot = slots[selectedSlot];
                    final startHour =
                        int.parse(slot.substring(0, 2));
                    final day = days[selectedDay];

                    Navigator.of(sheetContext).pop(
                      DateTime(day.year, day.month, day.day, startHour),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

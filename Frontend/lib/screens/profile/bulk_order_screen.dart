import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/ui.dart';
import 'static_page_screen.dart';

/// Halaman "Pesanan Jumlah Besar" (catering, kantor, acara).
///
/// Isinya simulasi: pembeli mengisi perkiraan jumlah pesanan, lalu diarahkan ke
/// layanan WhatsApp.
class BulkOrderScreen extends StatefulWidget {
  const BulkOrderScreen({super.key});

  @override
  State<BulkOrderScreen> createState() => _BulkOrderScreenState();
}

class _BulkOrderScreenState extends State<BulkOrderScreen> {
  final TextEditingController _jumlah = TextEditingController(text: '50');
  final TextEditingController _tanggal = TextEditingController();
  String _kebutuhan = 'Kantor / Rapat';

  static const List<String> _kebutuhanOptions = [
    'Kantor / Rapat',
    'Catering & Wedding',
    'Acara Kampus',
    'Lainnya',
  ];

  @override
  void dispose() {
    _jumlah.dispose();
    _tanggal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Pesanan Jumlah Besar',
      bottomBar: AppBottomBar(
        child: Row(
          children: [
            Expanded(
              child: AppOutlineButton(
                label: 'Lihat Paket',
                icon: Icons.local_cafe_outlined,
                onPressed: () => showAppMessage(
                  context,
                  'Paket catering: 20 cup Rp380.000, 50 cup Rp900.000.',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppPrimaryButton(
                label: 'Hubungi Kami',
                icon: Icons.support_agent,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WhatsappServiceScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pesan untuk acara?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pesanan di atas 20 cup bisa dipesan lewat tim kami supaya harga '
                'lebih hemat dan pengiriman tepat waktu.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
              const Divider(height: 26, color: AppColors.border),
              const AppSectionLabel(text: 'Perkiraan jumlah cup'),
              TextField(
                controller: _jumlah,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'mis. 50',
                  filled: true,
                  fillColor: AppColors.fieldFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const AppSectionLabel(text: 'Tanggal acara'),
              TextField(
                controller: _tanggal,
                decoration: InputDecoration(
                  hintText: 'mis. 24 Okt 2026',
                  filled: true,
                  fillColor: AppColors.fieldFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const AppSectionLabel(text: 'Jenis kebutuhan'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kebutuhanOptions.map((option) {
                  final active = _kebutuhan == option;

                  return GestureDetector(
                    onTap: () => setState(() => _kebutuhan = option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.pink
                            : AppColors.surfaceProfile,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? AppColors.maroon : AppColors.border,
                        ),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: active
                              ? AppColors.maroon
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              AppLabelValue(label: 'Minimal pesanan', value: '20 cup'),
              AppLabelValue(label: 'Gratis antar', value: 'Radius 5 km'),
              AppLabelValue(label: 'Estimasi', value: 'H-2 pemesanan'),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/merch.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency.dart';
import '../../widgets/ui.dart';
import 'merch_detail_screen.dart';

/// Halaman Scan Merchandise (PRD F48).
///
/// Ini simulasi: tidak memakai kamera, menekan "Mulai Scan" akan menampilkan
/// hasil pemindaian contoh setelah jeda singkat.
class ScanMerchScreen extends StatefulWidget {
  const ScanMerchScreen({super.key});

  @override
  State<ScanMerchScreen> createState() => _ScanMerchScreenState();
}

class _ScanMerchScreenState extends State<ScanMerchScreen> {
  bool _scanning = false;
  MerchProduct? _result;

  Future<void> _scan() async {
    setState(() {
      _scanning = true;
      _result = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _scanning = false;
      _result = kScanMerchSample;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Scan Merchandise',
      children: [
        AppCard(
          child: Column(
            children: [
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _scanning
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _result == null
                                  ? Icons.qr_code_scanner
                                  : Icons.check_circle_outline,
                              color: Colors.white,
                              size: 58,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _result == null
                                  ? 'Arahkan kamera ke QR di produk'
                                  : 'QR berhasil dipindai',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              AppPrimaryButton(
                label: _scanning ? 'Memindai…' : 'Mulai Scan',
                onPressed: _scanning ? null : _scan,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_result != null) ...[
          const AppSectionLabel(text: 'Hasil pemindaian'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: Image.asset(
                        _result!.image,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.local_mall_outlined),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _result!.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatRupiah(_result!.price),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.maroon,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _result!.description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                AppPrimaryButton(
                  label: 'Lihat Detail Merchandise',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MerchDetailScreen(product: _result!),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

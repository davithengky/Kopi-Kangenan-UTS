import 'package:flutter/material.dart';

import '../../providers/catalog_store.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency.dart';
import 'merch_detail_screen.dart';
import 'scan_merch_screen.dart';

/// Halaman Merchandise (PRD F46–F48).
///
/// Katalognya sekarang berasal dari `kMerchCatalog` di `models/merch.dart`
/// (sebelumnya produknya ditulis di dalam widget — lihat `docs/design.md`
/// §14.3). Kartunya bisa diketuk untuk membuka detail merchandise.
class MerchScreen extends StatelessWidget {
  const MerchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(
              children: [
                SizedBox(
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text(
                        'Merchandise',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ScanMerchScreen(),
                              ),
                            ),
                            icon: const Icon(
                              Icons.qr_code_scanner,
                              color: AppColors.maroon,
                            ),
                            tooltip: 'Scan Merchandise',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Banner promo tumbler
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 24),
                          color: Colors.white,
                          child: Image.asset(
                            'assets/merch/promo.tumbler.png',
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                height: 160,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 32,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Custom Merchandise',
                                style: TextStyle(
                                  color: AppColors.goldMerch,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 14),
                              SizedBox(
                                width: 180,
                                child: Divider(
                                  color: AppColors.goldMerch,
                                  thickness: 4,
                                  height: 2,
                                ),
                              ),
                              SizedBox(height: 22),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: CatalogStore.merch.value.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 24,
                                  childAspectRatio: 0.57,
                                ),
                            itemBuilder: (context, index) {
                              final product = CatalogStore.merch.value[index];

                              return InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MerchDetailScreen(product: product),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Image.asset(
                                          product.image,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Center(
                                                  child: Icon(
                                                    Icons
                                                        .image_not_supported_outlined,
                                                    size: 32,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 4,
                                      ),
                                      color: AppColors.greenBadgeBg,
                                      child: const Text(
                                        'Gratis Ukir',
                                        style: TextStyle(
                                          color: AppColors.greenBadgeText,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      formatRupiah(product.price),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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

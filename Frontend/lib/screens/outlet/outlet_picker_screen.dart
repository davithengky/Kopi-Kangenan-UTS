import 'package:flutter/material.dart';

import '../../models/address.dart';
import '../../models/outlet.dart';
import '../../providers/address_store.dart';
import '../../providers/catalog_store.dart';
import '../../providers/outlet_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ui.dart';
import '../profile/address_screen.dart';

/// Halaman daftar outlet dan pilihan Delivery/Pickup (PRD F7).
class OutletPickerScreen extends StatelessWidget {
  const OutletPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FulfilmentMode>(
      valueListenable: OutletStore.mode,
      builder: (context, mode, _) {
        return AppPage(
          title: 'Pilih Outlet',
          children: [
            _modeSelector(context, mode),
            const SizedBox(height: 16),
            if (mode == FulfilmentMode.delivery) ...[
              _addressCard(context),
              const SizedBox(height: 16),
            ],
            const AppSectionLabel(text: 'Outlet terdekat'),
            ValueListenableBuilder<Outlet>(
              valueListenable: OutletStore.selected,
              builder: (context, selected, _) => Column(
                children: [
                  for (final outlet in CatalogStore.outlets.value)
                    _outletTile(context, outlet, outlet.name == selected.name),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pesanan hanya bisa diambil atau dikirim dari satu outlet. '
              'Pastikan outlet pilihanmu sudah benar.',
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

  /// Pemilih Delivery/Pickup memakai pola tab-pill yang sama dengan tab VIP
  /// (`docs/design.md` §10.4): container `0xFFE0E7EE` radius 15, tab aktif
  /// putih radius 9 dengan border `0xFFE4E5E8`.
  Widget _modeSelector(BuildContext context, FulfilmentMode mode) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.blueGreyTab,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: FulfilmentMode.values.map((item) {
          final active = item == mode;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => OutletStore.setMode(item),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: active
                        ? AppColors.blueTabBorder
                        : Colors.transparent,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textVip,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _addressCard(BuildContext context) {
    return ValueListenableBuilder<List<Address>>(
      valueListenable: AddressStore.addresses,
      builder: (context, addresses, _) {
        final address = AddressStore.defaultAddress;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddressScreen()),
          ),
          child: AppCard(
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.maroon,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address == null
                            ? 'Belum ada alamat'
                            : 'Kirim ke ${address.label}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address?.detail ?? 'Tambahkan alamat pengiriman dulu.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _outletTile(BuildContext context, Outlet outlet, bool selected) {
    return GestureDetector(
      onTap: () {
        OutletStore.select(outlet);
        showAppMessage(context, 'Outlet diubah ke ${outlet.name}.');
        Navigator.maybePop(context);
      },
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.maroon : AppColors.borderSoft,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          outlet.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (outlet.distance.isNotEmpty)
                        Text(
                          outlet.distance,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    outlet.address,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

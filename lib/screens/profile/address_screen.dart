import 'package:flutter/material.dart';

import '../../models/address.dart';
import '../../providers/address_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ui.dart';

/// Daftar alamat pengiriman (PRD F4).
class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Address>>(
      valueListenable: AddressStore.addresses,
      builder: (context, addresses, _) {
        return AppPage(
          title: 'Alamat Pengiriman',
          children: [
            if (addresses.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: AppEmptyState(
                  icon: Icons.location_off_outlined,
                  title: 'Belum ada alamat',
                  message:
                      'Tambahkan alamat pengiriman supaya pesanan Delivery bisa '
                      'diantar ke tempatmu.',
                  actionLabel: 'Tambah Alamat',
                  onAction: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddressFormScreen(),
                    ),
                  ),
                ),
              )
            else ...[
              for (final address in addresses) ...[
                _addressCard(context, address),
                const SizedBox(height: 12),
              ],
              AppOutlineButton(
                label: 'Tambah Alamat Baru',
                icon: Icons.add_location_alt_outlined,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressFormScreen(),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _addressCard(BuildContext context, Address address) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.pink,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  address.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon,
                  ),
                ),
              ),
              if (address.isDefault) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenBadgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Utama',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenBadgeText,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            address.recipient,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(
            address.phone,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            address.detail,
            style: const TextStyle(fontSize: 12, height: 1.5),
          ),
          if (address.note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Patokan: ${address.note}',
              style: const TextStyle(
                fontSize: 11,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const Divider(height: 24, color: AppColors.border),
          Row(
            children: [
              if (!address.isDefault)
                TextButton(
                  onPressed: () {
                    AddressStore.setDefault(address.id);
                    showAppMessage(
                      context,
                      '${address.label} jadi alamat utama.',
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: const Text('Jadikan Utama'),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddressFormScreen(address: address),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.maroon,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  AddressStore.remove(address.id);
                  showAppMessage(context, 'Alamat ${address.label} dihapus.');
                },
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Hapus'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.red,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Form tambah/edit alamat (PRD F4).
class AddressFormScreen extends StatefulWidget {
  final Address? address;

  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  late final TextEditingController _label;
  late final TextEditingController _recipient;
  late final TextEditingController _phone;
  late final TextEditingController _detail;
  late final TextEditingController _note;

  static const List<String> _labels = ['Rumah', 'Kantor', 'Kos', 'Lainnya'];

  late String _selectedLabel;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();

    final address = widget.address;
    _label = TextEditingController(text: address?.label ?? '');
    _recipient = TextEditingController(text: address?.recipient ?? '');
    _phone = TextEditingController(text: address?.phone ?? '');
    _detail = TextEditingController(text: address?.detail ?? '');
    _note = TextEditingController(text: address?.note ?? '');
    _selectedLabel = address?.label ?? _labels.first;
    _isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _label.dispose();
    _recipient.dispose();
    _phone.dispose();
    _detail.dispose();
    _note.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_recipient.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _detail.text.trim().isEmpty) {
      showAppMessage(context, 'Nama, nomor HP, dan alamat wajib diisi.');
      return;
    }

    if (widget.address == null) {
      AddressStore.add(
        label: _selectedLabel,
        recipient: _recipient.text.trim(),
        phone: _phone.text.trim(),
        detail: _detail.text.trim(),
        note: _note.text.trim(),
        isDefault: _isDefault,
      );
      showAppMessage(context, 'Alamat baru disimpan.');
    } else {
      AddressStore.update(
        widget.address!.copyWith(
          label: _selectedLabel,
          recipient: _recipient.text.trim(),
          phone: _phone.text.trim(),
          detail: _detail.text.trim(),
          note: _note.text.trim(),
          isDefault: _isDefault,
        ),
      );
      showAppMessage(context, 'Alamat diperbarui.');
    }

    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: widget.address == null ? 'Tambah Alamat' : 'Edit Alamat',
      bottomBar: AppBottomBar(
        child: AppPrimaryButton(label: 'Simpan Alamat', onPressed: _simpan),
      ),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionLabel(text: 'Label alamat'),
              Wrap(
                spacing: 8,
                children: _labels.map((label) {
                  final active = _selectedLabel == label;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedLabel = label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
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
                        label,
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
              const SizedBox(height: 16),
              _field(_recipient, 'Nama penerima'),
              const SizedBox(height: 12),
              _field(_phone, 'Nomor HP', keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_detail, 'Alamat lengkap', maxLines: 3),
              const SizedBox(height: 12),
              _field(_note, 'Patokan (opsional)'),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _isDefault,
                onChanged: (value) =>
                    setState(() => _isDefault = value ?? false),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.maroon,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'Jadikan alamat utama',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/address.dart';
import '../services/sync_service.dart';

/// Daftar alamat pengiriman tersimpan (PRD F4), hanya di memori.
class AddressStore {
  AddressStore._();

  static int _counter = 2;

  static final ValueNotifier<List<Address>> addresses =
      ValueNotifier<List<Address>>([
        const Address(
          id: 'addr-1',
          label: 'Rumah',
          recipient: 'Jibi',
          phone: '0812-3456-7890',
          detail: 'Jl. Ketintang Baru No. 21, Gayungan, Surabaya',
          note: 'Pagar hitam, sebelah warung Bu Sri',
          isDefault: true,
        ),
      ]);

  static Address? get defaultAddress {
    if (addresses.value.isEmpty) return null;

    for (final address in addresses.value) {
      if (address.isDefault) return address;
    }

    return addresses.value.first;
  }

  static Address add({
    required String label,
    required String recipient,
    required String phone,
    required String detail,
    String note = '',
    bool isDefault = false,
  }) {
    final address = Address(
      id: 'addr-${_counter++}',
      label: label,
      recipient: recipient,
      phone: phone,
      detail: detail,
      note: note,
      isDefault: isDefault || addresses.value.isEmpty,
    );

    if (address.isDefault) {
      _clearDefaultFlag();
    }

    addresses.value = [...addresses.value, address];

    unawaited(
      SyncService.pushAddressCreate(
        label: address.label,
        recipient: address.recipient,
        phone: address.phone,
        detail: address.detail,
        note: address.note,
        isDefault: address.isDefault,
      ),
    );

    return address;
  }

  /// Mengganti seluruh daftar dengan data dari server.
  static void replaceAll(List<Address> incoming) {
    addresses.value = incoming;
    _counter = incoming.length + 1;
  }

  static void update(Address address) {
    if (address.isDefault) {
      _clearDefaultFlag();
    }

    addresses.value = addresses.value
        .map((item) => item.id == address.id ? address : item)
        .toList();
  }

  static void remove(String id) {
    addresses.value = addresses.value.where((item) => item.id != id).toList();

    unawaited(SyncService.pushAddressDelete(id));
  }

  static void setDefault(String id) {
    addresses.value = addresses.value
        .map((item) => item.copyWith(isDefault: item.id == id))
        .toList();
  }

  static void _clearDefaultFlag() {
    addresses.value = addresses.value
        .map((item) => item.isDefault ? item.copyWith(isDefault: false) : item)
        .toList();
  }

  static void reset() {
    addresses.value = [
      const Address(
        id: 'addr-1',
        label: 'Rumah',
        recipient: 'Jibi',
        phone: '0812-3456-7890',
        detail: 'Jl. Ketintang Baru No. 21, Gayungan, Surabaya',
        note: 'Pagar hitam, sebelah warung Bu Sri',
        isDefault: true,
      ),
    ];
    _counter = 2;
  }
}

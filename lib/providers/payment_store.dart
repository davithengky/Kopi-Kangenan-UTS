import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/payment_method.dart';
import '../services/sync_service.dart';

/// Metode pembayaran yang sedang dipakai dan yang sudah dihubungkan ke akun.
class PaymentStore {
  PaymentStore._();

  static final ValueNotifier<String> selectedId = ValueNotifier<String>('qris');

  /// Metode yang sudah "dihubungkan" (mis. GoPay).
  static final ValueNotifier<Set<String>> connectedIds =
      ValueNotifier<Set<String>>(<String>{});

  static PaymentMethod get selected {
    for (final method in kPaymentMethods) {
      if (method.id == selectedId.value) return method;
    }

    return kPaymentMethods.first;
  }

  static bool isConnected(PaymentMethod method) =>
      !method.needsConnection || connectedIds.value.contains(method.id);

  static void select(PaymentMethod method) {
    if (!isConnected(method)) return;
    selectedId.value = method.id;

    unawaited(SyncService.pushPaymentSelect(method.id));
  }

  static void connect(String id) {
    connectedIds.value = {...connectedIds.value, id};

    unawaited(SyncService.pushPaymentConnect(id));
  }

  static void reset() {
    selectedId.value = 'qris';
    connectedIds.value = <String>{};
  }
}

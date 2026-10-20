import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/sync_service.dart';
import '../utils/strings.dart';

/// Preferensi aplikasi: bahasa, notifikasi, dan biometrik (PRD F49/F50).
class SettingsStore {
  SettingsStore._();

  static final ValueNotifier<AppLanguage> language =
      ValueNotifier<AppLanguage>(AppLanguage.indonesia);

  /// Notifikasi promo (mis. voucher baru) dan status pesanan.
  static final ValueNotifier<bool> notifPromo = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> notifPesanan = ValueNotifier<bool>(true);

  /// "Aktifkan Biometric ID" di halaman Profil.
  static final ValueNotifier<bool> biometric = ValueNotifier<bool>(false);

  static void setLanguage(AppLanguage value) {
    language.value = value;
    unawaited(SyncService.pushSettings());
  }

  static void setNotifPromo(bool value) {
    notifPromo.value = value;
    unawaited(SyncService.pushSettings());
  }

  static void setNotifPesanan(bool value) {
    notifPesanan.value = value;
    unawaited(SyncService.pushSettings());
  }

  static void setBiometric(bool value) {
    biometric.value = value;
    unawaited(SyncService.pushSettings());
  }

  static void reset() {
    language.value = AppLanguage.indonesia;
    notifPromo.value = true;
    notifPesanan.value = true;
    biometric.value = false;
  }
}

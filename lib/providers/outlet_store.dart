import 'package:flutter/foundation.dart';

import '../models/outlet.dart';

/// Outlet yang sedang dipilih beserta mode pengambilannya.
///
/// Dipakai bersama oleh Beranda, Menu, dan Checkout lewat
/// `ValueListenableBuilder`, jadi mengubah outlet di satu layar langsung
/// terlihat di layar lain. Sama seperti store lain: hanya di memori.
class OutletStore {
  OutletStore._();

  static final ValueNotifier<Outlet> selected = ValueNotifier<Outlet>(
    kDefaultOutlet,
  );

  static final ValueNotifier<FulfilmentMode> mode =
      ValueNotifier<FulfilmentMode>(FulfilmentMode.pickup);

  static void select(Outlet outlet) {
    selected.value = outlet;
  }

  static void setMode(FulfilmentMode value) {
    mode.value = value;
  }

  /// Memakai outlet default dari server, tetapi hanya kalau pengguna belum
  /// memilih outlet lain.
  static void applyRemoteDefault(Outlet outlet) {
    if (selected.value.name == kDefaultOutlet.name) {
      selected.value = outlet;
    }
  }

  /// Mengembalikan semuanya ke keadaan awal. Dipakai oleh tes.
  static void reset() {
    selected.value = kDefaultOutlet;
    mode.value = FulfilmentMode.pickup;
  }
}

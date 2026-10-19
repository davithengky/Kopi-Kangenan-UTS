import 'package:flutter/foundation.dart';

import '../config/api.dart';
import '../models/address.dart';
import '../models/cart.dart';
import '../models/inbox.dart';
import '../models/merch.dart';
import '../models/order.dart';
import '../models/outlet.dart';
import '../models/point_entry.dart';
import '../models/product.dart';
import '../models/voucher.dart';
import '../providers/address_store.dart';
import '../providers/catalog_store.dart';
import '../providers/inbox_store.dart';
import '../providers/member_store.dart';
import '../providers/order_store.dart';
import '../providers/outlet_store.dart';
import '../providers/payment_store.dart';
import '../providers/settings_store.dart';
import '../providers/voucher_store.dart';
import '../utils/strings.dart';
import 'api_client.dart';

/// Menghubungkan store aplikasi dengan REST API Kopi Kangenan.
///
/// Cara kerjanya "offline-first":
/// - **Tarik data** — [bootstrap] mengisi katalog dari API saat aplikasi
///   dibuka, dan [refreshUserData] menyegarkan data milik pengguna setelah
///   login. Nilai awal setiap store sudah benar (data bawaan di `models/`),
///   jadi aplikasi tetap tampil normal kalau API tidak bisa dihubungi.
/// - **Kirim perubahan** — store mengubah nilai lokal lebih dulu supaya
///   tampilan langsung berubah, lalu memanggil fungsi `push...` di sini.
///
/// Semua fungsi di kelas ini aman dipanggil saat API mati: kegagalan hanya
/// dicatat lewat [debugPrint] dan tidak menghentikan aplikasi.
class SyncService {
  const SyncService._();

  /// Mengambil katalog lalu (kalau ada token) data pengguna.
  static Future<void> bootstrap() async {
    if (!ApiConfig.enabled) return;

    await loadCatalog();

    if (ApiConfig.hasToken) {
      await refreshUserData();
    }
  }

  /// Mengambil katalog menu, merchandise, dan outlet dari API.
  static Future<void> loadCatalog() async {
    if (!ApiConfig.enabled) return;

    await _guard(() async {
      final products = listOf(
        await ApiClient.get('/products', query: {'type': 'menu'}),
      );
      if (products.isNotEmpty) {
        CatalogStore.menu.value = _menuFromApi(products);
      }

      final merchItems = listOf(await ApiClient.get('/merch'));
      if (merchItems.isNotEmpty) {
        CatalogStore.merch.value = merchItems
            .map(_merchFromApi)
            .toList(growable: false);
      }

      final outletItems = listOf(await ApiClient.get('/outlets'));
      if (outletItems.isNotEmpty) {
        CatalogStore.outlets.value = outletItems
            .map(_outletFromApi)
            .toList(growable: false);

        for (final json in outletItems) {
          if (json['is_default'] == true) {
            OutletStore.applyRemoteDefault(_outletFromApi(json));
            break;
          }
        }
      }
    });
  }

  /// Menyegarkan semua data milik pengguna yang sedang masuk.
  static Future<void> refreshUserData() async {
    if (!ApiConfig.canSync) return;

    await _guard(() async {
      await _refreshMembership();
      await _refreshOrders();
      await _refreshVouchers();
      await _refreshAddresses();
      await _refreshInbox();
      await _refreshSettings();
      await _refreshPayments();
    });
  }

  // --- Pengiriman perubahan ---------------------------------------------

  /// Membuat pesanan di server. Mengembalikan `null` kalau tidak bisa.
  static Future<Order?> createOrder({
    required List<CartItem> items,
    required int bagFee,
    required int pointsUsed,
    required String paymentMethodId,
    required String fulfilment,
    int? outletId,
    DateTime? scheduledAt,
    String? voucherCode,
  }) async {
    if (!ApiConfig.canSync) return null;

    try {
      final response = await ApiClient.post(
        '/orders',
        body: {
          'items': items
              .map(
                (item) => {
                  'name': item.name,
                  'image': item.image,
                  'base_price': item.basePrice,
                  'unit_price': item.unitPrice,
                  'quantity': item.quantity,
                  'size': item.size,
                  'milk': item.milk,
                  'sugar': item.sugar,
                  'ice': item.ice,
                  'toppings': item.toppings,
                  'syrups': item.syrups,
                  'note': item.note,
                },
              )
              .toList(),
          'outlet_id': outletId,
          'bag_fee': bagFee,
          'points_used': pointsUsed,
          'payment_method_id': paymentMethodId,
          'fulfilment': fulfilment,
          if (voucherCode != null && voucherCode.isNotEmpty)
            'voucher_code': voucherCode,
          if (scheduledAt != null)
            'scheduled_at': scheduledAt.toIso8601String(),
        },
      );

      await refreshUserData();

      final data = dataOf(response);
      if (data == null) return null;

      final order = _orderFromApi(data);

      // Jaring pengaman: kalau penyegaran riwayat gagal, pesanan tetap
      // ditampilkan di halaman Status Pesanan.
      if (OrderStore.findById(order.id) == null) {
        OrderStore.orders.value = [order, ...OrderStore.orders.value];
      }

      return order;
    } catch (error) {
      debugPrint('SyncService.createOrder: $error');
      return null;
    }
  }

  /// Memajukan status pesanan di server.
  static Future<void> pushOrderAdvance(String orderCode) async {
    final id = _remoteOrderIds[orderCode];
    if (!ApiConfig.canSync || id == null) return;

    await _guard(() => ApiClient.put('/orders/$id/advance'));
  }

  /// Membatalkan pesanan di server.
  static Future<void> pushOrderCancel(String orderCode) async {
    final id = _remoteOrderIds[orderCode];
    if (!ApiConfig.canSync || id == null) return;

    await _guard(() => ApiClient.put('/orders/$id/cancel'));
  }

  /// Mencatat check-in di server.
  static Future<void> pushCheckIn() async {
    if (!ApiConfig.canSync) return;

    await _guard(() async {
      final response = await ApiClient.post('/checkin');
      final membership = dataOf(response)?['membership'];
      if (membership is Map<String, dynamic>) {
        _applyMembership(membership);
      }
    });
  }

  /// Mengklaim promo di server.
  static Future<void> pushPromoClaim(String label) async {
    if (!ApiConfig.canSync) return;

    await _guard(
      () => ApiClient.post('/promos/claim', body: {'label': label}),
    );
  }

  /// Membeli paket voucher di server, lalu menyegarkan daftar voucher.
  static Future<void> pushBuyVoucherPack(String packId) async {
    if (!ApiConfig.canSync) return;

    await _guard(() async {
      await ApiClient.post('/voucher-packs/$packId/buy');
      await _refreshVouchers();
    });
  }

  /// Mengaitkan kode voucher dengan akun di server.
  static Future<void> pushVoucherCode(String code) async {
    if (!ApiConfig.canSync) return;

    await _guard(
      () => ApiClient.post('/vouchers/validate', body: {'code': code}),
    );
  }

  /// Menyimpan alamat baru ke server.
  static Future<void> pushAddressCreate({
    required String label,
    required String recipient,
    required String phone,
    required String detail,
    required String note,
    required bool isDefault,
  }) async {
    if (!ApiConfig.canSync) return;

    await _guard(() async {
      await ApiClient.post(
        '/addresses',
        body: {
          'label': label,
          'recipient': recipient,
          'phone': phone,
          'detail': detail,
          'note': note,
          'is_default': isDefault,
        },
      );
      await _refreshAddresses();
    });
  }

  /// Menghapus alamat di server.
  static Future<void> pushAddressDelete(String localId) async {
    final id = _remoteIds['addresses']?[localId];
    if (!ApiConfig.canSync || id == null) return;

    await _guard(() async {
      await ApiClient.delete('/addresses/$id');
      await _refreshAddresses();
    });
  }

  /// Menandai pesan kotak masuk sudah dibaca di server.
  static Future<void> pushInboxRead(String localId) async {
    final id = _remoteIds['inbox']?[localId];
    if (!ApiConfig.canSync || id == null) return;

    await _guard(() => ApiClient.put('/inbox/$id/read'));
  }

  /// Menandai semua pesan sudah dibaca di server.
  static Future<void> pushInboxReadAll() async {
    if (!ApiConfig.canSync) return;

    await _guard(() => ApiClient.put('/inbox/read-all'));
  }

  /// Menyimpan pengaturan di server.
  static Future<void> pushSettings() async {
    if (!ApiConfig.canSync) return;

    await _guard(
      () => ApiClient.put(
        '/settings',
        body: {
          'language': SettingsStore.language.value.name,
          'notif_promo': SettingsStore.notifPromo.value,
          'notif_pesanan': SettingsStore.notifPesanan.value,
          'biometric': SettingsStore.biometric.value,
        },
      ),
    );
  }

  /// Memilih metode pembayaran di server.
  static Future<void> pushPaymentSelect(String methodId) async {
    if (!ApiConfig.canSync) return;

    await _guard(
      () => ApiClient.put(
        '/payment-methods/select',
        body: {'payment_method_id': methodId},
      ),
    );
  }

  /// Menghubungkan metode pembayaran di server.
  static Future<void> pushPaymentConnect(String methodId) async {
    if (!ApiConfig.canSync) return;

    await _guard(() => ApiClient.post('/payment-methods/$methodId/connect'));
  }

  // --- Penyegaran bagian dalam ------------------------------------------

  static Future<void> _refreshMembership() async {
    final membership = dataOf(await ApiClient.get('/membership'));
    if (membership != null) _applyMembership(membership);

    final history = listOf(await ApiClient.get('/points/history'));
    MemberStore.history.value = history
        .map(
          (entry) => PointEntry(
            title: '${entry['title']}',
            date: '${entry['date'] ?? ''}',
            delta: (entry['delta'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList(growable: false);

    final checkedDays = dataOf(await ApiClient.get('/checkin'))?['checked_days'];
    if (checkedDays is List) {
      MemberStore.checkedDays.value = checkedDays
          .whereType<num>()
          .map((day) => day.toInt())
          .toSet();
    }
  }

  static void _applyMembership(Map<String, dynamic> membership) {
    MemberStore.points.value = (membership['points'] as num?)?.toInt() ?? 0;
    MemberStore.totalSpent.value =
        (membership['total_spent'] as num?)?.toInt() ?? 0;
  }

  static Future<void> _refreshOrders() async {
    final orders = listOf(await ApiClient.get('/orders'));

    _remoteOrderIds.clear();

    final mapped = <Order>[];

    for (final json in orders) {
      final order = _orderFromApi(json);
      mapped.add(order);

      final remoteId = (json['id'] as num?)?.toInt();
      if (remoteId != null) _remoteOrderIds[order.id] = remoteId;
    }

    OrderStore.replaceAll(mapped);
  }

  static Future<void> _refreshVouchers() async {
    final vouchers = listOf(await ApiClient.get('/vouchers'));
    VoucherStore.userVouchers.value = vouchers
        .map(_voucherFromApi)
        .toList(growable: false);

    final claimed = dataOf(await ApiClient.get('/promos'))?['claimed'];
    if (claimed is List) {
      VoucherStore.claimedPromos.value = claimed
          .map((label) => '$label')
          .toList(growable: false);
    }
  }

  static Future<void> _refreshAddresses() async {
    final addresses = listOf(await ApiClient.get('/addresses'));

    _remoteIds['addresses'] = <String, int>{};

    final mapped = <Address>[];

    for (var index = 0; index < addresses.length; index++) {
      final json = addresses[index];
      final localId = 'addr-${index + 1}';
      final remoteId = (json['id'] as num?)?.toInt();

      if (remoteId != null) _remoteIds['addresses']![localId] = remoteId;

      mapped.add(
        Address(
          id: localId,
          label: '${json['label']}',
          recipient: '${json['recipient']}',
          phone: '${json['phone']}',
          detail: '${json['detail']}',
          note: '${json['note'] ?? ''}',
          isDefault: json['is_default'] == true,
        ),
      );
    }

    if (mapped.isNotEmpty) AddressStore.replaceAll(mapped);
  }

  static Future<void> _refreshInbox() async {
    final messages = dataOf(await ApiClient.get('/inbox'))?['messages'];
    if (messages is! List) return;

    _remoteIds['inbox'] = <String, int>{};

    final mapped = <InboxMessage>[];

    for (var index = 0; index < messages.length; index++) {
      final json = messages[index];
      if (json is! Map<String, dynamic>) continue;

      final localId = 'msg-${index + 1}';
      final remoteId = (json['id'] as num?)?.toInt();
      if (remoteId != null) _remoteIds['inbox']![localId] = remoteId;

      mapped.add(
        InboxMessage(
          id: localId,
          title: '${json['title']}',
          body: '${json['body']}',
          date: '${json['date'] ?? ''}',
          kind: _inboxKind(json['kind']),
          read: json['read'] == true,
        ),
      );
    }

    InboxStore.replaceAll(mapped);
  }

  static Future<void> _refreshSettings() async {
    final settings = dataOf(await ApiClient.get('/settings'));
    if (settings == null) return;

    SettingsStore.language.value = _language(settings['language']);
    SettingsStore.notifPromo.value = settings['notif_promo'] == true;
    SettingsStore.notifPesanan.value = settings['notif_pesanan'] == true;
    SettingsStore.biometric.value = settings['biometric'] == true;
  }

  static Future<void> _refreshPayments() async {
    final methods = listOf(await ApiClient.get('/payment-methods'));

    final connected = <String>{};
    String? selected;

    for (final method in methods) {
      final id = '${method['id']}';
      if (method['is_connected'] == true) connected.add(id);
      if (method['is_selected'] == true) selected = id;
    }

    PaymentStore.connectedIds.value = connected;
    if (selected != null) PaymentStore.selectedId.value = selected;
  }

  // --- Pemetaan JSON ke model -------------------------------------------

  static List<Product> _menuFromApi(List<Map<String, dynamic>> items) {
    final byCategory = <String, List<Product>>{
      for (final category in CatalogStore.categoryOrder) category: <Product>[],
    };

    for (final json in items) {
      final categories = (json['categories'] as List?)
          ?.map((category) => '$category')
          .toList();

      if (categories == null || categories.isEmpty) continue;

      for (final category in categories) {
        byCategory
            .putIfAbsent(category, () => <Product>[])
            .add(_productFromApi(json, category));
      }
    }

    return [for (final category in byCategory.keys) ...byCategory[category]!];
  }

  static Product _productFromApi(Map<String, dynamic> json, String category) {
    return Product(
      name: '${json['name']}',
      price: (json['price'] as num?)?.toInt() ?? 0,
      image: '${json['image'] ?? ''}',
      category: category,
      description: '${json['description'] ?? ''}',
      isNew: json['is_new'] == true,
      promoLabel: '${json['promo_label'] ?? ''}',
    );
  }

  static MerchProduct _merchFromApi(Map<String, dynamic> json) {
    return MerchProduct(
      name: '${json['name']}',
      price: (json['price'] as num?)?.toInt() ?? 0,
      image: '${json['image'] ?? ''}',
      description: '${json['description'] ?? ''}',
    );
  }

  static Outlet _outletFromApi(Map<String, dynamic> json) {
    return Outlet(
      name: '${json['name']}',
      address: '${json['address']}',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      distance: '${json['distance'] ?? ''}',
    );
  }

  static Order _orderFromApi(Map<String, dynamic> json) {
    final items = (json['items'] as List?) ?? const [];

    return Order(
      id: '${json['code']}',
      items: items
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => CartItem(
              name: '${item['name']}',
              image: '${item['image'] ?? ''}',
              basePrice: (item['base_price'] as num?)?.toInt() ?? 0,
              unitPrice: (item['unit_price'] as num?)?.toInt() ?? 0,
              quantity: (item['quantity'] as num?)?.toInt() ?? 1,
              size: '${item['size'] ?? ''}',
              milk: '${item['milk'] ?? ''}',
              sugar: '${item['sugar'] ?? ''}',
              ice: '${item['ice'] ?? ''}',
              toppings:
                  (item['toppings'] as List?)
                      ?.map((topping) => '$topping')
                      .toList() ??
                  const <String>[],
              syrups:
                  (item['syrups'] as List?)
                      ?.map((syrup) => '$syrup')
                      .toList() ??
                  const <String>[],
              note: '${item['note'] ?? ''}',
            ),
          )
          .toList(growable: false),
      subtotal: (json['subtotal'] as num?)?.toInt() ?? 0,
      bagFee: (json['bag_fee'] as num?)?.toInt() ?? 0,
      pointsUsed: (json['points_used'] as num?)?.toInt() ?? 0,
      voucherDiscount: (json['voucher_discount'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      paymentMethod: '${json['payment_method'] ?? ''}',
      fulfilment: '${json['fulfilment'] ?? 'Pickup'}',
      createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
      status: _orderStatus(json['status']),
      scheduledAt: json['scheduled_at'] == null
          ? null
          : DateTime.tryParse('${json['scheduled_at']}'),
    );
  }

  static Voucher _voucherFromApi(Map<String, dynamic> json) {
    return Voucher(
      code: '${json['code']}',
      title: '${json['title']}',
      description: '${json['description'] ?? ''}',
      minPurchase: (json['min_purchase'] as num?)?.toInt() ?? 0,
      validity: '${json['validity'] ?? ''}',
      kind: _voucherKind(json['kind']),
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
    );
  }

  static OrderStatus _orderStatus(Object? value) {
    final label = '$value'.toLowerCase();

    for (final status in OrderStatus.values) {
      if (status.label.toLowerCase() == label) return status;
    }

    return OrderStatus.pending;
  }

  static InboxKind _inboxKind(Object? value) {
    final label = '$value'.toLowerCase();

    for (final kind in InboxKind.values) {
      if (kind.label.toLowerCase() == label) return kind;
    }

    return InboxKind.promo;
  }

  static VoucherKind _voucherKind(Object? value) {
    final label = '$value'.toLowerCase();

    for (final kind in VoucherKind.values) {
      if (kind.name.toLowerCase() == label) return kind;
    }

    return VoucherKind.diskon;
  }

  static AppLanguage _language(Object? value) {
    final code = '$value'.toLowerCase();

    for (final language in AppLanguage.values) {
      if (language.name.toLowerCase() == code) return language;
    }

    return AppLanguage.indonesia;
  }

  // --- Pembantu ---------------------------------------------------------

  /// Kode pesanan → id numerik di server (untuk advance/cancel).
  static final Map<String, int> _remoteOrderIds = <String, int>{};

  /// Id lokal → id di server, per jenis data.
  static final Map<String, Map<String, int>> _remoteIds =
      <String, Map<String, int>>{};

  static Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      debugPrint('SyncService: $error');
    }
  }
}

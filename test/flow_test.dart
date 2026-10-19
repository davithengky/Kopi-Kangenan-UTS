import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopken_clone/config/api.dart';
import 'package:kopken_clone/main.dart';
import 'package:kopken_clone/models/order.dart';
import 'package:kopken_clone/models/product.dart';
import 'package:kopken_clone/providers/address_store.dart';
import 'package:kopken_clone/providers/cart_store.dart';
import 'package:kopken_clone/providers/inbox_store.dart';
import 'package:kopken_clone/providers/member_store.dart';
import 'package:kopken_clone/providers/order_store.dart';
import 'package:kopken_clone/providers/outlet_store.dart';
import 'package:kopken_clone/providers/payment_store.dart';
import 'package:kopken_clone/providers/settings_store.dart';
import 'package:kopken_clone/providers/voucher_store.dart';
import 'package:kopken_clone/screens/cart/cart_screen.dart';
import 'package:kopken_clone/screens/product/product_detail_screen.dart';

/// Tes alur utama di dalam aplikasi: menyelesaikan pesanan dari keranjang
/// sampai halaman Status Pesanan, dan menjelajah menu di tab Profil.
///
/// Catatan sama seperti `layout_test.dart`: font bawaan `flutter test` membuat
/// setiap glif selebar 1em, jadi label panjang terlihat lebih sempit dari
/// aslinya. Karena itu tes ini hanya memilih layar yang sudah memakai
/// `TextOverflow.ellipsis` atau lebar tetap.
void main() {
  /// Membuat satu item keranjang yang siap di-checkout.
  CartItem taroCloudLatte() {
    return const CartItem(
      name: 'Taro Cloud Latte',
      image: 'assets/taro cloud latte.png',
      basePrice: 28000,
      quantity: 1,
      size: 'Regular',
      milk: 'Milk',
      sugar: 'Normal Sugar',
      ice: 'Normal Ice',
      toppings: <String>[],
      syrups: <String>[],
      unitPrice: 28000,
    );
  }

  /// Memakai ukuran layar ponsel (390 × 844) supaya tata letak yang diuji sama
  /// dengan aplikasi aslinya, bukan kanvas bawaan `flutter test` (800 × 600).
  void usePhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  /// Membuka aplikasi, melewati splash, lalu menutup popup login.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const KopkenApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
  }

  /// Menggulir halaman sampai [finder] terlihat, lalu menekannya.
  Future<void> scrollDanKetuk(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Menunggu SnackBar (durasi bawaan 4 detik) hilang supaya tidak menutupi
  /// tombol di bawahnya.
  Future<void> tungguSnackBarHilang(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  setUp(() {
    // Pengujian berjalan tanpa jaringan: semua panggilan API dimatikan.
    ApiConfig.enabled = false;

    CartStore.clear();
    OrderStore.clear();
    MemberStore.reset();
    VoucherStore.reset();
    PaymentStore.reset();
    OutletStore.reset();
    AddressStore.reset();
    InboxStore.reset();
    SettingsStore.reset();
  });

  testWidgets('alur pesan: keranjang → checkout → QRIS → Beranda', (
    tester,
  ) async {
    CartStore.add(taroCloudLatte());

    usePhoneScreen(tester);
    await pumpApp(tester);

    // Tombol keranjang di header Beranda.
    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Keranjang'), findsOneWidget);
    expect(find.text('Taro Cloud Latte'), findsWidgets);

    // Lanjut ke Checkout.
    await tester.tap(find.text('Checkout (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Taro Cloud Latte'), findsWidgets);

    // Bayar memakai QRIS (metode bawaan).
    await tester.tap(find.textContaining('Bayar - '));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Kembali Ke Beranda'), findsOneWidget);

    // Halaman QRIS punya hitungan waktu `Timer.periodic`, jadi proses
    // penyelesaian pesanan harus menunggu halaman itu dibuang dulu sebelum
    // `pumpAndSettle` dipakai lagi.
    await tester.tap(find.text('Kembali Ke Beranda'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Pesanan dibuat lebih dulu, lalu pembeli dibawa kembali ke Beranda.
    expect(find.text('Beranda'), findsOneWidget);

    // Pesanan tercatat, keranjang dikosongkan, dan poin didapat.
    final order = OrderStore.orders.value.first;
    expect(order.status, OrderStatus.pending);
    expect(order.total, 28000);
    expect(order.paymentMethod, 'QRIS');
    expect(CartStore.isEmpty, isTrue);
    expect(MemberStore.points.value, 28);
  });

  testWidgets('tombol X di QRIS kembali ke Checkout tanpa membuat pesanan', (
    tester,
  ) async {
    CartStore.add(taroCloudLatte());

    usePhoneScreen(tester);
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Checkout (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Bayar - '));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Tombol X di header menutup halaman QRIS tanpa membayar.
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Belum dibayar: kembali ke Checkout, pesanan belum dibuat, dan keranjang
    // tetap terisi supaya pembeli bisa mengganti metode pembayaran.
    expect(find.text('Checkout'), findsOneWidget);
    expect(OrderStore.orders.value, isEmpty);
    expect(CartStore.totalQuantity, 1);
  });

  testWidgets('detail makanan tidak menampilkan opsi minuman', (tester) async {
    usePhoneScreen(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailScreen(
          product: const Product(
            name: 'Triple Cheese Bagel',
            price: 22000,
            image: 'assets/triple cheeze bagel.png',
            category: 'Makanan',
            description: 'Roti bagel bercita rasa keju.',
          ).toProductMap(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Temperature'), findsNothing);
    expect(find.text('Size'), findsNothing);
    expect(find.text('Milk Option'), findsNothing);
    expect(find.text('Sugar Level'), findsNothing);
    expect(find.text('Ice Level'), findsNothing);

    // Digulir sampai bawah pun opsi Topping & Syrup tetap tidak muncul.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1500));
    await tester.pumpAndSettle();

    expect(find.text('Topping'), findsNothing);
    expect(find.text('Syrup'), findsNothing);

    // Nama, harga, dan deskripsi tetap tampil.
    expect(find.text('Triple Cheese Bagel'), findsWidgets);
    expect(find.text('Rp22.000'), findsWidgets);
    expect(find.text('Roti bagel bercita rasa keju.'), findsOneWidget);
  });

  testWidgets('detail minuman menampilkan opsi minuman', (tester) async {
    usePhoneScreen(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailScreen(
          product: const Product(
            name: 'Taro Cloud Latte',
            price: 28000,
            image: 'assets/taro cloud latte.png',
            category: 'Coffee',
          ).toProductMap(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Temperature'), findsOneWidget);
    expect(find.text('Size'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Topping'), 250);
    await tester.pumpAndSettle();
    expect(find.text('Topping'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Syrup'), 200);
    await tester.pumpAndSettle();
    expect(find.text('Syrup'), findsOneWidget);
  });

  testWidgets('item merchandise di keranjang tanpa tombol Ganti', (
    tester,
  ) async {
    CartStore.add(
      const CartItem(
        name: 'ColorPop Cup',
        image: 'assets/merch/ColorPop Cup.png',
        basePrice: 109650,
        quantity: 1,
        size: '',
        milk: '',
        sugar: '',
        ice: '',
        toppings: <String>[],
        syrups: <String>[],
        unitPrice: 109650,
      ),
    );

    usePhoneScreen(tester);
    await tester.pumpWidget(const MaterialApp(home: CartScreen()));
    await tester.pumpAndSettle();

    expect(find.text('ColorPop Cup'), findsWidgets);

    // Merchandise tidak punya opsi kustomisasi, jadi tidak ada tombol "Ganti"
    // dan tidak ada baris placeholder "Standar · · · ·".
    expect(find.text('Ganti'), findsNothing);
    expect(find.textContaining('Standar'), findsNothing);
  });

  testWidgets('item minuman di keranjang tetap punya tombol Ganti', (
    tester,
  ) async {
    CartStore.add(taroCloudLatte());

    usePhoneScreen(tester);
    await tester.pumpWidget(const MaterialApp(home: CartScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Ganti'), findsOneWidget);
    expect(find.textContaining('Regular · Milk'), findsOneWidget);
  });

  testWidgets('tab Profil membuka Data Diri dan Kotak Masuk', (tester) async {
    usePhoneScreen(tester);
    await pumpApp(tester);

    await tester.tap(find.text('Saya'));
    await tester.pumpAndSettle();

    expect(find.text('Hai,'), findsOneWidget);
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('Daily Check-In'), findsOneWidget);

    await scrollDanKetuk(tester, find.text('Data Diri'));
    expect(find.text('Data Diri'), findsWidgets);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await scrollDanKetuk(tester, find.text('Kotak Masuk'));
    expect(find.text('Selamat datang di Kopi Kangenan!'), findsOneWidget);

    // Membaca pesan pertama mengurangi jumlah pesan belum dibaca.
    await tester.tap(find.text('Selamat datang di Kopi Kangenan!'));
    await tester.pumpAndSettle();
    expect(InboxStore.unreadCount, 1);
  });

  testWidgets('halaman Pilih Outlet mengganti mode dan outlet', (tester) async {
    usePhoneScreen(tester);
    await pumpApp(tester);

    await tester.tap(find.text('Tunjungan Plaza 3').first);
    await tester.pumpAndSettle();

    expect(find.text('Pilih Outlet'), findsOneWidget);

    // Segmented control Delivery/Pickup di bagian atas halaman.
    await tester.tap(find.text('Delivery').first);
    await tester.pumpAndSettle();
    expect(OutletStore.mode.value.label, 'Delivery');

    await tester.tap(find.text('Pickup').first);
    await tester.pumpAndSettle();
    expect(OutletStore.mode.value.label, 'Pickup');

    // Memilih outlet langsung menutup halaman ini.
    await tester.tap(find.text('Ketintang UNESA').first);
    await tester.pumpAndSettle();

    expect(OutletStore.selected.value.name, 'Ketintang UNESA');
    expect(find.text('Pilih Outlet'), findsNothing);
    expect(find.text('Ketintang UNESA'), findsWidgets);
  });

  testWidgets('Daily Check-In menambah poin lewat tombolnya', (tester) async {
    usePhoneScreen(tester);
    await pumpApp(tester);

    await tester.tap(find.text('Saya'));
    await tester.pumpAndSettle();

    // Kartu Daily Check-In di Profil punya tombol "Detail".
    await scrollDanKetuk(tester, find.text('Detail'));

    expect(find.text('0 / 6 hari'), findsOneWidget);

    await tester.tap(find.text('Check-In Hari Ini'));
    await tester.pumpAndSettle();

    expect(MemberStore.checkedDays.value.length, 1);
    expect(MemberStore.points.value, 25);
    expect(find.text('1 / 6 hari'), findsOneWidget);

    await tungguSnackBarHilang(tester);
  });
}

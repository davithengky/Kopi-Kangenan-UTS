import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopken_clone/config/api.dart';
import 'package:kopken_clone/main.dart';
import 'package:kopken_clone/providers/member_store.dart';
import 'package:kopken_clone/widgets/kangenan_coin.dart';

/// Tes tata letak pada ukuran layar ponsel (390 × 844).
///
/// Tujuannya menangkap error overflow / exception render, karena kesalahan
/// seperti itu tidak terdeteksi oleh `flutter analyze`.
///
/// Catatan: font bawaan `flutter test` membuat setiap glif selebar 1em,
/// sehingga teks jauh lebih lebar daripada Roboto aslinya. Karena itu tes ini
/// hanya menjaga tab yang sudah dirapikan (Beranda, Menu, dan Profil); tab lain
/// (VIP, Merch) bisa melaporkan overflow palsu dari label panjangnya.
void main() {
  setUp(() {
    // Pengujian berjalan tanpa jaringan: semua panggilan API dimatikan.
    ApiConfig.enabled = false;
  });

  /// Membuka aplikasi, melewati splash, lalu menutup popup login.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const KopkenApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Popup login otomatis terbuka dan menutupi seluruh layar, jadi ditutup
    // dulu supaya bottom navigation bisa ditekan.
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
  }

  void usePhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('Beranda dan Menu tampil bersih di layar ponsel', (
    WidgetTester tester,
  ) async {
    usePhoneScreen(tester);
    await pumpApp(tester);

    // --- Beranda ---
    expect(tester.takeException(), isNull, reason: 'Beranda');

    // Nama outlet, "Diskon & Cashback", "Baru!", dan "Makanan" harus ada.
    expect(find.text('Tunjungan Plaza 3'), findsWidgets);
    expect(find.text('Diskon & Cashback'), findsOneWidget);
    expect(find.text('Baru!'), findsWidgets);
    expect(find.text('Makanan'), findsWidgets);

    // --- Menu ---
    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Menu');

    // Nama outlet di Menu harus sama dengan Beranda.
    expect(find.text('Tunjungan Plaza 3'), findsOneWidget);
    expect(find.text('Diskon & Cashback'), findsOneWidget);

    // Tab kategori berbasis teks, dimulai dari "Promo & Combo".
    expect(find.text('Promo & Combo'), findsWidgets);

    // Judul lama yang dirender oleh shell navigasi sudah tidak ada lagi.
    expect(find.text('Menu Kopi Kangenan'), findsNothing);
  });

  testWidgets('Halaman Menu bisa digulir sampai bawah tanpa error', (
    WidgetTester tester,
  ) async {
    usePhoneScreen(tester);
    await pumpApp(tester);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    // Gulir bertahap supaya setiap section ikut ditata pada semua posisi.
    final scrollView = find.byType(SingleChildScrollView).first;
    for (int i = 0; i < 10; i++) {
      await tester.drag(scrollView, const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: 'gulir langkah ke-$i');
    }

    // Kategori terakhir beserta produknya sudah tampil di bagian bawah.
    expect(find.text('Makanan'), findsWidgets);
    expect(find.text('Triple Cheese Bagel'), findsOneWidget);
  });

  testWidgets('Halaman Profil tampil bersih tanpa overflow', (
    WidgetTester tester,
  ) async {
    usePhoneScreen(tester);
    await pumpApp(tester);

    await tester.tap(find.text('Saya'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: 'Profil');

    // Keadaan awal (belum masuk): sapaan tamu dan tombol Masuk.
    expect(find.text('Hai,'), findsOneWidget);
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Daily Check-In'), findsOneWidget);

    // Saat belum masuk, tombol header tetap "Masuk" (bukan "Edit Profil").
    expect(find.text('Edit Profil'), findsNothing);

    // Kartu level/poin harus punya jarak ke kartu promo di bawahnya.
    // Dulu keduanya menempel karena header memakai tinggi tetap
    // (`SizedBox(height: 220)`) sehingga kartu berakhir tepat di batasnya.
    final kartuLevel = tester.getRect(
      find.byKey(const ValueKey('profil-kartu-level')),
    );
    final kartuPromo = tester.getRect(
      find.byKey(const ValueKey('profil-kartu-promo')),
    );
    expect(
      kartuPromo.top - kartuLevel.bottom,
      greaterThanOrEqualTo(12),
      reason: 'jarak kartu level ke kartu promo',
    );
    expect(
      kartuPromo.top,
      greaterThanOrEqualTo(kartuLevel.bottom),
      reason: 'kartu promo tidak boleh menimpa kartu level',
    );
  });

  testWidgets('Header Profil: avatar logo, kolom level, dan koin Kangenan', (
    WidgetTester tester,
  ) async {
    usePhoneScreen(tester);
    await pumpApp(tester);

    await tester.tap(find.text('Saya'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: 'Profil');

    // Avatar memakai logo Kopi Kangenan dan band tetap polos.
    expect(
      find.descendant(of: find.byType(ClipOval), matching: find.byType(Image)),
      findsWidgets,
    );

    // Kartu tiga kolom: sapaan, level ringkas, dan poin berkoin "K".
    expect(find.text('Level'), findsOneWidget);
    expect(find.text('Kangenan Points'), findsOneWidget);
    expect(find.text(MemberStore.level.label), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.byType(KangenanCoin), findsWidgets);
  });
}

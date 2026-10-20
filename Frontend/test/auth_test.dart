import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopken_clone/config/api.dart';
import 'package:kopken_clone/main.dart';
import 'package:kopken_clone/providers/auth_store.dart';
import 'package:kopken_clone/services/auth_service.dart';

void main() {
  // Pengujian berjalan tanpa jaringan: semua panggilan API dimatikan.
  setUp(() => ApiConfig.enabled = false);

  /// Menunggu SnackBar (durasi bawaan 4 detik) hilang, supaya tidak menutupi
  /// bottom navigation saat tes berikutnya menekan tab.
  Future<void> tungguSnackBarHilang(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  group('AuthService', () {
    setUp(() {
      AuthService.reset();
      AuthStore.logout();
    });

    test('akun demo bisa masuk', () {
      final user = AuthService.login(
        identifier: AuthService.demoIdentifier,
        password: AuthService.demoPassword,
      );

      expect(user.name, 'Demo');
      expect(user.identifier, AuthService.demoIdentifier);
    });

    test('email tidak peka huruf besar/kecil dan spasi di ujung', () {
      final user = AuthService.login(
        identifier: '  ${AuthService.demoIdentifier.toUpperCase()}  ',
        password: AuthService.demoPassword,
      );

      expect(user.name, 'Demo');
    });

    test('akun belum terdaftar ditolak', () {
      expect(
        () =>
            AuthService.login(identifier: 'baru@email.com', password: '123456'),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            contains('belum terdaftar'),
          ),
        ),
      );
    });

    test('password salah ditolak', () {
      expect(
        () => AuthService.login(
          identifier: AuthService.demoIdentifier,
          password: 'salahsekali',
        ),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            'Password salah.',
          ),
        ),
      );
    });

    test('identifier kosong ditolak', () {
      expect(
        () => AuthService.login(identifier: '   ', password: '123456'),
        throwsA(isA<AuthException>()),
      );
    });

    test('format email tidak valid ditolak', () {
      expect(
        () => AuthService.validateIdentifier('bukan-email'),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            contains('nomor HP'),
          ),
        ),
      );

      expect(
        () => AuthService.validateIdentifier('nama@'),
        throwsA(isA<AuthException>()),
      );
    });

    test('nomor HP menerima spasi dan tanda hubung', () {
      expect(
        () => AuthService.validateIdentifier('0812-3456-7890'),
        returnsNormally,
      );
      expect(
        () => AuthService.validateIdentifier('+62 812 3456 7890'),
        returnsNormally,
      );
      expect(
        () => AuthService.validateIdentifier('123'),
        throwsA(isA<AuthException>()),
      );
    });

    test('password minimal 6 karakter', () {
      expect(
        () => AuthService.validatePassword('12345'),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            contains('minimal 6'),
          ),
        ),
      );
      expect(() => AuthService.validatePassword('123456'), returnsNormally);
    });

    test('nama minimal 3 karakter', () {
      expect(
        () => AuthService.validateName('ab'),
        throwsA(isA<AuthException>()),
      );
      expect(() => AuthService.validateName('Jibi'), returnsNormally);
    });

    test('daftar berhasil lalu bisa masuk', () {
      final terdaftar = AuthService.register(
        name: 'Jibi',
        identifier: '0812-3456-7890',
        password: 'rahasia',
        confirmPassword: 'rahasia',
      );

      expect(terdaftar.name, 'Jibi');
      expect(AuthService.registeredAccountCount, 2);

      final masuk = AuthService.login(
        identifier: '0812-3456-7890',
        password: 'rahasia',
      );
      expect(masuk.name, 'Jibi');
    });

    test('konfirmasi password tidak sama ditolak', () {
      expect(
        () => AuthService.register(
          name: 'Jibi',
          identifier: 'jibi@email.com',
          password: 'rahasia',
          confirmPassword: 'rahasia2',
        ),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            'Konfirmasi password tidak sama.',
          ),
        ),
      );
    });

    test('identifier yang sudah terdaftar ditolak', () {
      expect(
        () => AuthService.register(
          name: 'Kembar',
          identifier: AuthService.demoIdentifier,
          password: 'rahasia',
          confirmPassword: 'rahasia',
        ),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            contains('sudah terdaftar'),
          ),
        ),
      );
    });
  });

  group('AuthStore', () {
    setUp(() {
      AuthService.reset();
      AuthStore.logout();
    });

    test('awalnya tamu', () {
      expect(AuthStore.isLoggedIn, isFalse);
      expect(AuthStore.displayName, 'Guest');
    });

    test('login mengubah status dan nama tampilan', () {
      AuthStore.login(
        identifier: AuthService.demoIdentifier,
        password: AuthService.demoPassword,
      );

      expect(AuthStore.isLoggedIn, isTrue);
      expect(AuthStore.displayName, 'Demo');
    });

    test('logout mengembalikan ke tamu', () {
      AuthStore.register(
        name: 'Jibi',
        identifier: 'jibi@email.com',
        password: 'rahasia',
        confirmPassword: 'rahasia',
      );
      expect(AuthStore.displayName, 'Jibi');

      AuthStore.logout();
      expect(AuthStore.isLoggedIn, isFalse);
      expect(AuthStore.displayName, 'Guest');
    });
  });

  group('Alur Login & Daftar di aplikasi', () {
    setUp(() {
      AuthService.reset();
      AuthStore.logout();
    });

    /// Membuka aplikasi, melewati splash, dan berhenti di panel Login.
    Future<void> pumpSampaiPanelLogin(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const KopkenApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    }

    testWidgets('splash langsung membuka panel Login di atas Beranda', (
      WidgetTester tester,
    ) async {
      await pumpSampaiPanelLogin(tester);

      expect(find.text('Masuk untuk melanjutkan'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Belum punya akun? '), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tombol X menutup panel tanpa login', (
      WidgetTester tester,
    ) async {
      await pumpSampaiPanelLogin(tester);

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      expect(find.text('Masuk untuk melanjutkan'), findsNothing);
      expect(AuthStore.isLoggedIn, isFalse);
      expect(find.text('Beranda'), findsOneWidget);
    });

    testWidgets('login akun demo berhasil dan nama muncul di Profil', (
      WidgetTester tester,
    ) async {
      await pumpSampaiPanelLogin(tester);

      await tester.enterText(
        find.byType(TextField).at(0),
        AuthService.demoIdentifier,
      );
      await tester.enterText(
        find.byType(TextField).at(1),
        AuthService.demoPassword,
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Panel tertutup dan pengguna benar-benar tercatat masuk.
      expect(find.text('Masuk untuk melanjutkan'), findsNothing);
      expect(AuthStore.displayName, 'Demo');
      expect(
        find.text('Berhasil masuk. Selamat datang, Demo!'),
        findsOneWidget,
      );

      // Sapaan di halaman Profil ikut berubah: "Hai," dan nama kini terpisah
      // dua baris, dan tombol header berubah jadi "Edit Profil".
      await tungguSnackBarHilang(tester);
      await tester.tap(find.text('Saya'));
      await tester.pumpAndSettle();

      expect(find.text('Hai,'), findsOneWidget);
      expect(find.text('Demo'), findsOneWidget);
      expect(find.text('Edit Profil'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('password salah menampilkan pesan dan panel tetap terbuka', (
      WidgetTester tester,
    ) async {
      await pumpSampaiPanelLogin(tester);

      await tester.enterText(find.byType(TextField).at(0), 'demo@kangenan.com');
      await tester.enterText(find.byType(TextField).at(1), 'passwordsalah');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Password salah.'), findsOneWidget);
      expect(find.text('Masuk untuk melanjutkan'), findsOneWidget);
      expect(AuthStore.isLoggedIn, isFalse);
    });

    testWidgets('daftar akun baru langsung masuk dan tercatat', (
      WidgetTester tester,
    ) async {
      await pumpSampaiPanelLogin(tester);

      await tester.tap(find.text('Daftar di sini'));
      await tester.pumpAndSettle();

      expect(find.text('Daftar untuk mulai memesan'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(4));

      await tester.enterText(find.byType(TextField).at(0), 'Jibi');
      await tester.enterText(find.byType(TextField).at(1), 'jibi@email.com');
      await tester.enterText(find.byType(TextField).at(2), 'rahasia');
      await tester.enterText(find.byType(TextField).at(3), 'rahasia');
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.text('Daftar untuk mulai memesan'), findsNothing);
      expect(AuthStore.displayName, 'Jibi');
      expect(AuthService.registeredAccountCount, 2);

      await tungguSnackBarHilang(tester);
      await tester.tap(find.text('Saya'));
      await tester.pumpAndSettle();

      expect(find.text('Hai,'), findsOneWidget);
      expect(find.text('Jibi'), findsOneWidget);
    });

    testWidgets('daftar dengan konfirmasi berbeda ditolak', (
      WidgetTester tester,
    ) async {
      await pumpSampaiPanelLogin(tester);

      await tester.tap(find.text('Daftar di sini'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Jibi');
      await tester.enterText(find.byType(TextField).at(1), 'jibi@email.com');
      await tester.enterText(find.byType(TextField).at(2), 'rahasia');
      await tester.enterText(find.byType(TextField).at(3), 'rahasia2');
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi password tidak sama.'), findsOneWidget);
      expect(find.text('Daftar untuk mulai memesan'), findsOneWidget);
      expect(AuthStore.isLoggedIn, isFalse);
    });

    testWidgets('tombol Masuk di Profil membuka panel, Keluar menutup sesi', (
      WidgetTester tester,
    ) async {
      await pumpSampaiPanelLogin(tester);

      // Tutup panel otomatis, lalu buka tab Profil.
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saya'));
      await tester.pumpAndSettle();

      expect(find.text('Hai,'), findsOneWidget);
      expect(find.text('Guest'), findsOneWidget);

      // Tombol "Masuk" di Profil harus benar-benar membuka panel Login.
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Masuk untuk melanjutkan'), findsOneWidget);

      // Masuk memakai akun demo.
      await tester.enterText(find.byType(TextField).at(0), 'demo@kangenan.com');
      await tester.enterText(find.byType(TextField).at(1), '123456');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Hai,'), findsOneWidget);
      expect(find.text('Demo'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);

      // Keluar sudah dipindah ke section "Akun", jadi itemnya perlu
      // digulir dulu supaya benar-benar bisa ditekan.
      await tester.ensureVisible(find.text('Keluar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      expect(find.text('Hai,'), findsOneWidget);
      expect(find.text('Guest'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
      expect(AuthStore.isLoggedIn, isFalse);
    });

    testWidgets('akun yang baru didaftarkan bisa dipakai login lagi', (
      WidgetTester tester,
    ) async {
      await pumpSampaiPanelLogin(tester);

      // Daftar akun baru.
      await tester.tap(find.text('Daftar di sini'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Jibi');
      await tester.enterText(find.byType(TextField).at(1), 'jibi@email.com');
      await tester.enterText(find.byType(TextField).at(2), 'rahasia');
      await tester.enterText(find.byType(TextField).at(3), 'rahasia');
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(AuthStore.displayName, 'Jibi');

      // Keluar, lalu masuk lagi memakai akun tadi.
      await tungguSnackBarHilang(tester);
      await tester.tap(find.text('Saya'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Keluar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      // Halaman tadi ikut tergulir saat mencari tombol "Keluar"; gulir balik
      // ke atas supaya tombol "Masuk" di header bisa ditekan.
      await tester.ensureVisible(find.text('Masuk'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'jibi@email.com');
      await tester.enterText(find.byType(TextField).at(1), 'rahasia');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Hai,'), findsOneWidget);
      expect(find.text('Jibi'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopken_clone/config/api.dart';
import 'package:kopken_clone/main.dart';

void main() {
  setUp(() {
    // Pengujian berjalan tanpa jaringan: semua panggilan API dimatikan.
    ApiConfig.enabled = false;
  });

  testWidgets('Splash tampil lalu Beranda terbuka', (WidgetTester tester) async {
    await tester.pumpWidget(const KopkenApp());

    // Splash: logo tampil, bottom navigation belum ada.
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Beranda'), findsNothing);

    // Lewati durasi splash, lalu tunggu transisi halaman + popup login.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Bottom navigation utama tampil dengan label tabnya.
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('VIP'), findsOneWidget);
    expect(find.text('Merch'), findsOneWidget);
    expect(find.text('Saya'), findsOneWidget);
  });
}

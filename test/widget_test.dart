// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/providers/sleep_provider.dart';

Future<void> main() async {
  await initializeDateFormatting('id_ID');

  testWidgets('Noctelle opens on the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SleepProvider(),
        child: const NoctelleApp(),
      ),
    );
    expect(
      find.text('Temukan ritme istirahat yang lebih baik.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Ringkasan tidurmu'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Mulai sesi tidur'), findsOneWidget);

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Riwayat tidur'), findsOneWidget);

    await tester.tap(find.text('Mingguan'));
    await tester.pumpAndSettle();
    expect(find.text('Minggu ini'), findsOneWidget);

    await tester.tap(find.text('Pengaturan'));
    await tester.pumpAndSettle();
    expect(find.text('Target durasi tidur'), findsOneWidget);
    await tester.tap(find.text('Target durasi tidur'));
    await tester.pumpAndSettle();
    expect(find.text('Simpan target'), findsOneWidget);
    await tester.tap(find.text('Simpan target'));
    await tester.pumpAndSettle();
    expect(find.text('8j'), findsOneWidget);
  });
}

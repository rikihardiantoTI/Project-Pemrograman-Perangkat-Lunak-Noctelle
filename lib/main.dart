import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/sleep_provider.dart';
import 'screens/splash_screen.dart';
import 'widgets/noctelle_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  runApp(
    ChangeNotifierProvider(
      create: (_) => SleepProvider()..load(),
      child: const NoctelleApp(),
    ),
  );
}

class NoctelleApp extends StatelessWidget {
  const NoctelleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noctelle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: NoctelleColors.background,
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: const Color(0xFFF1F2FA),
          displayColor: const Color(0xFFF1F2FA),
          fontFamily: 'sans-serif',
        ),
        cardTheme: CardThemeData(
          color: NoctelleColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: NoctelleColors.outline),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.transparent,
          indicatorColor: NoctelleColors.mint.withValues(alpha: 0.14),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected ? NoctelleColors.mint : NoctelleColors.muted,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            );
          }),
        ),
      ),
      // batasi lebar agar tampil seperti HP saat dibuka di Chrome
      builder: (context, child) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: child,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

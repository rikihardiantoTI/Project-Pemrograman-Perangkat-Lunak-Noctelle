import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/sleep_provider.dart';
import 'screens/main_shell.dart';

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
        scaffoldBackgroundColor: const Color(0xFF0E1330),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A2147),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      // batasi lebar agar tampil seperti HP saat dibuka di Chrome
      builder: (context, child) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: child,
        ),
      ),
      home: const MainShell(),
    );
  }
}
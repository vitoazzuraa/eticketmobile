import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/supabase_client.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // Warna biru khas Facebook
  static const facebookBlue = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'E-Ticket Helpdesk',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5), // abu muda khas Facebook
        colorScheme: ColorScheme.fromSeed(
          seedColor: facebookBlue,
          brightness: Brightness.light,
          primary: facebookBlue,
        ),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: facebookBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: facebookBlue,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: facebookBlue),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: facebookBlue,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: facebookBlue, width: 2),
          ),
          border: OutlineInputBorder(),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF18191A), // gelap khas Facebook dark mode
        colorScheme: ColorScheme.fromSeed(
          seedColor: facebookBlue,
          brightness: Brightness.dark,
          primary: facebookBlue,
        ),
        cardColor: const Color(0xFF242526),
        appBarTheme: const AppBarTheme(
          backgroundColor: facebookBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: facebookBlue,
            foregroundColor: Colors.white,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: facebookBlue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
import 'package:flutter/material.dart';
import 'core/dummy_data.dart';
import 'features/auth/presentation/splash_screen.dart';

void main() => runApp(const AdminApp());

class AdminApp extends StatelessWidget {
  const AdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: DummyData.themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF0F2F5),
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1877F2)),
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            fontFamily: 'Roboto',
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'main_nav_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool minimumDelayDone = false;

  @override
  void initState() {
    super.initState();
    // Jeda splash screen 2 detik supaya logo dan nama app sempat terlihat,
    // tidak langsung lompat walau sesi login sudah ketahuan lebih cepat
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => minimumDelayDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    final brandingView = Scaffold(
      backgroundColor: const Color(0xFF1877F2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.confirmation_number, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'E-Ticket Helpdesk',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );

    // Selama jeda minimum belum lewat, tetap tampilkan branding
    // apapun status authState-nya (sudah selesai atau belum)
    if (!minimumDelayDone) return brandingView;

    return authState.when(
      data: (state) {
        final isLoggedIn = state.session != null;
        return isLoggedIn ? const MainNavScreen() : const LoginScreen();
      },
      loading: () => brandingView,
      error: (e, _) => const LoginScreen(),
    );
  }
}
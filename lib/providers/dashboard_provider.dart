import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dashboard_service.dart';
import 'auth_provider.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) => DashboardService());

// Statistik jumlah tiket per status, sesuai role yang login
// watch authStateProvider supaya refetch saat ganti akun
final dashboardStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  ref.watch(authStateProvider);
  return ref.read(dashboardServiceProvider).getStatistics();
});
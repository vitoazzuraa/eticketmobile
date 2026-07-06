import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

// Provider AuthService, dipanggil dari mana saja: ref.read(authServiceProvider)
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Stream status login, dipakai untuk auto redirect login/home
// Cara pakai di widget: final authState = ref.watch(authStateProvider);
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

// Role user yang sedang login, dipakai untuk tampilkan menu sesuai role
// watch authStateProvider supaya otomatis refetch saat ganti akun (login/logout)
final myRoleProvider = FutureProvider<String?>((ref) async {
  ref.watch(authStateProvider);
  return ref.read(authServiceProvider).getMyRole();
});
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_client.dart';

class AuthService {
  // Login dengan email dan password
  Future<AuthResponse> login(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Register, full_name dikirim ke metadata, nanti dibaca trigger
  // handle_new_user di Supabase untuk diisi otomatis ke tabel profiles
  Future<AuthResponse> register(String email, String password, String fullName) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  // Ganti password saat masih dalam keadaan login (bukan lewat email)
  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  // User yang sedang login, null kalau belum login
  User? get currentUser => supabase.auth.currentUser;

  // Dengarkan perubahan status login (untuk splash screen / auto redirect)
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  // Ambil data role dari tabel profiles
  Future<String?> getMyRole() async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    final data = await supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();
    return data['role'] as String?;
  }

  // Ambil profil user yang sedang login.
  // Dipakai setelah login untuk mengecek apakah akun masih aktif.
  Future<Map<String, dynamic>?> getMyProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    return await supabase
        .from('profiles')
        .select('id, email, full_name, role, is_active')
        .eq('id', userId)
        .maybeSingle();
  }

  Future<bool> isCurrentUserActive() async {
    final profile = await getMyProfile();
    return profile?['is_active'] == true;
  }
}

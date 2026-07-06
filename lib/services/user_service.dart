import '../core/supabase_client.dart';
import '../models/profile_model.dart';

class UserService {
  // Dipakai admin untuk lihat daftar semua pengguna
  Future<List<Profile>> getAllUsers() async {
    final data = await supabase.from('profiles').select().order('created_at');
    return (data as List).map((e) => Profile.fromMap(e)).toList();
  }

  // Dipakai admin saat assign tiket, hanya tampilkan role helpdesk
  Future<List<Profile>> getHelpdeskUsers() async {
    final data = await supabase.from('profiles').select().eq('role', 'helpdesk');
    return (data as List).map((e) => Profile.fromMap(e)).toList();
  }

  Future<void> updateRole(String userId, String role) async {
    await supabase.from('profiles').update({'role': role}).eq('id', userId);
  }

  Future<void> setActive(String userId, bool isActive) async {
    await supabase.from('profiles').update({'is_active': isActive}).eq('id', userId);
  }
}
import '../core/supabase_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  // Notifikasi terisi otomatis lewat trigger saat status tiket berubah
  Future<List<AppNotification>> getNotifications(String userId) async {
    final data = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => AppNotification.fromMap(e)).toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await supabase.from('notifications').update({'is_read': true}).eq('id', notificationId);
  }

  // Dengarkan notifikasi baru secara realtime, dipakai untuk badge/popup
  Stream<List<Map<String, dynamic>>> watchNotifications(String userId) {
    return supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId);
  }
}
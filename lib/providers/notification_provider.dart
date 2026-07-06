import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import 'auth_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

// Daftar notifikasi milik user yang sedang login
// watch authStateProvider supaya refetch saat ganti akun
final notificationListProvider = FutureProvider<List<AppNotification>>((ref) async {
  ref.watch(authStateProvider);
  final userId = ref.read(authServiceProvider).currentUser?.id;
  if (userId == null) return [];
  return ref.read(notificationServiceProvider).getNotifications(userId);
});

// Dengarkan notifikasi baru secara realtime, dipakai untuk badge
final notificationStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final userId = ref.read(authServiceProvider).currentUser?.id;
  if (userId == null) return const Stream.empty();
  return ref.read(notificationServiceProvider).watchNotifications(userId);
});
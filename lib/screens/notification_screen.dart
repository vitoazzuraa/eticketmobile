import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import 'ticket_detail_screen.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  static const facebookBlue = Color(0xFF1877F2);

  static const monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String formatDateTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${monthNames[dt.month - 1]} ${dt.year}, $hh:$mm';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: notifAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(child: Text('Belum ada notifikasi', style: TextStyle(color: theme.hintColor)));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Card(
                  color: n.isRead ? theme.cardColor : facebookBlue.withOpacity(0.08),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: n.isRead ? theme.dividerColor : facebookBlue,
                      child: Icon(
                        n.isRead ? Icons.notifications_none : Icons.notifications_active,
                        color: n.isRead ? theme.hintColor : Colors.white,
                      ),
                    ),
                    title: Text(
                      n.message,
                      style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        formatDateTime(n.createdAt),
                        style: TextStyle(fontSize: 12, color: theme.hintColor),
                      ),
                    ),
                    onTap: () async {
                      await ref.read(notificationServiceProvider).markAsRead(n.id);
                      ref.invalidate(notificationListProvider);

                      // Navigasi ke halaman terkait, sesuai FR-008 poin 2 di SRS
                      if (n.ticketId != null && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TicketDetailScreen(ticketId: n.ticketId!),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ticket_provider.dart';

class TicketTrackingScreen extends ConsumerWidget {
  final String ticketId;
  const TicketTrackingScreen({super.key, required this.ticketId});

  static const facebookBlue = Color(0xFF1877F2);

  static const statusColor = {
    'open': Colors.orange,
    'assigned': facebookBlue,
    'in_progress': Colors.purple,
    'closed': Colors.green,
  };

  static const statusLabel = {
    'open': 'Terbuka',
    'assigned': 'Ditugaskan',
    'in_progress': 'Diproses',
    'closed': 'Selesai',
  };

  static const monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String formatDateTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${monthNames[dt.month - 1]} ${dt.year}, $hh:$mm';
  }

  Widget statusChip(String? status, ThemeData theme) {
    if (status == null) {
      return Chip(
        label: const Text('Dibuat', style: TextStyle(fontSize: 12)),
        backgroundColor: theme.cardColor,
        visualDensity: VisualDensity.compact,
      );
    }
    final color = statusColor[status] ?? facebookBlue;
    return Chip(
      label: Text(
        statusLabel[status] ?? status,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
      backgroundColor: color.withOpacity(0.12),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color.withOpacity(0.4)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(ticketHistoryProvider(ticketId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tracking Tiket')),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return Center(child: Text('Belum ada riwayat', style: TextStyle(color: theme.hintColor)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final h = history[index];
              final isLast = index == history.length - 1;
              final newColor = statusColor[h['new_status']] ?? facebookBlue;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Garis timeline di kiri
                    Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: newColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(width: 2, color: theme.dividerColor),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    statusChip(h['old_status'], theme),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                      child: Icon(Icons.arrow_forward, size: 14, color: theme.hintColor),
                                    ),
                                    statusChip(h['new_status'], theme),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  formatDateTime(DateTime.parse(h['created_at'])),
                                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
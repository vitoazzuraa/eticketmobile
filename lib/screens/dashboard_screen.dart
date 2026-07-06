import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../providers/ticket_provider.dart';
import 'ticket_create_screen.dart';
import 'ticket_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const facebookBlue = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final ticketsAsync = ref.watch(ticketListProvider);
    final theme = Theme.of(context);
    final subtleText = theme.textTheme.bodyMedium?.color?.withOpacity(0.6);

    final statusColor = {
      'open': Colors.orange,
      'assigned': facebookBlue,
      'in_progress': Colors.purple,
      'closed': Colors.green,
    };

    // Label Bahasa Indonesia untuk tiap status statistik
    const statusLabel = {
      'total': 'Total',
      'open': 'Terbuka',
      'assigned': 'Ditugaskan',
      'in_progress': 'Diproses',
      'closed': 'Selesai',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(ticketListProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tombol tambah tiket cepat, model card seperti "create post" di Facebook
            Card(
              clipBehavior: Clip.antiAlias, // supaya isi ikut terpotong rapi sesuai sudut melengkung
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const CircleAvatar(
                  radius: 18,
                  backgroundColor: facebookBlue,
                  child: Icon(Icons.add, color: Colors.white, size: 20),
                ),
                title: const Text('Buat tiket baru...', style: TextStyle(fontSize: 15)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TicketCreateScreen()),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Statistik tiket, sesuai FR-009 di SRS, tampil horizontal 5 sejajar
            statsAsync.when(
              data: (stats) => SizedBox(
                height: 96,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      children: stats.entries.map((e) {
                    final color = statusColor[e.key] ?? facebookBlue;
                    final label = statusLabel[e.key] ?? e.key;
                    return Container(
                      width: 110,
                      margin: const EdgeInsets.only(right: 10),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, size: 10, color: color),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      label,
                                      style: TextStyle(color: subtleText, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${e.value}',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  ),
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),

            const SizedBox(height: 20),
            Text('Tiket Terbaru', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Tiket terbaru, agar Home tidak cuma statistik kosong
            ticketsAsync.when(
              data: (tickets) {
                final recent = tickets.take(5).toList();
                if (recent.isEmpty) {
                  return Text('Belum ada tiket', style: TextStyle(color: subtleText));
                }
                return Column(
                  children: recent.map((t) {
                    final color = statusColor[t.status] ?? facebookBlue;
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.15),
                          child: Icon(Icons.confirmation_number, color: color),
                        ),
                        title: Text(t.title),
                        subtitle: Text('${t.status} - ${t.priority}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TicketDetailScreen(ticketId: t.id),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
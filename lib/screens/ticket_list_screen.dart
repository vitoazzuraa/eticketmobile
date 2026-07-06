import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ticket_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'ticket_create_screen.dart';
import 'ticket_detail_screen.dart';

class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen> {
  String? selectedHelpdeskId; // null = tampil semua, khusus filter admin

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(myRoleProvider);
    final ticketsAsync = ref.watch(ticketsByHelpdeskFilterProvider(selectedHelpdeskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tiket'),
      ),
      body: Column(
        children: [
          // Filter berdasarkan helpdesk, hanya tampil untuk Admin
          // sesuai FR-007 poin 3 di SRS
          if (roleAsync.value == 'admin')
            Padding(
              padding: const EdgeInsets.all(8),
              child: Consumer(
                builder: (context, ref, _) {
                  final helpdeskAsync = ref.watch(helpdeskUsersProvider);
                  return helpdeskAsync.when(
                    data: (helpdeskList) => Row(
                      children: [
                        const Text('Filter helpdesk: '),
                        DropdownButton<String?>(
                          value: selectedHelpdeskId,
                          hint: const Text('Semua'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Semua')),
                            ...helpdeskList.map((h) => DropdownMenuItem(
                                  value: h.id,
                                  child: Text(h.fullName ?? h.email ?? h.id),
                                )),
                          ],
                          onChanged: (value) => setState(() => selectedHelpdeskId = value),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => const SizedBox.shrink(),
                  );
                },
              ),
            ),
          Expanded(
            child: ticketsAsync.when(
              data: (tickets) {
                if (tickets.isEmpty) {
                  return const Center(child: Text('Belum ada tiket'));
                }
                return ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final t = tickets[index];
                    return ListTile(
                      title: Text(t.title),
                      subtitle: Text('${t.status} - ${t.priority}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TicketDetailScreen(ticketId: t.id),
                          ),
                        ).then((_) => ref.invalidate(ticketsByHelpdeskFilterProvider(selectedHelpdeskId)));
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TicketCreateScreen()),
          ).then((_) => ref.invalidate(ticketsByHelpdeskFilterProvider(selectedHelpdeskId)));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
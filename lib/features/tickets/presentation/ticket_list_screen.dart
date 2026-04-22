import 'package:flutter/material.dart';
import '../../../core/dummy_data.dart';
import 'ticket_detail_screen.dart';

class AdminTicketListScreen extends StatelessWidget {
  const AdminTicketListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Tiket", style: TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        itemCount: DummyData.allTickets.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final ticket = DummyData.allTickets[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(backgroundImage: NetworkImage(ticket['userAvatar'])),
            title: Text(ticket['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Oleh: ${ticket['user']}"),
                Text("Assigned: ${ticket['assignedTo']}", style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _getStatusColor(ticket['status']), borderRadius: BorderRadius.circular(4)),
                  child: Text(ticket['status'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TicketDetailScreen(ticket: ticket))),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Open') return Colors.red.shade400;
    if (status == 'In Progress') return Colors.orange.shade400;
    return Colors.green.shade400;
  }
}
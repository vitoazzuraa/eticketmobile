import 'package:flutter/material.dart';
import '../../../core/dummy_data.dart';
import '../../tickets/presentation/ticket_detail_screen.dart';
import '../../tickets/presentation/create_ticket_screen.dart';
import 'notification_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Beranda", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1877F2))),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Row(
                children: DummyData.adminStats.map((stat) => Expanded(child: _buildStatBox(stat, context))).toList(),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).cardColor,
              child: Row(
                children: [
                  const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTicketScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.15), borderRadius: BorderRadius.circular(24)),
                        child: const Text("Ada kendala IT apa hari ini?", style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.photo_library, color: Colors.green),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: const Text("Tiket Terbaru", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ticket = DummyData.allTickets[index];
                return _buildTicketPost(ticket, context);
              },
              childCount: DummyData.allTickets.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(Map<String, dynamic> stat, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(stat['icon'], color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(stat['value'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          Text(stat['label'], style: const TextStyle(fontSize: 11), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTicketPost(Map<String, dynamic> ticket, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), 
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(ticket['userAvatar'])),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticket['user'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        Text(ticket['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(width: 6),
                        Icon(Icons.public, size: 12, color: Colors.grey[600]),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ticket['status'] == 'Open' ? Colors.red[50] : (ticket['status'] == 'Resolved' ? Colors.green[50] : Colors.orange[50]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ticket['status'], 
                  style: TextStyle(
                    color: ticket['status'] == 'Open' ? Colors.red : (ticket['status'] == 'Resolved' ? Colors.green : Colors.orange), 
                    fontWeight: FontWeight.bold, fontSize: 12
                  )
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(ticket['title'], style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: ticket))),
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                  label: const Text("Buka Mode Tindakan & Chat", style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
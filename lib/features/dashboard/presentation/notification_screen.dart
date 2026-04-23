import 'package:flutter/material.dart';
import '../../../core/dummy_data.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifikasi", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        itemCount: DummyData.notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notif = DummyData.notifications[index];
          return Container(
            color: notif['isRead'] ? Theme.of(context).scaffoldBackgroundColor : Colors.blue.withOpacity(0.05),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: notif['isRead'] ? Colors.grey[300] : const Color(0xFF1877F2),
                child: Icon(notif['icon'], color: notif['isRead'] ? Colors.grey[600] : Colors.white, size: 20),
              ),
              title: Text(notif['title'], style: TextStyle(fontWeight: notif['isRead'] ? FontWeight.normal : FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(notif['body'], style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(notif['time'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
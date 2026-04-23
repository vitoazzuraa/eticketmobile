import 'package:flutter/material.dart';

class DummyData {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
    ThemeMode.light,
  );

  static const Map<String, dynamic> adminProfile = {
    'name': 'Vito',
    'role': 'Administrator',
    'avatar': 'https://i.pravatar.cc/150?u=admin',
  };

  static const List<Map<String, dynamic>> adminStats = [
    {'label': 'Total Tiket', 'value': '45', 'icon': Icons.analytics},
    {
      'label': 'Perlu Respon',
      'value': '12',
      'icon': Icons.warning_amber_rounded,
    },
    {'label': 'Selesai', 'value': '28', 'icon': Icons.check_circle_outline},
  ];

  static const List<Map<String, dynamic>> allTickets = [
    {
      'id': 'USER-001',
      'user': 'Walter White',
      'userAvatar': 'https://i.pravatar.cc/150?u=budi',
      'title': 'Jaringan WiFi Lantai 3 Mati Total',
      'status': 'Open',
      'date': '12 Apr 2026 • 10:30',
      'priority': 'High',
      'assignedTo': 'None',
      'chats': [
        {
          'isMe': false,
          'sender': 'Walter White',
          'text':
              'Halo admin, tolong segera dicek karena kami sedang ada meeting online.',
          'time': '10:32',
        },
      ],
    },
    {
      'id': 'USER-002',
      'user': 'Jesse Pinkman',
      'userAvatar': 'https://i.pravatar.cc/150?u=siti',
      'title': 'Lisensi Software Desain Expired',
      'status': 'In Progress',
      'date': '11 Apr 2026 • 14:15',
      'priority': 'Medium',
      'assignedTo': 'Anto (Helpdesk)',
      'chats': [
        {
          'isMe': false,
          'sender': 'Jesse Pinkman',
          'text': 'Admin, lisensi saya habis.',
          'time': '14:15',
        },
        {
          'isMe': true,
          'sender': 'Saul Goodman',
          'text':
              'Baik Bu Jesse, sedang kami proses perpanjangannya ke vendor.',
          'time': '14:30',
        },
        {
          'isMe': false,
          'sender': 'Jesse Pinkman',
          'text': 'Terima kasih, mohon infonya kalau sudah bisa dipakai.',
          'time': '14:35',
        },
      ],
    },
  ];

  static const List<String> helpdeskStaff = [
    'Skyler (Helpdesk)',
    'Hank (Helpdesk)',
    'Saul Goodman (Helpdesk)',
  ];

  static const List<Map<String, dynamic>> notifications = [
    {
      'title': 'Status Tiket Diperbarui',
      'body':
          'Tiket "Jaringan WiFi Lantai 3 Mati Total" sekarang berstatus In Progress.',
      'time': '5 mnt lalu',
      'isRead': false,
      'icon': Icons.rule,
    },
    {
      'title': 'Pesan Baru',
      'body': 'Siti Aminah membalas tiket "Lisensi Software Desain Expired".',
      'time': '1 jam lalu',
      'isRead': false,
      'icon': Icons.chat_bubble,
    },
    {
      'title': 'Tiket Selesai',
      'body': 'Tiket "Proyektor Ruang Rapat" telah ditutup oleh Admin.',
      'time': 'Kemarin',
      'isRead': true,
      'icon': Icons.check_circle,
    },
  ];
}

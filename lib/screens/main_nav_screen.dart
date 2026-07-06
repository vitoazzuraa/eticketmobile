import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'ticket_list_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int currentIndex = 0;

  final pages = const [
    DashboardScreen(),
    TicketListScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  static const facebookBlue = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        type: BottomNavigationBarType.fixed,
        // Beda warna dari header (header biru), tapi tetap konsisten dengan
        // tema terang/gelap yang aktif, jadi ikut berubah saat dark mode
        backgroundColor: theme.cardColor,
        selectedItemColor: facebookBlue,
        unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'Tiket'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
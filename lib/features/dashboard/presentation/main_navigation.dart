import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import '../../tickets/presentation/ticket_list_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _screens = [DashboardScreen(), AdminTicketListScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue[900],
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Kelola Tiket'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Profil'),
        ],
      ),
    );
  }
}
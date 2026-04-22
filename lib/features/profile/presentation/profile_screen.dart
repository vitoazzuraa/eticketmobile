import 'package:flutter/material.dart';
import '../../../core/dummy_data.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(radius: 50, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin')),
          const SizedBox(height: 10),
          Text(DummyData.adminProfile['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),
          // Toggle Tema 
          ValueListenableBuilder<ThemeMode>(
            valueListenable: DummyData.themeNotifier,
            builder: (_, mode, __) {
              return ListTile(
                leading: Icon(mode == ThemeMode.light ? Icons.light_mode : Icons.dark_mode),
                title: const Text("Mode Gelap"),
                trailing: Switch(
                  value: mode == ThemeMode.dark,
                  onChanged: (val) {
                    DummyData.themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              );
            },
          ),
          const ListTile(leading: Icon(Icons.logout, color: Colors.red), title: Text("Logout", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class CreateTicketScreen extends StatelessWidget {
  const CreateTicketScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Tiket Baru", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tiket berhasil dibuat!")),
              );
            },
            child: const Text("KIRIM", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1877F2))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin')),
                const SizedBox(width: 12),
                const Text("Admin Utama (God Mode)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                hintText: "Judul Keluhan (Misal: Printer Rusak)",
                border: UnderlineInputBorder(),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            const TextField(
              maxLines: 8,
              decoration: InputDecoration(
                hintText: "Jelaskan detail kendala IT yang Anda alami...",
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt, color: Colors.green),
              label: const Text("Lampirkan Foto/Screenshot", style: TextStyle(color: Colors.black87)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                alignment: Alignment.centerLeft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
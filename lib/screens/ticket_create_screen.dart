import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/ticket_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/ticket_model.dart';

class TicketCreateScreen extends ConsumerStatefulWidget {
  const TicketCreateScreen({super.key});

  @override
  ConsumerState<TicketCreateScreen> createState() => _TicketCreateScreenState();
}

class _TicketCreateScreenState extends ConsumerState<TicketCreateScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  String category = 'hardware';
  String priority = 'medium';
  Uint8List? pickedImageBytes; // dipakai untuk preview, kompatibel di semua platform termasuk web
  String? pickedImageName;
  bool isLoading = false;
  String? errorMessage;

  // Pakai XFile + readAsBytes(), bukan dart:io File, supaya jalan juga di Flutter Web
  Future<void> pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        pickedImageBytes = bytes;
        pickedImageName = picked.name;
      });
    }
  }

  Future<void> handleSubmit() async {
    final userId = ref.read(authServiceProvider).currentUser?.id;
    if (userId == null) return;

    if (titleController.text.trim().isEmpty) {
      setState(() => errorMessage = 'Judul tidak boleh kosong');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      // 1. Buat tiket dulu, dapatkan id-nya
      final ticketId = await ref.read(ticketServiceProvider).createTicket(
            Ticket(
              id: '',
              title: titleController.text.trim(),
              description: descController.text.trim(),
              category: category,
              priority: priority,
              status: 'open',
              createdBy: userId,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

      // 2. Kalau ada gambar dipilih, upload dan kaitkan ke tiket di atas
      if (pickedImageBytes != null) {
        await ref.read(attachmentServiceProvider).uploadAttachment(
              ticketId,
              userId,
              pickedImageBytes!,
              pickedImageName ?? 'gambar.jpg',
            );
      }

      if (!mounted) return;
      // Refresh semua provider yang menampilkan data tiket, supaya tiket baru
      // langsung muncul baik dibuka dari Dashboard maupun dari Daftar Tiket
      ref.invalidate(ticketListProvider);
      ref.invalidate(ticketsByHelpdeskFilterProvider);
      ref.invalidate(dashboardStatsProvider);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => errorMessage = 'Gagal membuat tiket, coba lagi');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Tiket')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: const [
                DropdownMenuItem(value: 'hardware', child: Text('Hardware')),
                DropdownMenuItem(value: 'software', child: Text('Software')),
                DropdownMenuItem(value: 'network', child: Text('Jaringan')),
                DropdownMenuItem(value: 'other', child: Text('Lainnya')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => category = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: priority,
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (value) => setState(() => priority = value!),
            ),
            const SizedBox(height: 12),

            // Upload laporan, sesuai FR-005 poin 2 di SRS: dari galeri atau kamera
            // pakai Image.memory, bukan Image.file, supaya kompatibel di Flutter Web
            if (pickedImageBytes != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Image.memory(pickedImageBytes!, height: 120),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeri'),
                ),
                TextButton.icon(
                  onPressed: () => pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: handleSubmit,
                    child: const Text('Kirim Tiket'),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }
}

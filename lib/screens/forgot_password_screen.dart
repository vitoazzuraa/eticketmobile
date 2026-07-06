import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isLoading = false;
  String? message;

  bool isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> handleReset() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() => message = 'Email tidak boleh kosong');
      return;
    }
    if (!isValidEmail(email)) {
      setState(() => message = 'Format email tidak valid, contoh: nama@email.com');
      return;
    }
    setState(() {
      isLoading = true;
      message = null;
    });
    try {
      await ref.read(authServiceProvider).resetPassword(email);
      if (mounted) setState(() => message = 'Link reset password sudah dikirim ke email');
    } catch (e) {
      if (mounted) setState(() => message = 'Gagal mengirim link reset, pastikan email benar');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            if (message != null) Text(message!),
            const SizedBox(height: 8),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: handleReset,
                    child: const Text('Kirim Link Reset'),
                  ),
          ],
        ),
      ),
    );
  }
}

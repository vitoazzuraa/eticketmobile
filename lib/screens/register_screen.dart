import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  static const facebookBlue = Color(0xFF1877F2);

  bool isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> handleRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'Semua field wajib diisi');
      return;
    }
    if (!isValidEmail(email)) {
      setState(() => errorMessage = 'Format email tidak valid, contoh: nama@email.com');
      return;
    }
    if (password.length < 6) {
      setState(() => errorMessage = 'Password minimal 6 karakter');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await ref.read(authServiceProvider).register(email, password, name);
      if (!mounted) return;
      Navigator.pop(context); // balik ke login setelah register
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('already registered') || msg.contains('already exists')) {
        setState(() => errorMessage = 'Email sudah terdaftar, coba login');
      } else if (msg.contains('invalid format') || msg.contains('validate email')) {
        setState(() => errorMessage = 'Format email tidak valid');
      } else if (msg.contains('Password should be at least')) {
        setState(() => errorMessage = 'Password minimal 6 karakter');
      } else {
        setState(() => errorMessage = 'Gagal mendaftar, coba lagi');
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(color: facebookBlue, shape: BoxShape.circle),
                      child: const Icon(Icons.person_add, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Buat Akun Baru',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Daftar untuk mulai melaporkan tiket',
                      style: TextStyle(color: theme.hintColor, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscurePassword = !obscurePassword),
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              ],

              const SizedBox(height: 20),

              SizedBox(
                height: 48,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: handleRegister,
                        child: const Text('Register', style: TextStyle(fontSize: 16)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

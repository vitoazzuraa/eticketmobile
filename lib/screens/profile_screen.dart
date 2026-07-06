import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'setting_screen.dart';
import 'admin_user_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const facebookBlue = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authServiceProvider).currentUser;
    final roleAsync = ref.watch(myRoleProvider);
    final theme = Theme.of(context);
    final subtleText = theme.textTheme.bodyMedium?.color?.withOpacity(0.6);

    final initial = (user?.email ?? '?').substring(0, 1).toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          // Header mirip cover + avatar profile Facebook
          Container(
            color: facebookBlue,
            padding: const EdgeInsets.only(bottom: 24, top: 12),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    initial,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: facebookBlue),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.email ?? '-',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                roleAsync.when(
                  data: (role) {
                    final roleLabel = {
                          'admin': 'Admin',
                          'helpdesk': 'Helpdesk',
                          'user': 'User',
                        }[role] ??
                        '-';
                    final roleIcon = {
                      'admin': Icons.shield,
                      'helpdesk': Icons.support_agent,
                      'user': Icons.person_outline,
                    }[role];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (roleIcon != null) Icon(roleIcon, size: 14, color: Colors.white),
                          if (roleIcon != null) const SizedBox(width: 6),
                          Text(
                            roleLabel,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Text('memuat...', style: TextStyle(color: Colors.white70)),
                  error: (e, _) => const Text('error', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.settings, color: subtleText),
                  title: const Text('Setting'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.lock_outline, color: subtleText),
                  title: const Text('Ganti Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                    );
                  },
                ),

                // Hanya tampil untuk admin, sesuai FR-007 poin 7 di SRS
                if (roleAsync.value == 'admin')
                  ListTile(
                    leading: Icon(Icons.manage_accounts, color: subtleText),
                    title: const Text('Kelola Pengguna'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminUserScreen()),
                      );
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await ref.read(authServiceProvider).logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
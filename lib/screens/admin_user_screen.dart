import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';

class AdminUserScreen extends ConsumerWidget {
  const AdminUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Pengguna')),
      body: usersAsync.when(
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final u = users[index];
            return ListTile(
              title: Text(u.fullName ?? u.email ?? '-'),
              subtitle: Text(u.email ?? '-'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: u.role,
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('User')),
                      DropdownMenuItem(value: 'helpdesk', child: Text('Helpdesk')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;
                      await ref.read(userServiceProvider).updateRole(u.id, value);
                      ref.invalidate(allUsersProvider);
                    },
                  ),
                  Switch(
                    value: u.isActive,
                    onChanged: (value) async {
                      await ref.read(userServiceProvider).setActive(u.id, value);
                      ref.invalidate(allUsersProvider);
                    },
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
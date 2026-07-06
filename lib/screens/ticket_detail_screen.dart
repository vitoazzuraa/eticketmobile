import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ticket_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';
import 'ticket_tracking_screen.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final commentController = TextEditingController();
  static const facebookBlue = Color(0xFF1877F2);

  Future<void> handleAddComment() async {
    final userId = ref.read(authServiceProvider).currentUser?.id;
    if (userId == null || commentController.text.trim().isEmpty) return;
    await ref.read(commentServiceProvider).addComment(
          widget.ticketId,
          userId,
          commentController.text.trim(),
        );
    commentController.clear();
    ref.invalidate(ticketCommentsProvider(widget.ticketId));
    ref.invalidate(notificationListProvider);
  }

  Future<void> handleUpdateStatus(String newStatus) async {
    await ref.read(ticketServiceProvider).updateStatus(widget.ticketId, newStatus);
    ref.invalidate(ticketDetailProvider(widget.ticketId));
    ref.invalidate(ticketHistoryProvider(widget.ticketId));
  }

  Future<void> handleAssign(String helpdeskId) async {
    await ref.read(ticketServiceProvider).assignTicket(widget.ticketId, helpdeskId);
    ref.invalidate(ticketDetailProvider(widget.ticketId));
  }

  Future<void> handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus tiket?'),
        content: const Text('Tiket akan disembunyikan dari daftar (soft delete).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(ticketServiceProvider).deleteTicket(widget.ticketId);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  // Format tanggal/jam sederhana tanpa package intl, contoh: "Sen, 14:05"
  String formatChatTime(DateTime dt) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final day = days[dt.weekday - 1];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$day, $hh:$mm';
  }

  String getFileName(String fileUrl) {
    final uri = Uri.tryParse(fileUrl);
    final lastSegment = uri?.pathSegments.isNotEmpty == true ? uri!.pathSegments.last : fileUrl;
    return Uri.decodeComponent(lastSegment);
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(ticketDetailProvider(widget.ticketId));
    final commentsAsync = ref.watch(ticketCommentsProvider(widget.ticketId));
    final attachmentsAsync = ref.watch(ticketAttachmentsProvider(widget.ticketId));
    final roleAsync = ref.watch(myRoleProvider);
    final myId = ref.read(authServiceProvider).currentUser?.id;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TicketTrackingScreen(ticketId: widget.ticketId),
                ),
              );
            },
          ),
          // Hapus tiket, khusus admin, sesuai BR-002 poin 8 di SRS
          if (roleAsync.value == 'admin')
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: handleDelete,
            ),
        ],
      ),
      body: ticketAsync.when(
        data: (ticket) {
          final role = roleAsync.value;
          final isHelpdeskOrAdmin = role == 'helpdesk' || role == 'admin';
          final isAdmin = role == 'admin';
          final isClosed = ticket.status == 'closed';

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticket.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(ticket.description ?? ''),
                    const SizedBox(height: 8),
                    Text('Status: ${ticket.status} | Priority: ${ticket.priority}'),

                    // Hanya Helpdesk (yang ditugaskan) dan Admin yang bisa ubah status
                    // sesuai FR-006 dan FR-007 di SRS
                    if (isHelpdeskOrAdmin) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Ubah status: '),
                          DropdownButton<String>(
                            value: ticket.status,
                            items: const [
                              DropdownMenuItem(value: 'open', child: Text('Open')),
                              DropdownMenuItem(value: 'assigned', child: Text('Assigned')),
                              DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                              DropdownMenuItem(value: 'closed', child: Text('Closed')),
                            ],
                            onChanged: (value) {
                              if (value != null) handleUpdateStatus(value);
                            },
                          ),
                        ],
                      ),
                    ],

                    // Hanya Admin yang bisa assign tiket ke Helpdesk
                    // sesuai FR-007 poin 4 di SRS
                    if (isAdmin) ...[
                      const SizedBox(height: 8),
                      Consumer(
                        builder: (context, ref, _) {
                          final helpdeskAsync = ref.watch(helpdeskUsersProvider);
                          return helpdeskAsync.when(
                            data: (helpdeskList) => Row(
                              children: [
                                const Text('Assign ke: '),
                                DropdownButton<String>(
                                  value: ticket.assignedTo,
                                  hint: const Text('Pilih helpdesk'),
                                  items: helpdeskList
                                      .map((h) => DropdownMenuItem(
                                            value: h.id,
                                            child: Text(h.fullName ?? h.email ?? h.id),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) handleAssign(value);
                                  },
                                ),
                              ],
                            ),
                            loading: () => const Text('Memuat daftar helpdesk...'),
                            error: (e, _) => Text('Gagal memuat helpdesk: $e'),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 12),
                    attachmentsAsync.when(
                      data: (attachments) {
                        if (attachments.isEmpty) {
                          return Text('Belum ada lampiran', style: TextStyle(color: theme.hintColor));
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Lampiran', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 96,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: attachments.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final fileUrl = attachments[index]['file_url'] as String;

                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      fileUrl,
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 160,
                                        height: 96,
                                        color: theme.cardColor,
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.insert_drive_file),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                getFileName(fileUrl),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Text('Memuat lampiran...'),
                      error: (e, _) => Text('Gagal memuat lampiran: $e'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ===== Bagian chat komentar, gaya Messenger =====
              Expanded(
                child: commentsAsync.when(
                  data: (comments) {
                    if (comments.isEmpty) {
                      return Center(
                        child: Text('Belum ada komentar', style: TextStyle(color: theme.hintColor)),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final c = comments[index];
                        final isMe = c['user_id'] == myId;
                        final senderName = (c['sender_name'] ?? 'Pengguna') as String;
                        final initial = senderName.isNotEmpty ? senderName.substring(0, 1).toUpperCase() : '?';
                        final createdAt = DateTime.parse(c['created_at']);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isMe) ...[
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: facebookBlue,
                                  child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 13)),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4, bottom: 2),
                                        child: Text(
                                          senderName,
                                          style: TextStyle(fontSize: 11, color: theme.hintColor),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isMe ? facebookBlue : theme.cardColor,
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(16),
                                          topRight: const Radius.circular(16),
                                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                                          bottomRight: Radius.circular(isMe ? 4 : 16),
                                        ),
                                      ),
                                      child: Text(
                                        c['comment'],
                                        style: TextStyle(color: isMe ? Colors.white : theme.textTheme.bodyMedium?.color),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                                      child: Text(
                                        formatChatTime(createdAt),
                                        style: TextStyle(fontSize: 10, color: theme.hintColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),

              // Input chat.
              // Tiket closed dikunci supaya diskusi tidak berlanjut di tiket yang sudah selesai.
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: isClosed
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Tiket sudah closed. Komentar baru tidak dapat ditambahkan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.hintColor),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: commentController,
                                decoration: InputDecoration(
                                  hintText: 'Tulis pesan...',
                                  filled: true,
                                  fillColor: theme.cardColor,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            CircleAvatar(
                              backgroundColor: facebookBlue,
                              child: IconButton(
                                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                                onPressed: handleAddComment,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

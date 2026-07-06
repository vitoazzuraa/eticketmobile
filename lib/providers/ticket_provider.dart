import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ticket_service.dart';
import '../services/comment_service.dart';
import '../services/attachment_service.dart';
import '../services/history_service.dart';
import '../models/ticket_model.dart';
import 'auth_provider.dart';

final ticketServiceProvider = Provider<TicketService>((ref) => TicketService());
final commentServiceProvider = Provider<CommentService>((ref) => CommentService());
final attachmentServiceProvider = Provider<AttachmentService>((ref) => AttachmentService());
final historyServiceProvider = Provider<HistoryService>((ref) => HistoryService());

// Daftar tiket sesuai role yang login (RLS otomatis menyaring)
// watch authStateProvider supaya tidak ke-cache data akun lama setelah ganti login
final ticketListProvider = FutureProvider<List<Ticket>>((ref) async {
  ref.watch(authStateProvider);
  return ref.read(ticketServiceProvider).getTickets();
});

// Khusus admin: filter tiket berdasarkan helpdesk yang dipilih, null artinya tampil semua
final ticketsByHelpdeskFilterProvider = FutureProvider.family<List<Ticket>, String?>((ref, helpdeskId) async {
  ref.watch(authStateProvider);
  final service = ref.read(ticketServiceProvider);
  if (helpdeskId == null) return service.getTickets();
  return service.getTicketsByHelpdesk(helpdeskId);
});

// Detail satu tiket, perlu ticketId
// Cara pakai: ref.watch(ticketDetailProvider(ticketId))
final ticketDetailProvider = FutureProvider.family<Ticket, String>((ref, ticketId) async {
  return ref.read(ticketServiceProvider).getTicketDetail(ticketId);
});

// Komentar pada satu tiket, lengkap dengan nama pengirim untuk tampilan chat
final ticketCommentsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, ticketId) async {
  return ref.read(commentServiceProvider).getCommentsWithSender(ticketId);
});

// Riwayat status pada satu tiket
final ticketHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, ticketId) async {
  return ref.read(historyServiceProvider).getHistory(ticketId);
});

// Lampiran pada satu tiket
final ticketAttachmentsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, ticketId) async {
  return ref.read(attachmentServiceProvider).getAttachments(ticketId);
});
import '../core/supabase_client.dart';
import '../models/ticket_model.dart';

class TicketService {
  // Buat tiket baru, dipanggil semua role (user, helpdesk, admin)
  // Mengembalikan id tiket baru, dipakai untuk langsung upload attachment
  Future<String> createTicket(Ticket ticket) async {
    final data = await supabase
        .from('tickets')
        .insert(ticket.toInsertMap())
        .select('id')
        .single();
    return data['id'] as String;
  }

  // Daftar tiket sesuai role yang login, RLS otomatis menyaring
  // jadi query ini sama saja dipanggil dari role apapun
  Future<List<Ticket>> getTickets() async {
    final data = await supabase
        .from('tickets')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => Ticket.fromMap(e)).toList();
  }

  // Khusus admin: filter tiket berdasarkan helpdesk yang ditugaskan
  // sesuai FR-007 poin 3 di SRS
  Future<List<Ticket>> getTicketsByHelpdesk(String helpdeskId) async {
    final data = await supabase
        .from('tickets')
        .select()
        .eq('assigned_to', helpdeskId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Ticket.fromMap(e)).toList();
  }

  Future<Ticket> getTicketDetail(String ticketId) async {
    final data = await supabase
        .from('tickets')
        .select()
        .eq('id', ticketId)
        .single();
    return Ticket.fromMap(data);
  }

  // Dipanggil helpdesk/admin untuk ubah status
  Future<void> updateStatus(String ticketId, String newStatus) async {
    await supabase.from('tickets').update({'status': newStatus}).eq('id', ticketId);
  }

  // Dipanggil admin untuk menugaskan helpdesk
  Future<void> assignTicket(String ticketId, String helpdeskId) async {
    await supabase
        .from('tickets')
        .update({'assigned_to': helpdeskId, 'status': 'assigned'})
        .eq('id', ticketId);
  }

  // Soft delete, hanya admin (dibatasi juga lewat RLS)
  Future<void> deleteTicket(String ticketId) async {
    await supabase.from('tickets').update({'is_deleted': true}).eq('id', ticketId);
  }

  // Dengarkan perubahan tiket secara realtime
  Stream<List<Map<String, dynamic>>> watchTickets() {
    return supabase.from('tickets').stream(primaryKey: ['id']);
  }
}
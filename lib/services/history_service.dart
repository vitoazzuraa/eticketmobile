import '../core/supabase_client.dart';

class HistoryService {
  // Riwayat perubahan status tiket, terisi otomatis lewat trigger di database
  Future<List<Map<String, dynamic>>> getHistory(String ticketId) async {
    final data = await supabase
        .from('ticket_history')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }
}
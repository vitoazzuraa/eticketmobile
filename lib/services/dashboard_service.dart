import '../core/supabase_client.dart';

class DashboardService {
  // Hitung jumlah tiket per status, RLS otomatis menyaring sesuai role yang login
  Future<Map<String, int>> getStatistics() async {
    final data = await supabase.from('tickets').select('status');
    final list = List<Map<String, dynamic>>.from(data);

    final result = {
      'total': list.length,
      'open': 0,
      'assigned': 0,
      'in_progress': 0,
      'closed': 0,
    };

    for (final row in list) {
      final status = row['status'];
      if (result.containsKey(status)) {
        result[status] = result[status]! + 1;
      }
    }

    return result;
  }
}
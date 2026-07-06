import '../core/supabase_client.dart';
import '../models/comment_model.dart';

class CommentService {
  Future<void> addComment(String ticketId, String userId, String comment) async {
    await supabase.from('ticket_comments').insert({
      'ticket_id': ticketId,
      'user_id': userId,
      'comment': comment,
    });
  }

  Future<List<Comment>> getComments(String ticketId) async {
    final data = await supabase
        .from('ticket_comments')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);
    return (data as List).map((e) => Comment.fromMap(e)).toList();
  }

  // Ambil komentar sekaligus nama pengirimnya, dipakai untuk tampilan chat
  // (stream realtime Supabase tidak mendukung join, jadi digabung manual di sini)
  Future<List<Map<String, dynamic>>> getCommentsWithSender(String ticketId) async {
    final comments = await supabase
        .from('ticket_comments')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);

    final commentList = List<Map<String, dynamic>>.from(comments);
    if (commentList.isEmpty) return [];

    final userIds = commentList.map((c) => c['user_id'] as String).toSet().toList();
    final profiles = await supabase.from('profiles').select('id, full_name').inFilter('id', userIds);
    final nameMap = {for (final p in List<Map<String, dynamic>>.from(profiles)) p['id']: p['full_name']};

    return commentList.map((c) {
      return {
        ...c,
        'sender_name': nameMap[c['user_id']] ?? 'Pengguna',
      };
    }).toList();
  }

  // Dengarkan komentar baru secara realtime di halaman detail tiket
  Stream<List<Map<String, dynamic>>> watchComments(String ticketId) {
    return supabase
        .from('ticket_comments')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', ticketId);
  }
}
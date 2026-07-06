import 'dart:typed_data';
import '../core/supabase_client.dart';

class AttachmentService {
  // Upload pakai bytes (Uint8List), supaya kompatibel di semua platform
  // termasuk web (Flutter Web tidak mendukung dart:io File)
  Future<String> uploadAttachment(String ticketId, String uploadedBy, Uint8List bytes, String fileName) async {
    final cleanedFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final safeName = '${DateTime.now().millisecondsSinceEpoch}_$cleanedFileName';
    final path = '$ticketId/$safeName';

    await supabase.storage.from('ticket-attachments').uploadBinary(path, bytes);

    final fileUrl = supabase.storage.from('ticket-attachments').getPublicUrl(path);

    await supabase.from('ticket_attachments').insert({
      'ticket_id': ticketId,
      'file_url': fileUrl,
      'uploaded_by': uploadedBy,
    });

    return fileUrl;
  }

  Future<List<Map<String, dynamic>>> getAttachments(String ticketId) async {
    final data = await supabase
        .from('ticket_attachments')
        .select()
        .eq('ticket_id', ticketId);
    return List<Map<String, dynamic>>.from(data);
  }
}

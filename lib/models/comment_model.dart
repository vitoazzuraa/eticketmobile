class Comment {
  final String id;
  final String ticketId;
  final String userId;
  final String comment;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.comment,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      ticketId: map['ticket_id'],
      userId: map['user_id'],
      comment: map['comment'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
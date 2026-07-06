class Ticket {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final String priority;
  final String status;
  final String createdBy;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;

  Ticket({
    required this.id,
    required this.title,
    this.description,
    this.category,
    required this.priority,
    required this.status,
    required this.createdBy,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
  });

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      priority: map['priority'] ?? 'medium',
      status: map['status'] ?? 'open',
      createdBy: map['created_by'],
      assignedTo: map['assigned_to'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      closedAt: map['closed_at'] != null ? DateTime.parse(map['closed_at']) : null,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'created_by': createdBy,
    };
  }
}
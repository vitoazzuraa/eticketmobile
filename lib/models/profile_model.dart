class Profile {
  final String id;
  final String? fullName;
  final String? email;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  Profile({
    required this.id,
    this.fullName,
    this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      fullName: map['full_name'],
      email: map['email'],
      role: map['role'] ?? 'user',
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
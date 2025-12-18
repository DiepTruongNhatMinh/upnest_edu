class AdminUser {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String roleCode; // ADMIN / LECTURER / STUDENT
  final bool isActive;

  const AdminUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.roleCode,
    required this.isActive,
  });

  AdminUser copyWith({
    int? id,
    String? username,
    String? fullName,
    String? email,
    String? roleCode,
    bool? isActive,
  }) {
    return AdminUser(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      roleCode: roleCode ?? this.roleCode,
      isActive: isActive ?? this.isActive,
    );
  }
}

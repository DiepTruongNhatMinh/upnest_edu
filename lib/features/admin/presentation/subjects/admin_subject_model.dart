class AdminSubject {
  final int id;
  final String code;
  final String name;
  final bool isActive;

  const AdminSubject({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
  });

  AdminSubject copyWith({
    int? id,
    String? code,
    String? name,
    bool? isActive,
  }) {
    return AdminSubject(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }
}

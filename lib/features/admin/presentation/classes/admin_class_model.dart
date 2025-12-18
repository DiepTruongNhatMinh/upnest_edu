class AdminClass {
  final int id;
  final String code;        // VD: LOP10A1
  final String name;        // VD: Lớp 10A1
  final String subjectCode; // VD: MATH
  final String subjectName; // VD: Toán
  final String lecturer;    // VD: gv01 (tạm)
  final bool isActive;

  const AdminClass({
    required this.id,
    required this.code,
    required this.name,
    required this.subjectCode,
    required this.subjectName,
    required this.lecturer,
    required this.isActive,
  });

  AdminClass copyWith({
    int? id,
    String? code,
    String? name,
    String? subjectCode,
    String? subjectName,
    String? lecturer,
    bool? isActive,
  }) {
    return AdminClass(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      subjectCode: subjectCode ?? this.subjectCode,
      subjectName: subjectName ?? this.subjectName,
      lecturer: lecturer ?? this.lecturer,
      isActive: isActive ?? this.isActive,
    );
  }
}

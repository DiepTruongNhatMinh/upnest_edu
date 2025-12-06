enum UserRole {
  admin,
  lecturer,
  student,
}

extension UserRoleExt on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.lecturer:
        return 'Giảng viên';
      case UserRole.student:
        return 'Sinh viên';
    }
  }
}

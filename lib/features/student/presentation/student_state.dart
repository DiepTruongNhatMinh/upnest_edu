import 'package:upnest_edu/core/mock/app_mock_db.dart';
import 'enrollment/course_models.dart';
import 'classes/student_class_models.dart';

class StudentState {
  static final StudentState I = StudentState._();
  StudentState._();

  // cửa sổ thay đổi đăng ký tính từ lúc Admin tạo lớp/lịch học
  static const Duration changeWindow = Duration(days: 3);

  // tạm thời: student hiện tại (sau này lấy từ AuthService)
  String get currentStudentUsername => 'sv01';

  // ====== CATALOG (đồng bộ từ AppMockDb) ======
  List<CourseOffering> get catalog {
    // Giả định AppMockDb.classSections là List<Map> có các field tối thiểu:
    // id, code, name, subjectCode, subjectName, lecturerUsername, capacity, createdAt, scheduleText (optional)
    final list = <CourseOffering>[];

    for (final c in AppMockDb.classSections) {
      final classId = (c['id'] as num).toInt();

      final code = (c['code'] ?? '').toString();
      final name = (c['name'] ?? '').toString();
      final subjectCode = (c['subjectCode'] ?? '').toString();
      final subjectName = (c['subjectName'] ?? '').toString();

      final lecturerUsername = (c['lecturerUsername'] ?? '').toString();
      final lecturerFullName = AppMockDb.fullNameOf(lecturerUsername);
      final lecturerName =
          lecturerFullName.isEmpty ? lecturerUsername : '$lecturerUsername - $lecturerFullName';

      final capacity = ((c['capacity'] as num?)?.toInt() ?? 0);

      // enrolled = đếm từ enrollments nguồn chung
      final enrolled = AppMockDb.enrollments
          .where((e) => (e['classId'] as num).toInt() == classId)
          .length;

      final scheduleText = (c['scheduleText'] ?? '').toString();
      final createdAt = (c['createdAt'] is DateTime)
          ? (c['createdAt'] as DateTime)
          : DateTime.now().subtract(const Duration(days: 1));

      list.add(
        CourseOffering(
          classId: classId,
          classCode: code,
          className: name,
          subjectCode: subjectCode,
          subjectName: subjectName,
          lecturerName: lecturerName,
          capacity: capacity,
          enrolled: enrolled,
          scheduleText: scheduleText.isEmpty ? 'Chưa có lịch' : scheduleText,
          createdAt: createdAt,
        ),
      );
    }

    // sort ổn định
    list.sort((a, b) => a.classCode.compareTo(b.classCode));
    return list;
  }

  // ====== MY ENROLLMENTS (đồng bộ từ AppMockDb) ======
  List<StudentEnrollment> get myEnrollments {
    final uname = currentStudentUsername.toLowerCase();

    final my = AppMockDb.enrollments
        .where((e) => (e['studentUsername'] as String).toLowerCase() == uname)
        .map((e) => (e['classId'] as num).toInt())
        .toList();

    final rows = <StudentEnrollment>[];

    for (final classId in my) {
      final c = AppMockDb.classById(classId);
      if (c == null) continue;

      final lecturerUsername = (c['lecturerUsername'] ?? '').toString();
      final lecturerFullName = AppMockDb.fullNameOf(lecturerUsername);
      final lecturerName =
          lecturerFullName.isEmpty ? lecturerUsername : '$lecturerUsername - $lecturerFullName';

      final g = AppMockDb.gradeOf(classId: classId, studentUsername: currentStudentUsername);
      final att = AppMockDb.attendancePercent(classId: classId, studentUsername: currentStudentUsername);

      final anns = AppMockDb.announcementsOfClass(classId);
      final lastAnnouncement = anns.isEmpty
          ? null
          : '${(anns.first['title'] ?? '').toString()}: ${(anns.first['content'] ?? '').toString()}';

      rows.add(
        StudentEnrollment(
          classId: classId,
          classCode: (c['code'] ?? '').toString(),
          className: (c['name'] ?? '').toString(),
          subjectCode: (c['subjectCode'] ?? '').toString(),
          subjectName: (c['subjectName'] ?? '').toString(),
          lecturerName: lecturerName,
          attendanceRate: att,
          midterm: g['midterm'],
          finalExam: g['final'],
          lastAnnouncement: lastAnnouncement,
          enrolledAt: _enrolledAtOf(classId) ?? DateTime.now(), // Giá trị này đảm bảo enrolledAt không null trong đối tượng tạo ra
        ),
      );
    }

    // ĐÃ SỬA: sort theo thời gian đăng ký gần nhất.
    // Vì constructor ở trên đảm bảo enrolledAt không null, 
    // ta có thể dùng toán tử khẳng định (!) để gọi compareTo.
    rows.sort((a, b) => b.enrolledAt!.compareTo(a.enrolledAt!)); 
    return rows;
  }

  DateTime? _enrolledAtOf(int classId) {
    final uname = currentStudentUsername.toLowerCase();
    final item = AppMockDb.enrollments.firstWhere(
      (e) =>
          (e['classId'] as num).toInt() == classId &&
          (e['studentUsername'] as String).toLowerCase() == uname,
      orElse: () => {},
    );
    if (item.isEmpty) return null;
    final t = item['enrolledAt'];
    return t is DateTime ? t : null;
  }

  bool isEnrolled(int classId) {
    final uname = currentStudentUsername.toLowerCase();
    return AppMockDb.enrollments.any(
      (e) =>
          (e['classId'] as num).toInt() == classId &&
          (e['studentUsername'] as String).toLowerCase() == uname,
    );
  }

  CourseOffering? getOffering(int classId) {
    for (final o in catalog) {
      if (o.classId == classId) return o;
    }
    return null;
  }

  StudentEnrollment? getEnrollment(int classId) {
    for (final e in myEnrollments) {
      if (e.classId == classId) return e;
    }
    return null;
  }

  // Quyền thay đổi đăng ký dựa trên createdAt của lớp
  bool canChangeEnrollment(int classId) {
    final offer = getOffering(classId);
    if (offer == null) return false;
    return DateTime.now().difference(offer.createdAt) < changeWindow;
    }

  Duration remainingChangeTime(int classId) {
    final offer = getOffering(classId);
    if (offer == null) return Duration.zero;
    final deadline = offer.createdAt.add(changeWindow);
    final diff = deadline.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  // ====== ENROLL / DROP ghi vào nguồn chung ======

  EnrollResult enroll(int classId) {
    final offer = getOffering(classId);
    if (offer == null) return EnrollResult.notFound;
    if (!canChangeEnrollment(classId)) return EnrollResult.locked;

    if (isEnrolled(classId)) return EnrollResult.already;

    final enrolledCount = AppMockDb.enrollments
        .where((e) => (e['classId'] as num).toInt() == classId)
        .length;

    if (enrolledCount >= offer.capacity) return EnrollResult.full;

    AppMockDb.enrollments.add({
      'classId': classId,
      'studentUsername': currentStudentUsername,
      'enrolledAt': DateTime.now(),
    });

    return EnrollResult.ok;
  }

  DropResult drop(int classId) {
    final offer = getOffering(classId);
    if (offer == null) return DropResult.notFound;
    if (!canChangeEnrollment(classId)) return DropResult.locked;
    if (!isEnrolled(classId)) return DropResult.notEnrolled;

    final uname = currentStudentUsername.toLowerCase();
    AppMockDb.enrollments.removeWhere(
      (e) =>
          (e['classId'] as num).toInt() == classId &&
          (e['studentUsername'] as String).toLowerCase() == uname,
    );

    return DropResult.ok;
  }
}

enum EnrollResult { ok, already, full, locked, notFound }
enum DropResult { ok, locked, notEnrolled, notFound }
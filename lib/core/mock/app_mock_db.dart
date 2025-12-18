// lib/core/mock/app_mock_db.dart
import 'dart:math';

class AppMockDb {
  AppMockDb._();

  // ===== USERS (đồng bộ cho 3 role) =====
  // username + fullName + role
  static const users = <Map<String, dynamic>>[
    {'id': 1, 'username': 'admin', 'fullName': 'Quản trị hệ thống', 'role': 'ADMIN'},
    {'id': 2, 'username': 'gv01', 'fullName': 'Nguyễn Văn A', 'role': 'LECTURER'},
    {'id': 3, 'username': 'gv02', 'fullName': 'Trần Thị H', 'role': 'LECTURER'},
    {'id': 101, 'username': 'sv01', 'fullName': 'Trần Thị B', 'role': 'STUDENT'},
    {'id': 102, 'username': 'sv02', 'fullName': 'Lê Văn C', 'role': 'STUDENT'},
    {'id': 103, 'username': 'sv03', 'fullName': 'Nguyễn Thị D', 'role': 'STUDENT'},
    {'id': 104, 'username': 'sv04', 'fullName': 'Phạm Văn E', 'role': 'STUDENT'},
    {'id': 105, 'username': 'sv05', 'fullName': 'Võ Minh K', 'role': 'STUDENT'},
    {'id': 106, 'username': 'sv06', 'fullName': 'Đặng Thảo N', 'role': 'STUDENT'},
  ];

  static Map<String, dynamic>? userByUsername(String username) {
    for (final u in users) {
      if ((u['username'] as String).toLowerCase() == username.toLowerCase()) return u;
    }
    return null;
  }

  static String fullNameOf(String username) =>
      (userByUsername(username)?['fullName'] ?? '').toString();

  static List<Map<String, dynamic>> students() =>
      users.where((u) => u['role'] == 'STUDENT').toList();

  static List<Map<String, dynamic>> lecturers() =>
      users.where((u) => u['role'] == 'LECTURER').toList();

  // ===== SUBJECTS / COURSES =====
  static const subjects = <Map<String, dynamic>>[
    {'id': 1, 'code': 'MATH', 'name': 'Toán', 'isActive': true},
    {'id': 2, 'code': 'PHY', 'name': 'Vật lý', 'isActive': true},
    {'id': 3, 'code': 'ENG', 'name': 'Tiếng Anh', 'isActive': true},
  ];

  // ===== CLASS SECTIONS =====
  // lecturerUsername: gv01/gv02
  static const classSections = <Map<String, dynamic>>[
    {
      'id': 1,
      'code': 'MATH-10A1',
      'name': 'Toán 10A1',
      'subjectCode': 'MATH',
      'subjectName': 'Toán',
      'lecturerUsername': 'gv01',
      'status': 'ACTIVE',
    },
    {
      'id': 2,
      'code': 'PHY-11B2',
      'name': 'Vật lý 11B2',
      'subjectCode': 'PHY',
      'subjectName': 'Vật lý',
      'lecturerUsername': 'gv02',
      'status': 'ACTIVE',
    },
    {
      'id': 3,
      'code': 'ENG-12C3',
      'name': 'Tiếng Anh 12C3',
      'subjectCode': 'ENG',
      'subjectName': 'Tiếng Anh',
      'lecturerUsername': 'gv01',
      'status': 'INACTIVE',
    },
  ];

  static List<Map<String, dynamic>> classesForLecturer(String lecturerUsername) {
    return classSections
        .where((c) => (c['lecturerUsername'] as String).toLowerCase() == lecturerUsername.toLowerCase())
        .toList();
  }

  static Map<String, dynamic>? classById(int id) {
    for (final c in classSections) {
      if (c['id'] == id) return c;
    }
    return null;
  }

  // ===== ENROLLMENTS (SV thuộc lớp nào) =====
  // studentUsername in classId
  static const enrollments = <Map<String, dynamic>>[
    {'classId': 1, 'studentUsername': 'sv01'},
    {'classId': 1, 'studentUsername': 'sv02'},
    {'classId': 1, 'studentUsername': 'sv03'},
    {'classId': 1, 'studentUsername': 'sv04'},
    {'classId': 1, 'studentUsername': 'sv05'},
    {'classId': 3, 'studentUsername': 'sv01'},
    {'classId': 3, 'studentUsername': 'sv06'},
    {'classId': 2, 'studentUsername': 'sv02'},
    {'classId': 2, 'studentUsername': 'sv03'},
  ];

  static List<String> studentsInClass(int classId) {
    return enrollments
        .where((e) => e['classId'] == classId)
        .map((e) => (e['studentUsername'] as String))
        .toList();
  }

  // ===== GRADES (đồng bộ giữa Lecturer/Student) =====
  // midterm/final có thể null
  static final Map<int, Map<String, Map<String, double?>>> gradesByClass = {
    1: {
      'sv01': {'midterm': 7.5, 'final': 8.0},
      'sv02': {'midterm': 6.0, 'final': 7.0},
      'sv03': {'midterm': null, 'final': null},
      'sv04': {'midterm': 9.0, 'final': null},
      'sv05': {'midterm': 8.0, 'final': 8.5},
    },
    2: {
      'sv02': {'midterm': 6.5, 'final': 7.0},
      'sv03': {'midterm': 8.5, 'final': 8.0},
    },
    3: {
      'sv01': {'midterm': 7.0, 'final': 7.5},
      'sv06': {'midterm': null, 'final': null},
    },
  };

  static Map<String, double?> gradeOf({
    required int classId,
    required String studentUsername,
  }) {
    final m = gradesByClass[classId]?[studentUsername];
    if (m == null) return {'midterm': null, 'final': null};
    return {'midterm': m['midterm'], 'final': m['final']};
  }

  static void setGrade({
    required int classId,
    required String studentUsername,
    double? midterm,
    double? finalExam,
  }) {
    gradesByClass.putIfAbsent(classId, () => {});
    gradesByClass[classId]!.putIfAbsent(studentUsername, () => {'midterm': null, 'final': null});
    gradesByClass[classId]![studentUsername]!['midterm'] = midterm;
    gradesByClass[classId]![studentUsername]!['final'] = finalExam;
  }

  // ===== ATTENDANCE (đồng bộ giữa Lecturer/Student) =====
  // sessionsByClass: danh sách buổi học (DateTime)
  static final Map<int, List<DateTime>> sessionsByClass = {
    1: [
      DateTime.now().subtract(const Duration(days: 7)),
      DateTime.now().subtract(const Duration(days: 2)),
      DateTime.now(),
    ],
    2: [
      DateTime.now().subtract(const Duration(days: 3)),
      DateTime.now(),
    ],
    3: [
      DateTime.now().subtract(const Duration(days: 5)),
    ],
  };

  // presentByClass[classId][sessionIso] = Set<studentUsername>
  static final Map<int, Map<String, Set<String>>> presentByClass = {
    1: {
      _isoDay(DateTime.now().subtract(const Duration(days: 7))): {'sv01', 'sv02', 'sv04', 'sv05'},
      _isoDay(DateTime.now().subtract(const Duration(days: 2))): {'sv01', 'sv02', 'sv03', 'sv05'},
      _isoDay(DateTime.now()): {'sv01', 'sv02', 'sv03', 'sv04'},
    },
    2: {
      _isoDay(DateTime.now().subtract(const Duration(days: 3))): {'sv02', 'sv03'},
      _isoDay(DateTime.now()): {'sv03'},
    },
    3: {
      _isoDay(DateTime.now().subtract(const Duration(days: 5))): {'sv01'},
    },
  };

  static List<DateTime> sessionsOfClass(int classId) =>
      sessionsByClass[classId] ?? const [];

  static Set<String> presentSet({
    required int classId,
    required DateTime session,
  }) {
    final key = _isoDay(session);
    return presentByClass[classId]?[key] ?? <String>{};
  }

  static void setPresentSet({
    required int classId,
    required DateTime session,
    required Set<String> presentStudents,
  }) {
    final key = _isoDay(session);
    presentByClass.putIfAbsent(classId, () => {});
    presentByClass[classId]![key] = {...presentStudents};
  }

  static double attendancePercent({
    required int classId,
    required String studentUsername,
  }) {
    final sessions = sessionsOfClass(classId);
    if (sessions.isEmpty) return 0;

    int present = 0;
    for (final s in sessions) {
      final set = presentSet(classId: classId, session: s);
      if (set.contains(studentUsername)) present++;
    }
    return present / sessions.length;
  }

  // ===== ANNOUNCEMENTS (đồng bộ Lecturer/Student) =====
  // announcementsByClass[classId] = [{title, content, createdAt}]
  static final Map<int, List<Map<String, dynamic>>> announcementsByClass = {
    1: [
      {
        'title': 'Ôn tập chương 1',
        'content': 'Các bạn xem lại bài 1–3 và làm thêm bài tập cuối chương.',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
    ],
    3: [
      {
        'title': 'Lịch kiểm tra',
        'content': 'Kiểm tra 15 phút vào buổi học tuần sau.',
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
      },
    ],
  };

  static List<Map<String, dynamic>> announcementsOfClass(int classId) =>
      announcementsByClass[classId] ?? <Map<String, dynamic>>[];

  static void addAnnouncement({
    required int classId,
    required String title,
    required String content,
    DateTime? createdAt,
  }) {
    announcementsByClass.putIfAbsent(classId, () => []);
    announcementsByClass[classId]!.insert(0, {
      'title': title,
      'content': content,
      'createdAt': createdAt ?? DateTime.now(),
    });
  }

  // ===== DASHBOARD COUNTS =====
  static int countUsers() => users.length;
  static int countSubjects() => subjects.length;
  static int countClasses() => classSections.length;

  static int countEnrollments() => enrollments.length;

  static int classesCountForLecturer(String lecturerUsername) =>
      classesForLecturer(lecturerUsername).length;

  static int studentsCountForLecturer(String lecturerUsername) {
    final classes = classesForLecturer(lecturerUsername);
    final set = <String>{};
    for (final c in classes) {
      final id = c['id'] as int;
      set.addAll(studentsInClass(id));
    }
    return set.length;
  }

  static int sessionsTodayForLecturer(String lecturerUsername) {
    // đơn giản: nếu lớp của gv có session hôm nay => count
    final today = _isoDay(DateTime.now());
    int count = 0;
    for (final c in classesForLecturer(lecturerUsername)) {
      final classId = c['id'] as int;
      final sessions = sessionsOfClass(classId);
      if (sessions.any((s) => _isoDay(s) == today)) count++;
    }
    return count;
  }

  static int pendingGradesForLecturer(String lecturerUsername) {
    // đếm số SV trong lớp gv mà chưa có cả midterm+final
    int missing = 0;
    for (final c in classesForLecturer(lecturerUsername)) {
      final classId = c['id'] as int;
      final st = studentsInClass(classId);
      for (final u in st) {
        final g = gradeOf(classId: classId, studentUsername: u);
        if (g['midterm'] == null && g['final'] == null) missing++;
      }
    }
    return missing;
  }

  static String _isoDay(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // tiện ích nhỏ cho mock nếu cần random
  static int r(int min, int max) => min + Random().nextInt(max - min + 1);
}

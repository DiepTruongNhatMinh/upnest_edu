// class StudentEnrollment (ví dụ: nằm trong course_models.dart)
class StudentEnrollment {
  final int classId;
  final String classCode;
  final String className;
  final String subjectCode;
  final String subjectName;
  final String lecturerName;

  double? midterm;
  double? finalExam;

  double attendanceRate;
  String? lastAnnouncement;

  // 1. ĐÃ SỬA: enrolledAt là nullable
  final DateTime? enrolledAt; 

  StudentEnrollment({
    required this.classId,
    required this.classCode,
    required this.className,
    required this.subjectCode,
    required this.subjectName,
    required this.lecturerName,
    required this.attendanceRate,
    required this.midterm,
    required this.finalExam,
    required this.lastAnnouncement,
    // 2. ĐÃ SỬA: bỏ 'required' để nó là tham số tùy chọn (optional)
    this.enrolledAt, 
  });
}
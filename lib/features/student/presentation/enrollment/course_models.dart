class CourseOffering {
  final int classId;
  final String classCode;
  final String className;
  final String subjectCode;
  final String subjectName;
  final String lecturerName;

  final int capacity;
  int enrolled;

  final String scheduleText;

  final DateTime createdAt;

  CourseOffering({
    required this.classId,
    required this.classCode,
    required this.className,
    required this.subjectCode,
    required this.subjectName,
    required this.lecturerName,
    required this.capacity,
    required this.enrolled,
    required this.scheduleText,
    required this.createdAt,
  });
}

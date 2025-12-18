class GradeEntry {
  final String studentUsername;
  final String studentName;

  double? midterm; // giữa kỳ
  double? finalExam; // cuối kỳ

  GradeEntry({
    required this.studentUsername,
    required this.studentName,
    this.midterm,
    this.finalExam,
  });

  double? get average {
    if (midterm == null && finalExam == null) return null;
    final m = midterm ?? 0;
    final f = finalExam ?? 0;
    // mock: 40% giữa kỳ, 60% cuối kỳ
    return (m * 0.4) + (f * 0.6);
  }
}

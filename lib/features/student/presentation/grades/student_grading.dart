class StudentGrading {
  static double? average(double? midterm, double? finalExam,
      {double midtermWeight = 0.4, double finalWeight = 0.6}) {
    if (midterm == null && finalExam == null) return null;
    final m = midterm ?? 0;
    final f = finalExam ?? 0;
    return (m * midtermWeight) + (f * finalWeight);
  }

  static bool isPass(double? avg) => avg != null && avg >= 5.0;

  static String letter(double? avg) {
    if (avg == null) return '-';
    if (avg >= 8.5) return 'A';
    if (avg >= 7.0) return 'B';
    if (avg >= 5.5) return 'C';
    if (avg >= 4.0) return 'D';
    return 'F';
  }

  static String rankVi(double? avg) {
    switch (letter(avg)) {
      case 'A':
        return 'Xuất sắc';
      case 'B':
        return 'Giỏi';
      case 'C':
        return 'Khá';
      case 'D':
        return 'Trung bình';
      case 'F':
        return 'Yếu';
      default:
        return '-';
    }
  }
}

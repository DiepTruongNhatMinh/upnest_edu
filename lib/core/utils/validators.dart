class Validators {
  static String? requiredField(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'Trường này không được để trống';
    }
    return null;
  }
}

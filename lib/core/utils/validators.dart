class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.contains('@')) return 'Invalid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) return 'Min 6 chars required';
    return null;
  }
}

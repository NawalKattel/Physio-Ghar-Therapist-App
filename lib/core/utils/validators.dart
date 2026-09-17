final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

final _nepaliMobilePattern = RegExp(r'^(\+977)?9[78]\d{8}$');

String? validateRequired(
  String? value, [
  String message = 'This field is required',
]) => (value ?? '').trim().isEmpty ? message : null;

String? validateName(String? value) {
  final name = (value ?? '').trim();
  return name.length < 2 || name.length > 60 ? 'Enter your full name' : null;
}

String? validatePhone(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
  return _nepaliMobilePattern.hasMatch(digits)
      ? null
      : 'Enter a valid 10-digit mobile number';
}

String? validateEmail(String? value) =>
    _emailPattern.hasMatch((value ?? '').trim())
    ? null
    : 'Enter a valid email address';

String? validateExperience(String? value) {
  final years = int.tryParse((value ?? '').trim());
  return years == null || years < 0 || years > 50
      ? 'Enter years of experience (0–50)'
      : null;
}

String? validatePassword(String? value) {
  final password = value ?? '';
  if (password.length < 8) return 'Use at least 8 characters';
  if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
      !RegExp(r'\d').hasMatch(password)) {
    return 'Include at least one letter and one number';
  }
  return null;
}

String? validateLength(
  String? value, {
  required int min,
  required int max,
  required String field,
}) {
  final length = (value ?? '').trim().length;
  if (length == 0) return 'Enter a $field';
  if (length < min) {
    return '${field[0].toUpperCase()}${field.substring(1)} must be at least $min characters';
  }
  if (length > max) {
    return '${field[0].toUpperCase()}${field.substring(1)} must be $max characters or fewer';
  }
  return null;
}

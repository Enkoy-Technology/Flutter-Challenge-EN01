/// Email validation regex pattern
/// Validates standard email format: name@domain.com
final _emailRegex = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
);

/// Validates email format
/// Returns error message if invalid, null if valid
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  
  // Trim whitespace
  final trimmedValue = value.trim();
  
  // Check if empty after trimming
  if (trimmedValue.isEmpty) {
    return 'Please enter your email';
  }
  
  // Validate email format using regex
  if (!_emailRegex.hasMatch(trimmedValue)) {
    return 'Please enter a valid email address';
  }
  
  return null;
}

/// Validates password
/// Returns error message if invalid, null if valid
String? validatePassword(String? value, {int minLength = 6}) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }
  
  if (value.length < minLength) {
    return 'Password must be at least $minLength characters';
  }
  
  return null;
}

/// Validates name
/// Returns error message if invalid, null if valid
String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your name';
  }
  
  final trimmedValue = value.trim();
  if (trimmedValue.isEmpty) {
    return 'Please enter your name';
  }
  
  if (trimmedValue.length < 2) {
    return 'Name must be at least 2 characters';
  }
  
  return null;
}

/// Validates password confirmation
/// Returns error message if invalid, null if valid
String? validatePasswordConfirmation(String? value, String? password) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  }
  
  if (value != password) {
    return 'Passwords do not match';
  }
  
  return null;
}


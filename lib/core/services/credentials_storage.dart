import 'package:shared_preferences/shared_preferences.dart';

class CredentialsStorage {
  static const String _keyEmail = 'saved_email';
  static const String _keyPassword = 'saved_password';
  static const String _keyDisplayName = 'saved_display_name';

  /// Save credentials after successful signup
  static Future<void> saveCredentials({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
    await prefs.setString(_keyDisplayName, displayName);
  }

  /// Get saved email
  static Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  /// Get saved password
  static Future<String?> getSavedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPassword);
  }

  /// Get saved display name
  static Future<String?> getSavedDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDisplayName);
  }

  /// Clear all saved credentials
  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.remove(_keyDisplayName);
  }

  /// Check if credentials are saved
  static Future<bool> hasCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyEmail) && prefs.containsKey(_keyPassword);
  }
}


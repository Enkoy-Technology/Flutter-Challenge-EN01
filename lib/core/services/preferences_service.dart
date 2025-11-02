import 'package:flutter/foundation.dart';

class PreferencesService extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  PreferencesService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    // Load from SharedPreferences in production
    _notificationsEnabled = true;
    _soundEnabled = true;
    _vibrationEnabled = true;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    // Save to SharedPreferences in production
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    notifyListeners();
    // Save to SharedPreferences in production
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    notifyListeners();
    // Save to SharedPreferences in production
  }
}


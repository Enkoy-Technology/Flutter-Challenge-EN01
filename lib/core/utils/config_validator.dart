import '../constants/app_constants.dart';

class ConfigValidator {
  static bool isSupabaseConfigured() {
    return AppConstants.supabaseUrl.isNotEmpty &&
        !AppConstants.supabaseUrl.contains('YOUR_') &&
        AppConstants.supabaseUrl.startsWith('https://') &&
        AppConstants.supabaseAnonKey.isNotEmpty &&
        !AppConstants.supabaseAnonKey.contains('YOUR_') &&
        AppConstants.supabaseAnonKey.length > 20;
  }

  static String getConfigurationError() {
    if (AppConstants.supabaseUrl.isEmpty ||
        AppConstants.supabaseUrl.contains('YOUR_')) {
      return 'Supabase URL is not configured. Please update lib/core/constants/app_constants.dart';
    }

    if (!AppConstants.supabaseUrl.startsWith('https://')) {
      return 'Supabase URL must start with https://';
    }

    if (AppConstants.supabaseAnonKey.isEmpty ||
        AppConstants.supabaseAnonKey.contains('YOUR_')) {
      return 'Supabase anon key is not configured. Please update lib/core/constants/app_constants.dart';
    }

    if (AppConstants.supabaseAnonKey.length < 20) {
      return 'Supabase anon key appears to be invalid';
    }

    return 'Configuration is valid';
  }
}


import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Sign up with email and password
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Sign up the user with email confirmation disabled for development
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null,
      );

      if (response.user == null) {
        throw Exception('Unable to create account. Please try again.');
      }

      final userId = response.user!.id;

      // Wait a bit for auth session to be established
      await Future.delayed(const Duration(milliseconds: 500));

      // Create user profile in the users table
      final userProfile = {
        'id': userId,
        'email': email,
        'display_name': displayName,
        'created_at': DateTime.now().toIso8601String(),
        'is_online': true,
        'last_seen': DateTime.now().toIso8601String(),
      };

      // Insert the user profile
      await _supabase.from('users').insert(userProfile);

      // Fetch the created profile to return
      final createdProfile = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(createdProfile);
    } on AuthException catch (e) {
      // Handle specific auth errors
      if (e.message.contains('User already registered')) {
        throw Exception(
          'This email is already registered. Please sign in instead.',
        );
      }
      throw Exception('Unable to create account. Please try again.');
    } on PostgrestException catch (e) {
      // Handle database errors
      if (e.message.contains('violates row-level security policy')) {
        throw Exception('Account setup incomplete. Please contact support.');
      }
      throw Exception('Unable to create account. Please try again.');
    } catch (e) {
      throw Exception('Unable to create account. Please try again.');
    }
  }

  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Invalid email or password. Please try again.');
      }

      final userId = response.user!.id;

      // Update user online status
      await _supabase
          .from('users')
          .update({
            'is_online': true,
            'last_seen': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // Fetch user profile
      final userProfile = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(userProfile);
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw Exception('Invalid email or password. Please try again.');
      }
      throw Exception('Unable to sign in. Please try again.');
    } on PostgrestException {
      throw Exception('Unable to sign in. Please try again.');
    } catch (e) {
      throw Exception('Unable to sign in. Please try again.');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      if (currentUserId != null) {
        // Update user online status
        await _supabase
            .from('users')
            .update({
              'is_online': false,
              'last_seen': DateTime.now().toIso8601String(),
            })
            .eq('id', currentUserId!);
      }

      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Unable to sign out. Please try again.');
    }
  }

  /// Get user profile
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile
  Future<UserModel> updateUserProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final response = await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Upload avatar
  Future<String> uploadAvatar(String userId, String filePath) async {
    try {
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);

      if (!await file.exists()) {
        throw Exception('Image file not found');
      }

      final bytes = await file.readAsBytes();

      // Upload with upsert to replace existing file
      await _supabase.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final url = _supabase.storage.from('avatars').getPublicUrl(fileName);
      return url;
    } catch (e) {
      if (e.toString().contains('not found')) {
        throw Exception(
          'Storage bucket not configured. Please check Supabase setup.',
        );
      }
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}

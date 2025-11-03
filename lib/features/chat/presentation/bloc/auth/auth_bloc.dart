import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        final user = await _authRepository.getUserProfile(currentUser.id);
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signUp(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      final errorMessage = _extractErrorMessage(e.toString());
      emit(AuthError(errorMessage));
      emit(AuthUnauthenticated());
    }
  }

  String _extractErrorMessage(String error) {
    // Remove "Exception: " prefix if present
    if (error.startsWith('Exception: ')) {
      error = error.substring('Exception: '.length);
    }

    // Extract meaningful error messages
    if (error.contains('Invalid argument(s)')) {
      return 'Please check your Supabase configuration';
    }
    if (error.contains('No host specified')) {
      return 'Supabase URL is not configured correctly';
    }
    if (error.contains('User already registered')) {
      return 'This email is already registered';
    }
    if (error.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    }
    if (error.contains('Email not confirmed')) {
      return 'Please confirm your email address';
    }

    return error;
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      final errorMessage = _extractErrorMessage(e.toString());
      emit(AuthError(errorMessage));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

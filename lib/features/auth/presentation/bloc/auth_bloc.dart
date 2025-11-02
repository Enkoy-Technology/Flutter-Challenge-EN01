import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>((event, emit) async {
      await emit.forEach(
        repository.userStream,
        onData: (user) => user == null
            ? AuthUnauthenticated()
            : AuthAuthenticated(user: user),
      );
    });

    on<LogoutEvent>((event, emit) async {
      await repository.logout();
      emit(AuthUnauthenticated());
    });
  }
}

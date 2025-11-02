import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../auth/domain/usecases/register_usecase.dart';
import '../../../../auth/domain/usecases/login_usecase.dart';
import '../../../../auth/data/models/user_model.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase; // inject LoginUseCase

  RegisterCubit({required this.registerUseCase, required this.loginUseCase})
    : super(RegisterInitial());

  Future<void> register(String email, String password, String name) async {
    emit(RegisterLoading());
    try {
      // 1. Register the user
      final user = await registerUseCase(email, password, name);

      // 2. Automatically login
      final loggedInUser = await loginUseCase(email, password);

      emit(RegisterSuccess(loggedInUser));
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}

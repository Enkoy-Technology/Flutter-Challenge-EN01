import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../auth/domain/usecases/register_usecase.dart';
import '../../../../auth/data/models/user_model.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase registerUseCase;

  RegisterCubit(this.registerUseCase) : super(RegisterInitial());

  Future<void> register(String email, String password, String name) async {
    emit(RegisterLoading());
    try {
      final user = await registerUseCase(email, password, name);
      emit(RegisterSuccess(user));
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}

import 'package:disctop_app/features/auth/auth_repository/login_usecaes.dart';
import 'package:disctop_app/features/auth/cubit/cubit_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;
  LoginCubit(this.loginUseCase) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      final result = await loginUseCase(email, password);
      emit(LoginSuccess(
        token: result['token']!,
        role: result['role']!,
      ));
      
    } catch (e) {
      emit(LoginFailure(message: e.toString()));
    }
  }
}

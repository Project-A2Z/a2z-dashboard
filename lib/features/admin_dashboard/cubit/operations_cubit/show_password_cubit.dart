import 'package:bloc/bloc.dart';
import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/show_password_state.dart';

class ShowPasswordCubit extends Cubit<ShowPasswordState> {
  final ApiService service;
  bool isVisible = false;
  String currentPassword = "**********";

  ShowPasswordCubit(this.service) : super(ShowPasswordInitial());

  Future<void> togglePassword({
    required String email,
    required String adminPassword,
  }) async {
    if (isVisible) {
      isVisible = false;
      emit(ShowPasswordHidden());
    } else {
      emit(ShowPasswordLoading());
      try {
        final pass = await service.showPassword(
          email: email,
          adminPassword: adminPassword,
        );
        currentPassword = pass;
        isVisible = true;
        emit(ShowPasswordSuccess(pass));
      } catch (e) {
        emit(ShowPasswordError(e.toString()));
      }
    }
  }
}

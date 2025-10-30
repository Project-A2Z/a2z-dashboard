import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/features/auth/cubit/opt_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpCubit extends Cubit<OtpState> {
  final ApiService authService;

  OtpCubit(this.authService) : super(OtpInitial());

  Future<void> verifyOtp(String email, String otp) async {
    emit(OtpLoading());
    try {
      final response = await authService.verifyOtp(email: email, otp: otp);
      if (response.statusCode == 200) {
        emit(OtpSuccess());
      } else {
        emit(OtpError('رمز التحقق غير صحيح'));
      }
    } catch (e) {
      emit(OtpError(e.toString()));
    }
  }

  Future<void> resendOtp(String email) async {
    try {
      await authService.resendOtp(email: email);
      emit(OtpResent());
    } catch (e) {
      emit(OtpError(e.toString()));
    }
  }
}

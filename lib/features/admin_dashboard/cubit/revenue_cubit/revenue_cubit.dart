import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/payments_cubit/payment_state.dart';
import 'package:disctop_app/core/api_service.dart';

class PaymentCubit_revenue extends Cubit<PaymentState> {
  final ApiService apiService;
  PaymentCubit_revenue(this.apiService) : super(PaymentInitial());

  Future<void> fetchPayments() async {
    emit(PaymentLoading());
    try {
      final payments = await apiService.getPayments_query("revenues");
      emit(PaymentLoaded(payments));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
}

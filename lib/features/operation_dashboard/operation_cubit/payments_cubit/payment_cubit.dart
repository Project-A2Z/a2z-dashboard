import 'package:disctop_app/features/admin_dashboard/cubit/revenue_cubit/create_payment_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/payments_cubit/payment_state.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/payments_cubit/payment_model.dart';
import 'package:disctop_app/core/api_service.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final ApiService apiService;
  PaymentCubit(this.apiService) : super(PaymentInitial());

  Future<void> fetchPayments() async {
    emit(PaymentLoading());
    try {
      final payments = await apiService.getPayments();
      emit(PaymentLoaded(payments));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  void createPayment(CreatePaymentModel payment) {}
}

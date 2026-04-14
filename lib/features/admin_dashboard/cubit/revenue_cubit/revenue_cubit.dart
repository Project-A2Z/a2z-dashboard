import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disctop_app/core/payment_mappers.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/payments_cubit/payment_state.dart';
import 'package:disctop_app/core/api_service.dart';

class PaymentCubit_revenue extends Cubit<PaymentState> {
  final ApiService apiService;
  PaymentCubit_revenue(this.apiService) : super(PaymentInitial());

  Future<void> fetchPayments() async {
    emit(PaymentLoading());
    try {
      final canonicalType = PaymentMappers.toPaymentTypeApi('revenues');
      var payments = await apiService.getPayments_query(canonicalType);

      // Fallback for older backend data/contracts that still use lowercase type values.
      if (payments.isEmpty) {
        payments = await apiService.getPayments_query('revenues');
      }

      // Last resort: fetch all and filter locally so list still shows newly added records.
      if (payments.isEmpty) {
        final all = await apiService.getPayments();
        payments = all
            .where((p) => p.type.toLowerCase() == 'revenues')
            .toList();
      }

      emit(PaymentLoaded(payments));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
}

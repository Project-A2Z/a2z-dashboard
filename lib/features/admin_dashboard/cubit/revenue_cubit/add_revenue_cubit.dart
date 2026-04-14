import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/revenue_cubit/add_revenue_state.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/revenue_cubit/create_payment_model.dart';
import 'package:disctop_app/core/api_service.dart';

class AddPaymentCubit extends Cubit<AddPaymentState> {
  final ApiService apiService;

  AddPaymentCubit(this.apiService) : super(AddPaymentInitial());

  Future<void> createPayment({
    required String paymentStatus,
    required String paymentWay,
    String? paymentWith,
    required double totalPrice,
    required String type,
  }) async {
    emit(AddPaymentLoading());

    try {
      final response = await apiService.createPayment(
        paymentStatus: paymentStatus,
        paymentWay: paymentWay,
        paymentWith: paymentWith!,
        totalPrice: totalPrice,
        type: type,
      );

      final payment = CreatePaymentModel.fromJson(response.data);
      emit(AddPaymentSuccess(payment));
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'حدث خطأ أثناء إنشاء الدفع';
      print('❌ Dio Error: $errorMessage');
      emit(AddPaymentError(errorMessage));
    } catch (e) {
      print('❌ Unexpected Error: $e');
      emit(AddPaymentError(e.toString()));
    }
  }
}

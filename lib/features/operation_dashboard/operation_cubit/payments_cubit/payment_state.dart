import 'package:disctop_app/features/operation_dashboard/operation_cubit/payments_cubit/payment_model.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<PaymentModel> payments;
  PaymentLoaded(this.payments);
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
}

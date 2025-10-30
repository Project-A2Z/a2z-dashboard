import 'package:disctop_app/features/admin_dashboard/cubit/revenue_cubit/create_payment_model.dart';

abstract class AddPaymentState {}

class AddPaymentInitial extends AddPaymentState {}

class AddPaymentLoading extends AddPaymentState {}

class AddPaymentSuccess extends AddPaymentState {
  final CreatePaymentModel payment;

  AddPaymentSuccess(this.payment);
}

class AddPaymentError extends AddPaymentState {
  final String message;

  AddPaymentError(this.message);
}

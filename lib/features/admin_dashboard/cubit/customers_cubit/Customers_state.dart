
import 'package:disctop_app/features/admin_dashboard/cubit/customers_cubit/customers_model.dart';

abstract class CustomersState {}

class CustomersInitial extends CustomersState {}

class CustomersLoading extends CustomersState {}

class CustomersLoaded extends CustomersState {
  final CustomersModel customersData;

  CustomersLoaded(this.customersData);
}

class CustomersError extends CustomersState {
  final String message;

  CustomersError(this.message);
}

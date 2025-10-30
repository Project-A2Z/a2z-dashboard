import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/operations_model.dart';

abstract class OperationsState {
  List<Object?> get props => [];
}

class OperationsInitial extends OperationsState {}

class OperationsLoading extends OperationsState {}

class OperationsLoaded extends OperationsState {
  final OperationsModel operations;

  OperationsLoaded(this.operations);

  @override
  List<Object?> get props => [operations];
}

class OperationsError extends OperationsState {
  final String message;

  OperationsError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:disctop_app/features/admin_dashboard/cubit/control_cubit/control_model.dart';

abstract class ProfitState {}

class ProfitInitial extends ProfitState {}

class ProfitLoading extends ProfitState {}

class ProfitLoaded extends ProfitState {
  final ProfitModel profitData;

  ProfitLoaded(this.profitData);
}

class ProfitError extends ProfitState {
  final String message;

  ProfitError(this.message);
}

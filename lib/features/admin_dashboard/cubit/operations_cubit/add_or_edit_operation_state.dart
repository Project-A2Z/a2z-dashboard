abstract class AddOrEditEmployeeState {}

class AddOrEditEmployeeInitial extends AddOrEditEmployeeState {}

class AddOrEditEmployeeLoading extends AddOrEditEmployeeState {}

class AddOrEditEmployeeSuccess extends AddOrEditEmployeeState {
  final String message;
  AddOrEditEmployeeSuccess(this.message);
}

class AddOrEditEmployeeError extends AddOrEditEmployeeState {
  final String message;
  AddOrEditEmployeeError(this.message);
}

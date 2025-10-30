abstract class OrderDetailsState {}

class OrderDetailsInitial extends OrderDetailsState {}

class OrderDetailsLoading extends OrderDetailsState {}

class OrderDetailsLoaded extends OrderDetailsState {
  final Map<String, dynamic> order; 
  OrderDetailsLoaded({required this.order});
}

class OrderDetailsError extends OrderDetailsState {
  final String message;
  OrderDetailsError({required this.message});
}

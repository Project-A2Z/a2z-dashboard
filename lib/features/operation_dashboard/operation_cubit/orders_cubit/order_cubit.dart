import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/orders_cubit/order_model.dart';
import 'order_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final ApiService _api;
  OrdersCubit(this._api) : super(OrdersInitial());

  Future<void> fetchOrders() async {
    emit(OrdersLoading());
    try {
      final List<OrderModel> models = await _api.getOrders();

      // نحول كل OrderModel لِ Map علشان ال UI ما يتغيرش
      final List<Map<String, dynamic>> maps = models.map((m) => m.toJson()).toList();

      emit(OrdersLoaded(maps));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}

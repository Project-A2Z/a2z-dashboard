import 'package:disctop_app/features/operation_dashboard/operation_cubit/orders_cubit/order_model.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_model.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disctop_app/core/api_service.dart';
import 'order_details_state.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  final ApiService _apiService;

  OrderDetailsCubit(this._apiService) : super(OrderDetailsInitial());

  Future<void> fetchOrderDetails(String orderId) async {
    try {
      emit(OrderDetailsLoading());
      final OrderModel orderModel = await _apiService.getOrderByOrderId(orderId);
      emit(OrderDetailsLoaded(order: orderModel.toJson())); 
    } catch (e) {
      emit(OrderDetailsError(message: e.toString()));
    }
  }
  Future<void> fetchOrderProducts(List<String> productIds) async {
  emit(ProductsLoading() as OrderDetailsState);
  try {
    final List<ProductModel> products = [];

    for (final id in productIds) {
      final product = await _apiService.getProductById(id);
 
      products.add(product);
        }

    emit(ProductsLoaded(products) as OrderDetailsState);
  } catch (e) {
    emit(ProductsError(e.toString()) as OrderDetailsState);
  }
}

}

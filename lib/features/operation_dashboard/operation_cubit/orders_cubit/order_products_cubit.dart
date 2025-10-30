
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_model.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disctop_app/core/api_service.dart';


class OrderProductsCubit extends Cubit<ProductsState> {
  final ApiService apiService;
  OrderProductsCubit(this.apiService) : super(ProductsInitial());

  Future<void> fetchOrderProducts(List<String> productIds) async {
    if (productIds.isEmpty) {
      emit(ProductsLoaded(<ProductModel>[]));
      return;
    }

    emit(ProductsLoading());
    final List<ProductModel> products = [];
    for (final id in productIds) {
      try {
        final p = await apiService.getProductById(id);
        products.add(p);
      } catch (e) {

         print('Failed to load product $id: $e');
      }
    }
    emit(ProductsLoaded(products));
  }
}

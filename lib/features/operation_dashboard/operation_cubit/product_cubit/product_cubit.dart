import 'package:bloc/bloc.dart';
import 'package:disctop_app/core/api_service.dart';
import 'product_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ApiService apiService;
  ProductsCubit(this.apiService) : super(ProductsInitial());

  
  Future<void> fetchProducts() async {
    emit(ProductsLoading());
    try {
      final products = await apiService.getProducts();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  
  Future<void> searchProducts({
    String? nameRegex,
    String? categoryRegex,
    String? descriptionRegex,
    double? minPrice,
  }) async {
    emit(ProductsLoading());
    try {
      final params = <String, dynamic>{};
      if (nameRegex != null && nameRegex.isNotEmpty) {
        params['name[regex]'] = nameRegex;
      }
      if (categoryRegex != null && categoryRegex.isNotEmpty) {
        params['category[regex]'] = categoryRegex;
      }
      if (descriptionRegex != null && descriptionRegex.isNotEmpty) {
        params['description[regex]'] = descriptionRegex;
      }
      if (minPrice != null) {
        params['price[gte]'] = minPrice;
      }

      final products = await apiService.getProducts(params: params);
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> deleteProduct(String id) async {
    emit(ProductsLoading());
    try {
      await apiService.deleteProduct(id);
      final products = await apiService.getProducts();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }
}

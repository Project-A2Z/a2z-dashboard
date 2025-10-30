import 'package:bloc/bloc.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/update_products_state.dart';
import 'package:disctop_app/core/api_service.dart';

class UpdateProductCubit extends Cubit<UpdateProductState> {
  final ApiService apiService;
  UpdateProductCubit(this.apiService) : super(UpdateProductInitial());

  /// ✅ Update product
  Future<void> updateProduct({
    required String id,
    required String name,
    required String price,
    required String description,
    required String category,
    required int stockQty,
    required List<String> imageList, // ← لازم تبعته روابط صور فقط
  }) async {
    emit(UpdateProductLoading());
    try {
      final updated = await apiService.updateProduct(
        id: id,
        name: name,
        price: price,
        description: description,
        category: category,
        stockQty: stockQty,
        imageList: imageList,
      );
      emit(UpdateProductSuccess(updated));
    } catch (e) {
      emit(UpdateProductFailure(e.toString()));
    }
  }
}

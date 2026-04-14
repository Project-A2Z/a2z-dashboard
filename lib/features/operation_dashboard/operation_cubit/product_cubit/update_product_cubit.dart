import 'dart:typed_data';

import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/update_products_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disctop_app/core/api_service.dart';

class UpdateProductCubit extends Cubit<UpdateProductState> {
  final ApiService apiService;

  UpdateProductCubit(this.apiService) : super(UpdateProductInitial());

  Future<void> updateProduct({
    required String id,
    required String name,
    required String price,
    required String purchasePrice,
    required String description,
    required String category,
    required int stockQty,
     required List<Uint8List> newImages, 
     required bool isKG ,
    required bool isTON ,
   required bool isLITER ,
   required bool isCUBIC_METER ,
   required List<String>? deleteImages,
   List<Map<String, String>> advProduct = const [],
  }) async {
    print({
  'name': name,
  'price': price,
  'purchase_price': purchasePrice,
  'description': description,
  'category': category,
  'stock_qty': stockQty,
});

    emit(UpdateProductLoading());

    try {
      final product = await apiService.updateProduct(
        id: id,
        name: name,
        price: price,
        purchasePrice: purchasePrice,
        description: description,
        category: category,
        stockQty: stockQty,
        isKG: isKG,
        isTON: isTON,
        isLITER: isLITER,
        isCUBIC_METER: isCUBIC_METER,
        deleteImages: deleteImages,
        newImages: newImages,
        advProduct: advProduct,
      );
      

      emit(UpdateProductSuccess(product));
    } catch (e) {
      emit(UpdateProductError(e.toString()));
    }
  }
}

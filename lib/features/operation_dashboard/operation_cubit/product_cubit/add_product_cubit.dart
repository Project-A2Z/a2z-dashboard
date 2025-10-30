import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'add_product_state.dart';
import 'package:disctop_app/core/api_service.dart';

class AddProductCubit extends Cubit<AddProductState> {
  final ApiService apiService;
  AddProductCubit(this.apiService) : super(AddProductInitial());

  Future<void> addProduct({
    required String name,
    required String price,
    required String description,
    required String category,
    required int stockQty,
    required bool inStock,
    required List<Uint8List> imageBytesList,
    required List<String> imageNames,
  }) async {
    emit(AddProductLoading());
    try {
      final product = await apiService.createProduct(
        name: name,
        price: price,
        description: description,
        category: category,
        stockQty: stockQty,
        inStock: inStock,
        imageBytesList: imageBytesList,
        imageNames: imageNames,
      );
      emit(AddProductSuccess(product));
    } on DioError catch (e) {
      emit(AddProductFailure(
          e.response?.data?.toString() ?? e.message ?? 'Unknown error'));
    } catch (e) {
      emit(AddProductFailure(e.toString()));
    }
  }
}

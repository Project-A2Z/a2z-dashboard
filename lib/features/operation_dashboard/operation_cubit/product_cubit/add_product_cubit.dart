import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'add_product_state.dart';
import 'package:disctop_app/core/api_service.dart';

class AddProductCubit extends Cubit<AddProductState> {
  final ApiService apiService;
  AddProductCubit(this.apiService) : super(AddProductInitial());

  Future<void> updateProductAdmin({
    required String productId,
    required String nameAr,
    required String nameEn,
    required String descriptionAr,
    required String descriptionEn,
    required String categoryAr,
    required String categoryEn,
    required List<Map<String, String>> advProduct,
    required List<Uint8List> imageBytesList,
    List<Map<String, dynamic>>? variantsDataList,
  }) async {
    emit(AddProductLoading());
    try {
      final product = await apiService.updateProduct(
        id: productId,
        name: nameAr,
        price: '0.0', // placeholder or update to required format
        purchasePrice: '0.0',
        description: descriptionAr,
        category: categoryAr,
        stockQty: 0,
        isKG: false,
        isTON: false,
        isLITER: false,
        isCUBIC_METER: false,
        newImages: imageBytesList,
        deleteImages: [],
        advProduct: advProduct,
      );

      if (variantsDataList != null) {
        for (final variantPayload in variantsDataList) {
          final variantsArray = variantPayload['variants'] as List<dynamic>? ?? [];
          for (final variant in variantsArray) {
            if (variant is Map) {
              variant['productId'] = product.id;
            }
          }
          await apiService.createProductVariants(variantPayload);
        }
      }

      emit(AddProductSuccess(product));
    } on DioError catch (e) {
      emit(AddProductFailure(
          e.response?.data?.toString() ?? e.message ?? 'Unknown error'));
    } catch (e) {
      emit(AddProductFailure(e.toString()));
    }
  }

  Future<void> addProduct({
    required String nameAr,
    required String nameEn,
    required String descriptionAr,
    required String descriptionEn,
    required String categoryAr,
    required String categoryEn,
    required List<Map<String, String>> advProduct,
    required List<Uint8List> imageBytesList,
    List<Map<String, dynamic>>? variantsDataList,
  }) async {
    emit(AddProductLoading());
    try {
      final product = await apiService.createProduct(
        nameAr: nameAr,
        nameEn: nameEn,
        descriptionAr: descriptionAr,
        descriptionEn: descriptionEn,
        categoryAr: categoryAr,
        categoryEn: categoryEn,
        advProduct: advProduct,
        imageBytesList: imageBytesList,
      );

      if (variantsDataList != null) {
        for (final variantPayload in variantsDataList) {
          final variantsArray = variantPayload['variants'] as List<dynamic>? ?? [];
          for (final variant in variantsArray) {
            if (variant is Map) {
              variant['productId'] = product.id;
            }
          }
          await apiService.createProductVariants(variantPayload);
        }
      }

      emit(AddProductSuccess(product));
    } on DioError catch (e) {
      emit(AddProductFailure(
          e.response?.data?.toString() ?? e.message ?? 'Unknown error'));
    } catch (e) {
      emit(AddProductFailure(e.toString()));
    }
  }
}

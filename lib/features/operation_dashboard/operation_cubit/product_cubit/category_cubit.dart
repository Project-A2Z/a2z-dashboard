import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final ApiService _service;

  CategoriesCubit(this._service) : super(CategoriesInitial());

  Future<void> loadCategories() async {
    emit(CategoriesLoading());
    try {
      final categories = await _service.getCategoris();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }
}

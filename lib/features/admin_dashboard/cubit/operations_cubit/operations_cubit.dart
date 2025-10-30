import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/operations_stat.dart';

class OperationsCubit extends Cubit<OperationsState> {
    final ApiService apiService;
  OperationsCubit(this.apiService) : super(OperationsInitial());


  Future<void> fetchOperations() async {
    emit(OperationsLoading());
    try {
      final response = await apiService.getOperations();
      emit(OperationsLoaded(response));
    } on DioException catch (e) {
      emit(OperationsError(
          e.response?.data['message'] ?? 'حدث خطأ أثناء تحميل العمليات'));
    } catch (e) {
      emit(OperationsError(e.toString()));
    }
  }
}

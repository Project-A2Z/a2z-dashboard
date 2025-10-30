import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/add_or_edit_operation_state.dart';

class AddOrEditEmployeeCubit extends Cubit<AddOrEditEmployeeState> {
  final ApiService apiservice;

  AddOrEditEmployeeCubit(this.apiservice)
      : super(AddOrEditEmployeeInitial());

  Future<void> saveEmployee({
    String? id,
    required String firstName,
    required String email,
    required String phoneNumber,
    required String department,
    required String dateOfSubmission,
    required String salary,
  }) async {
    emit(AddOrEditEmployeeLoading());
    try {
      final response = await apiservice.saveEmployee(
        id: id,
        firstName: firstName,
        email: email,
        phoneNumber: phoneNumber,
        department: department,
        dateOfSubmission: dateOfSubmission,
        salary: salary,
      );

      if (response.statusCode == 200) {

        emit(AddOrEditEmployeeSuccess(
            id == null ? 'تم إضافة الموظف بنجاح ✅' : 'تم تعديل الموظف بنجاح ✅'));
      } else {
        emit(AddOrEditEmployeeError(
            'فشل العملية (${response.statusCode})'));
      }
    } on DioException catch (e) {
      emit(AddOrEditEmployeeError(
          e.response?.data.toString() ?? e.message ?? 'خطأ غير معروف'));
    } catch (e) {
      emit(AddOrEditEmployeeError(e.toString()));
    }
  }
}

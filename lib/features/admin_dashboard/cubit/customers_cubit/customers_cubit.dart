import 'package:bloc/bloc.dart';
import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/customers_cubit/Customers_state.dart';



class CustomersCubit extends Cubit<CustomersState> {
  final ApiService apiService;

  CustomersCubit(this.apiService) : super(CustomersInitial());

  Future<void> fetchCustomers() async {
    try {
      emit(CustomersLoading());
      final result = await apiService.getAdminCustomerStatistics();
      emit(CustomersLoaded(result));
    } catch (e) {
      emit(CustomersError('فشل في تحميل الإحصائيات: $e'));
    }
  }
}

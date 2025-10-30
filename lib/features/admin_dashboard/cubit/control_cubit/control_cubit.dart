import 'package:bloc/bloc.dart';
import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/control_cubit/control_state.dart';


class ProfitCubit extends Cubit<ProfitState> {
  final ApiService apiService;

  ProfitCubit(this.apiService) : super(ProfitInitial());

  Future<void> fetchProfits() async {
    try {
      emit(ProfitLoading());
      final res = await apiService.getAdminProfitStatistics();
      emit(ProfitLoaded(res));
    } catch (e) {
      emit(ProfitError('فشل في تحميل الإحصائيات: $e'));
    }
  }
}

import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/notification_cubit/notification_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OperationNotificationCubit extends Cubit<OperationNotificationState> {
  final ApiService notificationService;

  OperationNotificationCubit(this.notificationService)
      : super(OperationNotificationInitial());

  Future<void> loadNotifications() async {
    emit(OperationNotificationLoading());
    try {
      final response = await notificationService.fetchOperationNotifications();
      emit(OperationNotificationLoaded(
        notifications: response.data,
        unreadCount: response.unreadCount,
      ));
    } catch (e) {
      emit(OperationNotificationError(e.toString()));
    }
  }
}

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
 


      final unreadNotifications = response.data
          .where((n) => n.isRead == false)
          .toList();

      emit(OperationNotificationLoaded(
        notifications: unreadNotifications,
        unreadCount: unreadNotifications.length,
      ));
      
    } catch (e) {
      emit(OperationNotificationError(e.toString()));
    }
  }
Future<void> markAllAsRead() async {
  try {

    await notificationService.markAllNotificationsAsRead();
    loadNotifications();
  } catch (e) {
    print("Error marking notifications as read: $e");
    emit(OperationNotificationError("فشل في تحديث حالة الإشعارات"));
  }
}

}
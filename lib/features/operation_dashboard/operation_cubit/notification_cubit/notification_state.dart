

import 'package:disctop_app/features/operation_dashboard/operation_cubit/notification_cubit/notification_model.dart';

abstract class OperationNotificationState {}

class OperationNotificationInitial extends OperationNotificationState {}

class OperationNotificationLoading extends OperationNotificationState {}

class OperationNotificationLoaded extends OperationNotificationState {
  final List<OperationNotification> notifications;
  final int unreadCount;

  OperationNotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });
}

class OperationNotificationError extends OperationNotificationState {
  final String message;
  OperationNotificationError(this.message);
}

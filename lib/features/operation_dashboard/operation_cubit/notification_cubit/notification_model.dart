class OperationNotification {
  final String id;
  final String title;
  final String userType;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  OperationNotification({
    required this.id,
    required this.title,
    required this.userType,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory OperationNotification.fromJson(Map<String, dynamic> json) {
    return OperationNotification(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      userType: json['userType'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class OperationNotificationResponse {
  final String status;
  final int unreadCount;
  final List<OperationNotification> data;

  OperationNotificationResponse({
    required this.status,
    required this.unreadCount,
    required this.data,
  });

  factory OperationNotificationResponse.fromJson(Map<String, dynamic> json) {
    return OperationNotificationResponse(
      status: json['status'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
      data: (json['data'] as List)
          .map((item) => OperationNotification.fromJson(item))
          .toList(),
    );
  }
}

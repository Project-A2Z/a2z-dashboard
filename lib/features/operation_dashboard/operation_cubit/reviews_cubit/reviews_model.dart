class ReviewModel {
  final String id;
  final UserInfo user;
  final String productId;
  final String description;
  final int rateNum;
  final DateTime createdAt;
  final String reply;

  ReviewModel({
    required this.id,
    required this.user,
    required this.productId,
    required this.description,
    required this.rateNum,
    required this.createdAt,
    required this.reply,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final userData = json['userId'];
    final user = (userData is Map)
        ? UserInfo.fromJson(Map<String, dynamic>.from(userData))
        : UserInfo(
            id: '',
            firstName: 'غير معروف',
            lastName: '',
            email: '',
          );

    return ReviewModel(
      id: json['_id']?.toString() ?? '',
      user: user,
      productId: json['productId']?.toString() ?? '',
      reply: json['reply']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      rateNum: (json['rateNum'] is int)
          ? json['rateNum']
          : int.tryParse(json['rateNum']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),

    );
  }
}

class UserInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  UserInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  String get fullName {
    final full = '$firstName $lastName'.trim();
    return full.isNotEmpty ? full : 'مستخدم';
  }
}

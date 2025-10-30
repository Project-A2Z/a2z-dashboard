class InquiryModel {
  final String id;
  final String name;
  final String description;
  final String phoneNumber;
  final String email;
  final String? reply;
  final DateTime createdAt;
  final DateTime updatedAt;

  InquiryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.phoneNumber,
    required this.email,
    this.reply,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InquiryModel.fromJson(Map<String, dynamic> json) {
    return InquiryModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      reply: json['reply'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "phoneNumber": phoneNumber,
      "email": email,
      "reply": reply,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
  
}

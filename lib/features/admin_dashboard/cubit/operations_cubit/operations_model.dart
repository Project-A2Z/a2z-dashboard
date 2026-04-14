class OperationsModel {
  final String status;
  final String message;
  final int length;
  final List<Operation> operations;

  OperationsModel({
    required this.status,
    required this.message,
    required this.length,
    required this.operations,
  });

  factory OperationsModel.fromJson(Map<String, dynamic> json) {
    return OperationsModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      length: json['length'] ?? 0,
      operations: (json['operations'] as List<dynamic>)
          .map((op) => Operation.fromJson(op))
          .toList(),
    );
  }
}

class Operation {
  final String id;
  final String? firstName;
  final String? email;
  final String? role;
  final String? image;
  final String? operationId;
  final String? phoneNumber;
  final String? department;
  final int? salary;
  final String? dateOfSubmission;
  final bool? isVerified;
  final List<dynamic>? address;
  final String? createdAt;
  final String? updatedAt;
  final String? password;
  final String? adminPassword;

  Operation({
    required this.id,
    this.firstName,
    this.email,
    this.role,
    this.image,
    this.operationId,
    this.phoneNumber,
    this.department,
    this.salary,
    this.dateOfSubmission,
    this.isVerified,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.password,
    this.adminPassword,
  });

  factory Operation.fromJson(Map<String, dynamic> json) {
    return Operation(
      id: json['id'] ?? '',
      firstName: json['firstName'],
      email: json['email'],
      role: json['role'],
      image: json['image'],
      operationId: json['operationId'],
      phoneNumber: json['phoneNumber'],
      department: json['department'],
      salary: json['salary'],
      dateOfSubmission: json['dateOfSubmission'],
      isVerified: json['isVerified'],
      address: json['address'] ?? [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      password: json['password'],
      adminPassword: json['adminPassword'],
    );
  }
}

class PaymentModel {
  final String id;
  final String orderId;
  final String paymentStatus;
  final String paymentWay;
  final String? paymentWith;
  final String type;
  final String? numOperation;
  final String? image;
  final double totalPrice;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic>? user;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.paymentStatus,
    required this.paymentWay,
    this.paymentWith,
    required this.type,
    this.numOperation,
    this.image,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      paymentWay: json['paymentWay'] ?? '',
      paymentWith: json['paymentWith'],
      type: json['type'] ?? '',
      numOperation: json['NumOperation'],
      image: json['image'],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      user: json['userId'] is Map<String, dynamic> ? json['userId'] : null,
    );
  }
}

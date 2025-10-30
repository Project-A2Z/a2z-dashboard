class CreatePaymentModel {
  final String id;

  final String paymentStatus;
  final String paymentWay;
  final String paymentWith;
  
  final double totalPrice;
  
  final String type;

  CreatePaymentModel({
    required this.id,
    required this.paymentStatus,
    required this.paymentWay,
    required this.paymentWith,
    required this.totalPrice,
    required this.type,
  });

  factory CreatePaymentModel.fromJson(Map<String, dynamic> json) {
    return CreatePaymentModel(
      id: json['_id'] ?? '',

      paymentStatus: json['paymentStatus'] ?? '',
      paymentWay: json['paymentWay'] ?? '',
      paymentWith: json['paymentWith'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      type: json['type'] ?? '',
    );
  }
}

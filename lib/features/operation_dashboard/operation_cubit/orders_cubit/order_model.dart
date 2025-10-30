class OrderModel {
  final String id;
  final String orderId;
  final String status;
  final double deliveryPrice;
  final String? deliveryDate;
  final Map<String, dynamic>? cartId;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? paymentDetails;
  final String createdAt;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.status,
    required this.deliveryPrice,
    required this.createdAt,
    this.deliveryDate,
    this.cartId,
    this.address,
    this.paymentDetails,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? '',
      deliveryPrice: (json['deliveryPrice'] ?? 0).toDouble(),
      deliveryDate: json['deliveryDate'],
      cartId: json['cartId'] != null
          ? Map<String, dynamic>.from(json['cartId'])
          : null,
      address: json['address'] != null
          ? Map<String, dynamic>.from(json['address'])
          : null,
      paymentDetails: json['paymentDetails'] != null
          ? Map<String, dynamic>.from(json['paymentDetails'])
          : null,
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "orderId": orderId,
      "status": status,
      "deliveryPrice": deliveryPrice,
      "deliveryDate": deliveryDate,
      "cartId": cartId,
      "address": address,
      "paymentDetails": paymentDetails,
      "createdAt": createdAt,
    };
  }
}

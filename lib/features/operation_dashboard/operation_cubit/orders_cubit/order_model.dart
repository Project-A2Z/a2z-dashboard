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
  final String updatedAt;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.status,
    required this.deliveryPrice,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryDate,
    this.cartId,
    this.address,
    this.paymentDetails,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? '',
      status: _normalizeStatus(json['status']),
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
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  static String _normalizeStatus(dynamic rawStatus) {
    if (rawStatus is Map) {
      final key = rawStatus['key'];
      if (key is String && key.isNotEmpty) return key;

      final en = rawStatus['en'];
      if (en is String && en.isNotEmpty) {
        return _normalizeStatusString(en);
      }

      final ar = rawStatus['ar'];
      if (ar is String && ar.isNotEmpty) {
        return _normalizeStatusString(ar);
      }
      return '';
    }

    if (rawStatus is String) {
      return _normalizeStatusString(rawStatus);
    }

    return '';
  }

  static String _normalizeStatusString(String value) {
    final cleaned = value.trim().toLowerCase().replaceAll(RegExp(r'[-_\s]'), '');

    switch (cleaned) {
      case 'underreview':
      case 'تحتمراجعة':
        return 'UnderReview';
      case 'reviewed':
      case 'مراجعة':
      case 'تمالمراجعة':
        return 'Reviewed';
      case 'prepared':
      case 'مستعد':
      case 'تمالتجهيز':
        return 'Prepared';
      case 'shipped':
      case 'تمالتسليم':
      case 'تمالشحن':
        return 'Shipped';
      case 'delivered':
      case 'تمالاستلام':
        return 'Delivered';
      case 'cancelled':
      case 'تمالالغاء':
      case 'الغاء':
      case 'إلغاء':
        return 'Cancelled';
      default:
        return value;
    }
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
      "updatedAt": updatedAt,
    };
  }
}

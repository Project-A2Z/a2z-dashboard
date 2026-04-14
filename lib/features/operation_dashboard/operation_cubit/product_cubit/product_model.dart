
class ProductModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<String> imageList;
  final double price;
  final double purchasePrice;
  final int stockQty;
  final String stockType;
  final double averageRate;
  final bool isKG;
  final bool isTON;
  final bool isLITER;
  final bool isCUBIC_METER;
  final String updatedAt;
  final List<ProductVariantModel> productVariants;
  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imageList,
    required this.price,
    required this.purchasePrice,
    required this.stockQty,
    required this.stockType,
    required this.averageRate,
    required this.isKG,
    required this.isTON,
    required this.isLITER,
    required this.isCUBIC_METER,
    required this.updatedAt,
    required this.productVariants,
  });

  static String _asText(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final ar = map['ar']?.toString().trim() ?? '';
      final en = map['en']?.toString().trim() ?? '';
      if (ar.isNotEmpty) return ar;
      if (en.isNotEmpty) return en;
      final first = map.values.where((e) => e != null).cast<dynamic>().toList();
      if (first.isNotEmpty) return first.first.toString();
      return '';
    }
    return value.toString();
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final variantsRaw = (json['productVariants'] as List?) ?? const [];
    return ProductModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: _asText(json['name']),
      category: _asText(json['category']),
      description: _asText(json['description']),
      imageList: List<String>.from(json['imageList'] ?? []),
      price: _asDouble(json['price']),
      purchasePrice: _asDouble(json['PurchasePrice'] ?? json['purchasePrice']),
      stockQty: _asInt(json['stockQty']),
      stockType: json['stockType'] ?? '',
      averageRate: _asDouble(json['averageRate']),
       isKG: json['IsKG'] ?? false,
      isTON: json['IsTON'] ?? false,
      isLITER: json['IsLITER'] ?? false,
      isCUBIC_METER: json['IsCUBIC_METER'] ?? false,
      updatedAt: json['updatedAt']?? "",
      productVariants: variantsRaw
          .whereType<Map>()
          .map((e) => ProductVariantModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'imageList': imageList,
      'price': price,
      'PurchasePrice': purchasePrice,
      'stockQty': stockQty,
      'stockType': stockType,
      'averageRate': averageRate,
       'IsKG': isKG,
      'IsTON': isTON,
      'IsLITER': isLITER,
      'IsCUBIC_METER': isCUBIC_METER,
      'updatedAt':updatedAt,
      'productVariants': productVariants.map((e) => e.toJson()).toList(),
     
    };
  }
}

class ProductVariantModel {
  final String id;
  final String unitId;
  final String unitName;
  final double price;
  final double totalQuantity;
  final double? purchasePrice;

  ProductVariantModel({
    required this.id,
    required this.unitId,
    required this.unitName,
    required this.price,
    required this.totalQuantity,
    required this.purchasePrice,
  });

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static double? _asNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    final unitObj = json['unitId'];
    final unitMap = unitObj is Map<String, dynamic>
        ? unitObj
        : (unitObj is Map ? Map<String, dynamic>.from(unitObj) : <String, dynamic>{});

    return ProductVariantModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      unitId: (unitMap['id'] ?? unitMap['_id'] ?? json['unitId'] ?? '').toString(),
      unitName: (unitMap['name'] ?? '').toString(),
      price: _asDouble(json['price']),
      totalQuantity: _asDouble(json['totalQuantity']),
      purchasePrice: _asNullableDouble(json['purchasePrice'] ?? json['PurchasePrice']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unitId': unitId,
      'unitName': unitName,
      'price': price,
      'totalQuantity': totalQuantity,
      'purchasePrice': purchasePrice,
    };
  }
}


// class ProductReview {
//   final String id;
//   final String userId;
//   final String productId;
//   final String description;
//   final int rateNum;
//   final String reply;
//   final String createdAt;
//   final String updatedAt;
  

//   ProductReview({
//     required this.id,
//     required this.userId,
//     required this.productId,
//     required this.description,
//     required this.rateNum,
//     required this.reply,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory ProductReview.fromJson(Map<String, dynamic> json) {
//     return ProductReview(
//       id: json['_id'] ?? '',
//       userId: json['userId'] ?? '',
//       productId: json['productId'] ?? '',
//       description: json['description'] ?? '',
//       rateNum: json['rateNum'] ?? 0,
//       reply: json['reply'] ?? '',
//       createdAt: json['createdAt'] ?? '',
//       updatedAt: json['updatedAt'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'userId': userId,
//       'productId': productId,
//       'description': description,
//       'rateNum': rateNum,
//       'reply': reply,
//       'createdAt': createdAt,
//       'updatedAt': updatedAt,
//     };
//   }
// }


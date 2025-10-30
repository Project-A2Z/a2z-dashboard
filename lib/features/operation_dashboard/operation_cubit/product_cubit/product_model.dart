class ProductModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<String> imageList;
  final double price;
  final int stockQty;
  final String stockType;
  final double averageRate;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imageList,
    required this.price,
    required this.stockQty,
    required this.stockType,
    required this.averageRate,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imageList: List<String>.from(json['imageList'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
      stockQty: json['stockQty'] ?? 0,
      stockType: json['stockType'] ?? '',
      averageRate: (json['averageRate'] ?? 0).toDouble(),
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
      'stockQty': stockQty,
      'stockType': stockType,
      'averageRate': averageRate,
    };
  }
}

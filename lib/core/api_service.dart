import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/control_cubit/control_model.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/customers_cubit/customers_model.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/operations_model.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/inquirey_cubit/inquirey_model.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/notification_cubit/notification_model.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/orders_cubit/order_model.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/payments_cubit/payment_model.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/reviews_cubit/reviews_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_model.dart';

class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://a2z-backend.fly.dev/app/v1',
            connectTimeout: const Duration(seconds: 50),
            receiveTimeout: const Duration(seconds: 50),
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<List<ProductModel>> getProducts({Map<String, dynamic>? params}) async {
    final mergedParams = {'lang': 'en', ...?params};
    final res = await _dio.get('/products', queryParameters: mergedParams);
    final data = res.data['data'] as List;
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }
 Future<OrderModel> getOrderByOrderId(String orderId) async {
    final res = await _dio.get('/orders/user/$orderId');
    if (res.statusCode == 200) {
      final data = res.data['data'];
      if (data is List && data.isNotEmpty) {
        final match = data.firstWhere(
          (e) {
            final m = Map<String, dynamic>.from(e);
            final od = (m['orderId'] ?? m['_id'] ?? '').toString();
            return od == orderId || m['_id'] == orderId;
          },
          orElse: () => data.first,
        );
        return OrderModel.fromJson(Map<String, dynamic>.from(match));
      } else if (data is Map) {
        return OrderModel.fromJson(Map<String, dynamic>.from(data));
      } else {
        if (res.data is Map<String, dynamic>) {
          return OrderModel.fromJson(Map<String, dynamic>.from(res.data));
        }
      }
    }
    throw Exception('Failed to fetch order details for $orderId');
  }
  Future<List<ProductModel>> getAllProducts() async {
  try {
    final res = await _dio.get('/products', queryParameters: {'lang': 'en'});

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = res.data;

      dynamic productsData;
      if (data is Map && data.containsKey('products')) {
        productsData = data['products'];
      } else if (data is Map && data.containsKey('data')) {
        final innerData = data['data'];
        productsData = (innerData is Map && innerData.containsKey('products'))
            ? innerData['products']
            : innerData;
      } else {
        productsData = data;
      }

      if (productsData is List) {
        return productsData
            .map((p) => ProductModel.fromJson(Map<String, dynamic>.from(p)))
            .toList();
      } else {
        throw Exception('Unexpected format for products list');
      }
    } else {
      throw Exception('Failed to fetch products: ${res.statusCode}');
    }
  } catch (e) {
    print('❌ Error fetching products: $e');
    rethrow;
  }
}


 Future<ProductModel> getProductById(String id) async {
    final res = await _dio.get('/products/$id', queryParameters: {'lang': 'en'});
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = res.data;
      dynamic p;
      if (data is Map && data.containsKey('product')) {
        p = data['product'];
      } else if (data is Map && data.containsKey('data')) {
        p = data['data'];
      } else {
        p = data;
      }

      if (p is Map) {
        return ProductModel.fromJson(Map<String, dynamic>.from(p));
      } else {
        throw Exception('Unexpected product format for id $id');
      }
    } else {
      throw Exception('Failed to fetch product $id: ${res.statusCode}');
    }
  }

  Future<ProductModel> createProduct({
    required String name,
    required String price,
    required String description,
    required String category,
    required int stockQty,
    required bool inStock,
    required List<Uint8List> imageBytesList,
    required List<String> imageNames,
  }) async {
    if (imageBytesList.isEmpty) {
      throw Exception('يجب رفع صورة واحدة على الأقل');
    }
    if (imageBytesList.length > 5) {
      throw Exception('يمكنك رفع حتى 5 صور فقط');
    }

    final formData = FormData();
    formData.fields.addAll([
      MapEntry('name', name),
      MapEntry('price', double.parse(price).toString()),
      MapEntry('description', description),
      MapEntry('category', category),
      MapEntry('stockQty', stockQty.toString()),
      MapEntry('stockType', 'unit'),
    ]);

    for (int i = 0; i < imageBytesList.length; i++) {
      formData.files.add(
        MapEntry(
          'image',
          MultipartFile.fromBytes(
            imageBytesList[i],
            filename: imageNames[i],
          ),
        ),
      );
    }

    final res = await _dio.post('/products',
        queryParameters: {'lang': 'en'}, data: formData);

    if (res.statusCode == 200 || res.statusCode == 201) {
      return ProductModel.fromJson(res.data['product']);
    } else {
      throw Exception(res.data.toString());
    }
  }
  Future<void> updateInquiryStatus(String id, String status) async {
  final response = await _dio.put(
    '/inquiries/$id/status',
    data: {'status': status},
  );
  if (response.statusCode != 200) {
    throw Exception('فشل تحديث الحالة');
  }
}
  Future<OperationNotificationResponse> fetchOperationNotifications() async {
    try {
      final response = await _dio.get('/notifications/operations');

      if (response.statusCode == 200) {
        return OperationNotificationResponse.fromJson(response.data);
      } else {
        throw Exception('فشل في تحميل الإشعارات');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء تحميل الإشعارات: $e');
    }
  }

//"adminmina@gmail.com"
//"1Asa*i9A"
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/users/login', data: {
      "email":"minadaniel893@gmail.com" ,
      "password":"V21mina#",
    });
    

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }
    final data = response.data as Map<String, dynamic>;
    final token = data['token'] ?? data['data']?['token'];
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
final userName = (data['data']?['user']?['firstName'] ?? data['data']?['user']?['name'] ?? '');
if (userName != null && userName.toString().isNotEmpty) {
  await prefs.setString('userName', userName.toString());
}
}
      
    
    return data;
  }
   Future<Response> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return await _dio.request(
      '/users/OTPVerification',
      data: {
        "email": email,
        "OTP": otp,
        "type": "passwordReset",
      },
      options: Options(method: 'PATCH'),
    );
  }

  Future<Response> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    return await _dio.request(
      '/users/ResetPassword',
      data: {
        "email": email,
        "Newpassword": newPassword,
      },
      options: Options(method: 'PATCH'),
    );
  }

  Future<Response> resendOtp({required String email}) async {
    return await _dio.request(
      '/users/forgetPassword',
      data: {"email": email},
      options: Options(method: 'POST'),
    );
  }
  Future<ProductModel> updateProduct({
    required String id,
    required String name,
    required String price,
    required String description,
    required String category,
    required int stockQty,
    required List<String> imageList,
  }) async {
    final dataMap = {
      'name': name,
      'price': double.parse(price),
      'description': description,
      'category': category,
      'stockQty': stockQty,
      'stockType': 'unit',
      'imageList': imageList,
    };

    final res = await _dio.put(
      '/products/$id',
      queryParameters: {'lang': 'en'},
      data: dataMap,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    return ProductModel.fromJson(res.data['product']);
  }

  Future<void> deleteProduct(String id) async {
    final res = await _dio.delete('/products/$id', queryParameters: {'lang': 'en'});
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete product: ${res.data}');
    }
  }

Future<List<OrderModel>> getOrders() async {
    final res = await _dio.get('/orders/');
    if (res.statusCode == 200) {
      final data = res.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } else {
      throw Exception('Failed to fetch orders: ${res.statusCode}');
    }
  }

Future<OrderModel> updateOrderStatus({
  required String orderId,
  required String newStatus,
}) async {
  final res = await _dio.patch(
    '/orders/$orderId/status',
    data: {'status': newStatus},
    queryParameters: {'lang': 'en'},
  );

  if (res.statusCode == 200) {
    final responseData = res.data;

    if (responseData is Map && responseData['data'] != null) {
      final orderData = Map<String, dynamic>.from(responseData['data']);
      return OrderModel.fromJson(orderData);
    } else {
      throw Exception("Unexpected response format: $responseData");
    }
  } else {
    throw Exception(
        'Failed to update order status: ${res.statusCode} - ${res.data}');
  }
}
  
  Future<List<InquiryModel>> getInquiries() async {
  final res = await _dio.get('/inquiries');
  if (res.statusCode == 200) {
    final data = res.data;

    final list = (data is Map && data['inquiries'] is List)
        ? data['inquiries']
        : [];

    return (list as List)
        .map((e) => InquiryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  } else {
    throw Exception('Failed to fetch inquiries: ${res.statusCode}');
  }
}

  Future<InquiryModel> getInquiryById(String inquiryId) async {
    final res = await _dio.get('/inquiries/$inquiryId');
    if (res.statusCode == 200) {
      final dynamic data = res.data;
      final Map<String, dynamic> orderMap = data is Map && data['data'] is Map
          ? Map<String, dynamic>.from(data['data'])
          : (data is Map ? Map<String, dynamic>.from(data) : {});
      return InquiryModel.fromJson(orderMap);
    } else {
      throw Exception('Failed to fetch inquiry: ${res.statusCode}');
    }
  }
 Future<List<InquiryModel>> fetchInquiries() async {
    final res = await _dio.get("/inquiries");
    if (res.statusCode == 200 && res.data['data'] != null) {
      return (res.data['data'] as List)
          .map((e) => InquiryModel.fromJson(e))
          .toList();
    }
    throw Exception("Failed to load inquiries");
  }

  Future<InquiryModel> replyToInquiry(String id, String reply) async {
    final res = await _dio.patch("/inquiries/$id", data: {"reply": reply});
    if (res.statusCode == 200 && res.data['data'] != null) {
      return InquiryModel.fromJson(res.data['data']);
    }
    throw Exception("Failed to update inquiry");
  }
   Future<List<PaymentModel>> getPayments() async {
    final res = await _dio.get('/payments');
    if (res.statusCode == 200) {
      final data = res.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception('Failed to fetch payments: ${res.statusCode}');
    }
  }
 
   Future<List<PaymentModel>> getPayments_query(String value) async {
    final res = await _dio.get('/payments?type=$value&limit=100');
    if (res.statusCode == 200) {
      final data = res.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception('Failed to fetch payments: ${res.statusCode}');
    }
  }
  
 Future<List<ReviewModel>> getReviewsByProduct(String productId) async {
    try {
      final res = await _dio.get('/reviews/$productId');

      final decoded = res.data is String ? jsonDecode(res.data) : res.data;

      final data = decoded['data'];
      if (data == null || data['reviews'] == null) return [];

      final reviews = List<Map<String, dynamic>>.from(data['reviews']);
      return reviews.map((e) => ReviewModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error fetching reviews: $e');
      rethrow;
    }
  }
Future<void> replyToReview(String reviewId, String replyText) async {
  try {
    final res = await _dio.patch('/reviews/$reviewId', data: {'reply': replyText});
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to send reply: ${res.statusCode}');
    }
  } catch (e) {
    print('Error replyToReview: $e');
    rethrow;
  }
}

Future<void> hideReview(String reviewId) async {
  try {
    final res = await _dio.patch('/reviews/$reviewId', data: {'hidden': true});
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to hide review: ${res.statusCode}');
    }
  } catch (e) {
    print('Error hideReview: $e');
    rethrow;
  }
}

Future<void> deleteReview(String reviewId) async {
  try {
    final res = await _dio.delete('/reviews/$reviewId');
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete review: ${res.statusCode}');
    }
  } catch (e) {
    print('Error deleteReview: $e');
    rethrow;
  }
}

Future<ProfitModel> getAdminProfitStatistics() async {
  try {
    final res = await _dio.get('/payments/admin/statistics/profits');
    if (res.statusCode == 200 && res.data != null) {
      return ProfitModel.fromJson(res.data);
    } else {
      throw Exception('Failed to load profits data: ${res.statusCode}');
    }
  } catch (e) {
    print('❌ Error fetching profit statistics: $e');
    rethrow;
  }
}
Future<CustomersModel> getAdminCustomerStatistics() async {
  try {
    final res = await _dio.get('/users/customersStatistics');
    if (res.statusCode == 200 && res.data != null) {
      return CustomersModel.fromJson(res.data);
    } else {
      throw Exception('Failed to load profits data: ${res.statusCode}');
    }
  } catch (e) {
    print('❌ Error fetching profit statistics: $e');
    rethrow;
  }
}

  Future<Response> createPayment({
    required String paymentStatus,
    required String paymentWay,
    required String paymentWith,
    required double totalPrice,
    required String type,
  }) async {
    final formData = FormData.fromMap({
      "paymentStatus": paymentStatus,
      "paymentWay": paymentWay,
      "paymentWith": paymentWith,
      "totalPrice": totalPrice,
      "type": type,
    });

    print('📤 Sending payment data: ${formData.fields}');
    try {
      final response = await _dio.post(
        'https://a2z-backend.fly.dev/app/v1/payments/',
        data: formData,
        options: Options(
          headers: {"Content-Type": "multipart/form-data"},
        ),
      );
      print('✅ Response: ${response.data}');
      return response;
    } on DioException catch (e) {
      print('❌ Error creating payment: ${e.response?.data}');
      rethrow; 
    }
  }
  Future<OperationsModel> getOperations() async {
  try {
    final res = await _dio.get('/users/allOperation');
    if (res.statusCode == 200 && res.data != null) {
      return OperationsModel.fromJson(res.data);
    } else {
      throw Exception('Failed to load operation: ${res.statusCode}');
    }
  } catch (e) {
    print('❌ Error fetching operation: $e');
    rethrow;
  }
}
  Future<String> showPassword({
    required String email,
    required String adminPassword,
  }) async {
    try {
      final res = await _dio.get(
        '/users/showPassword',
        queryParameters: {
          'lang': 'ar',
          'password': adminPassword,
          'email': email,
        },
      );
        print(res.data);
      if (res.statusCode == 200 && res.data != null) {
         return res.data['data']['password'] ?? 'كلمة المرور غير موجودة';
      } else {
        throw Exception('فشل في تحميل كلمة المرور');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'خطأ أثناء جلب كلمة المرور');
    }
  }
   Future<void> createOperation({
    required String firstName,
    required String email,
    required String phoneNumber,
    required String department,
    required String dateOfSubmission,
    required String salary,
  }) async {
    try {
      final response = await _dio.post(
        '/users/createOperation',
        data: {
          "firstName": firstName,
          "email": email,
          "phoneNumber": phoneNumber,
          "department": department,
          "dateOfSubmission": dateOfSubmission,
          "salary": int.parse(salary),
        },
        
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('حدث خطأ أثناء إنشاء الموظف');
      }
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());
    }
  }
  

Future<Response> saveEmployee({
  String? id,
  required String firstName,
  required String email,
  required String phoneNumber,
  required String department,
  required String dateOfSubmission,
  required String salary,
}) async {
  final endpoint = id == null
      ? '/users/createOperation'
      : '/users/updateOperation/$id';

  final data = id == null
      ? {
          "firstName": firstName,
          "email": email,
          "phoneNumber": phoneNumber,
          "department": department,
          "dateOfSubmission": dateOfSubmission,
          "salary": int.tryParse(salary) ?? 0,
        }
      : {
          "firstName": firstName,
          "phoneNumber": phoneNumber,
          "dateOfSubmission": dateOfSubmission,
          "salary": int.tryParse(salary) ?? 0,
        };

  final options = Options(
    method: id == null ? 'POST' : 'PATCH',
    headers: {"Content-Type": "application/json"},
  );

  return await _dio.request(
    endpoint,
    data: data,
    options: options,
  );
}

}










  


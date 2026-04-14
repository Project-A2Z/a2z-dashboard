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
          baseUrl: 'https://a2z-backend--dkreq.fly.dev/app/v1',
          connectTimeout: const Duration(seconds: 50),
          receiveTimeout: const Duration(seconds: 50),
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getAttributes() async {
    try {
      final res = await _dio.get(
        '/attributes',
        queryParameters: {'lang': 'ar'},
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data;
        if (data is Map && data.containsKey('data')) {
          final items = data['data'];
          if (items is List) {
            return items.map((e) => Map<String, dynamic>.from(e)).toList();
          }
        }
        return [];
      } else {
        throw Exception('Failed to fetch attributes: ${res.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching attributes: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllUnits({
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final res = await _dio.get(
        '/units',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data;
        if (data is Map && data.containsKey('data')) {
          final items = data['data'];
          if (items is List) {
            return items.map((e) => Map<String, dynamic>.from(e)).toList();
          }
        }
        return [];
      } else {
        throw Exception('Failed to fetch units: ${res.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching units: $e');
      rethrow;
    }
  }

  Future<List<ProductModel>> getProducts({Map<String, dynamic>? params}) async {
    final mergedParams = {'lang': 'en', ...?params};
    final res = await _dio.get(
      '/products?limit=1000',
      queryParameters: mergedParams,
    );
    final data = res.data['data'] as List;
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<OrderModel> getOrderByOrderId(String orderId) async {
    final res = await _dio.get('/orders/user/$orderId');
    if (res.statusCode == 200) {
      final data = res.data['data'];
      if (data is List && data.isNotEmpty) {
        final match = data.firstWhere((e) {
          final m = Map<String, dynamic>.from(e);
          final od = (m['orderId'] ?? m['_id'] ?? '').toString();
          return od == orderId || m['_id'] == orderId;
        }, orElse: () => data.first);
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
          productsData =
              (innerData is Map && innerData.containsKey('products'))
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
    final res = await _dio.get(
      '/products/$id',
      queryParameters: {'lang': 'en'},
    );
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

  Future<Map<String, dynamic>> getProductAdminDetailsById(String id) async {
    try {
      final v2Url = _dio.options.baseUrl.replaceAll('/v1', '/v2');
      final res = await _dio.get(
        '$v2Url/products/$id/admin',
        queryParameters: {'lang': 'ar'},
        options: Options(headers: {'Accept-Language': 'ar'}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (res.data != null && res.data['status'] == 'success') {
          return Map<String, dynamic>.from(res.data);
        }
        throw Exception('Failed to fetch admin details');
      } else {
        throw Exception('Admin details fetch failed: ${res.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print('Warning: Product not found: 404 for ID $id (Continuing with cached data)');
        return <String, dynamic>{};
      }
      rethrow;
    }
  }

  Future<ProductModel> createProduct({
    required String nameAr,
    required String nameEn,
    required String categoryAr,
    required String categoryEn,
    required String descriptionAr,
    required String descriptionEn,
    required List<Map<String, String>> advProduct,
    required List imageBytesList,
  }) async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry('name[ar]', nameAr),
      MapEntry('name[en]', nameEn),
      MapEntry('category[ar]', categoryAr),
      MapEntry('category[en]', categoryEn),
      MapEntry('description[ar]', descriptionAr),
      MapEntry('description[en]', descriptionEn),
    ]);

    for (int i = 0; i < advProduct.length; i++) {
      formData.fields.add(MapEntry('advProduct[$i][ar]', advProduct[i]['ar'] ?? ''));
      formData.fields.add(MapEntry('advProduct[$i][en]', advProduct[i]['en'] ?? ''));
    }

    if (imageBytesList.isNotEmpty) {
      for (int i = 0; i < imageBytesList.length; i++) {
        formData.files.add(
          MapEntry(
            'image',
            MultipartFile.fromBytes(
              imageBytesList[i],
              filename: 'image_$i.jpg',
            ),
          ),
        );
      }
    }

    final res = await _dio.post(
      '/products',
      queryParameters: {'lang': 'en'},
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final raw = res.data;
      dynamic product;

      if (raw is Map && raw['product'] is Map<String, dynamic>) {
        product = raw['product'];
      } else if (raw is Map && raw['data'] is Map<String, dynamic>) {
        product = raw['data'];
      } else if (raw is Map<String, dynamic>) {
        product = raw;
      }

      if (product is Map<String, dynamic>) {
        return ProductModel.fromJson(product);
      }

      throw Exception('Unexpected create product response format');
    } else {
      throw Exception(res.data.toString());
    }
  }

  Future<OperationNotificationResponse> fetchOperationNotifications({
    bool unreadOnly = false,
  }) async {
    try {
      final response = await _dio.get('/notifications/operations?limit=100');

      if (response.statusCode == 200) {
        return OperationNotificationResponse.fromJson(response.data);
      } else {
        throw Exception('فشل في تحميل الإشعارات');
      }
    } catch (e) {
      throw Exception('حدث خطأ أثناء تحميل الإشعارات: $e');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    await _dio.patch(
      '/notifications/mark-all-read',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  //"adminmina@gmail.com"
  //"1Asa*i9A"
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      '/users/login',
      data: {"email": "operation1@gmail.com", "password": "b@3mq08eZA"},
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }
    final data = response.data as Map<String, dynamic>;
    final token = data['token'] ?? data['data']?['token'];
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      final userName =
          (data['data']?['user']?['firstName'] ??
              data['data']?['user']?['name'] ??
              '');
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
      data: {"email": email, "OTP": otp, "type": "passwordReset"},
      options: Options(method: 'PATCH'),
    );
  }

  Future<Response> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    return await _dio.request(
      '/users/ResetPassword',
      data: {"email": email, "Newpassword": newPassword},
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
    required String purchasePrice,
    required String description,
    required String category,
    required int stockQty,
    required bool isKG,
    required bool isTON,
    required bool isLITER,
    required bool isCUBIC_METER,
    required List<Uint8List>? newImages, // صور جديدة
    required List<String>? deleteImages,
    required List<Map<String, String>> advProduct,
  }) async {
    try {
      // ✅ نجهز formData زي الـ create
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('name', name),
        MapEntry('price', double.parse(price).toString()),
        MapEntry('PurchasePrice', double.parse(purchasePrice).toString()),
        MapEntry('description', description),
        MapEntry('category', category),
        MapEntry('stockQty', stockQty.toString()),
        MapEntry('IsKG', isKG.toString()),
        MapEntry('IsTON', isTON.toString()),
        MapEntry('IsLITER', isLITER.toString()),
        MapEntry('IsCUBIC_METER', isCUBIC_METER.toString()),
      ]);

      if (newImages != null && newImages.isNotEmpty) {
        for (int i = 0; i < newImages.length; i++) {
          formData.files.add(
            MapEntry(
              'image',
              MultipartFile.fromBytes(newImages[i], filename: 'image_$i.jpg'),
            ),
          );
        }
      }

      // ✅ لو فيه صور عايز تحذفها
      if (deleteImages != null && deleteImages.isNotEmpty) {
        formData.fields.add(MapEntry('Deleteimage', deleteImages.join(',')));
      }
      final res = await _dio.put(
        '/products/$id',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('✅ RESPONSE DATA: ${res.data}');
      print('✅ STATUS CODE: ${res.statusCode}');

      if (res.statusCode == 200 && res.data['status'] == 'success') {
        return ProductModel.fromJson(res.data['product']);
      } else {
        throw Exception('فشل تعديل المنتج: ${res.data}');
      }
    } catch (e) {
      throw Exception('❌ خطأ أثناء تعديل المنتج: $e');
    }
  }

  Future<void> sendReply({
    required String reviewId,
    required String message,
  }) async {
    try {
      await _dio.put('/reviews/reply/$reviewId', data: {'reply': message});
    } catch (e) {
      throw Exception('Failed to send reply: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    final res = await _dio.delete(
      '/products/$id',
      queryParameters: {'lang': 'en'},
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete product: ${res.data}');
    }
  }

  Future<List<OrderModel>> getOrders() async {
    final res = await _dio.get('/orders/');
    if (res.statusCode == 200) {
      final data = res.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception('Failed to fetch orders: ${res.statusCode}');
    }
  }

  Future<List<dynamic>> getCategoris() async {
    final res = await _dio.get('/products/categories?lang=en');
    if (res.statusCode == 200) {
      final data = res.data['data'] as List<dynamic>? ?? [];

      return data;
    } else {
      throw Exception('Failed to fetch orders: ${res.statusCode}');
    }
  }

  Future<Map<String, List<Map<String, String>>>>
  getProductUnitConstants() async {
    final res = await _dio.get('/site/constants');

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch constants: ${res.statusCode}');
    }

    final body = res.data;
    if (body is! Map) {
      throw Exception('Unexpected constants response format');
    }

    final data = body['data'];
    if (data is! Map) {
      throw Exception('Missing constants data');
    }

    final enumMaterializedLanguage = data['enumMaterializedLanguage'];
    if (enumMaterializedLanguage is! Map) {
      throw Exception('Missing enumMaterializedLanguage in constants');
    }

    List<Map<String, String>> parseLocalizedValues(String key) {
      final section = enumMaterializedLanguage[key];
      if (section is! Map) return <Map<String, String>>[];

      final values = <Map<String, String>>[];
      for (final value in section.values) {
        if (value is Map && value['ar'] != null && value['en'] != null) {
          final ar = value['ar'].toString().trim();
          final en = value['en'].toString().trim();
          if (ar.isNotEmpty && en.isNotEmpty) {
            values.add({'ar': ar, 'en': en});
          }
        }
      }
      return values;
    }

    return {
      'unitName': parseLocalizedValues('UnitName'),
      'baseUnit': parseLocalizedValues('BaseUnit'),
    };
  }

  Future<void> createProductVariants(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(
        '/product-variants',
        data: data,
        options: Options(
          headers: {'Accept': 'application/json'},
          contentType: Headers.jsonContentType,
        ),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception(res.data.toString());
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data != null ? e.response!.data.toString() : e.message;
      throw Exception('Create Variants Error: $errorMessage');
    }
  }

  Future<void> createUnit({
    required String name,
    required num conversionRate,
    required String base,
  }) async {
    try {
      final res = await _dio.post(
        '/units',
        data: {'name': name, 'conversionRate': conversionRate, 'base': base},
        options: Options(
          headers: {'Accept': 'application/json'},
          contentType: Headers.jsonContentType,
        ),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception(res.data.toString());
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data != null ? e.response!.data.toString() : e.message;
      throw Exception('Create Unit Error: $errorMessage');
    }
  }

  Future<List<Map<String, dynamic>>> getUnits() async {
    final res = await _dio.get('/units');

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch units: ${res.statusCode}');
    }

    final body = res.data;
    if (body is! Map || body['data'] is! List) {
      throw Exception('Unexpected units response format');
    }

    final list = body['data'] as List;
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String newStatus,
    required double deliveryPrice,
    required DateTime deliveryDate,
  }) async {
    final res = await _dio.patch(
      '/orders/$orderId/status',
      data: {
        'status': newStatus,
        'deliveryPrice': deliveryPrice,
        'deliveryDate': deliveryDate.toIso8601String(),
      },
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
        'Failed to update order status: ${res.statusCode} - ${res.data}',
      );
    }
  }

  Future<List<InquiryModel>> getInquiries() async {
    final res = await _dio.get('/inquiries');
    if (res.statusCode == 200) {
      final data = res.data;

      final list =
          (data is Map && data['inquiries'] is List) ? data['inquiries'] : [];

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
      final Map<String, dynamic> orderMap =
          data is Map && data['data'] is Map
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
      final res = await _dio.put(
        '/reviews/reply/$reviewId',
        data: {'reply': replyText},
      );
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Failed to send reply: ${res.statusCode}');
      }
    } catch (e) {
      print('Error replyToReview: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      final res = await _dio.delete('/reviews/operation/$reviewId');
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
        'https://a2z-backend--dkreq.fly.dev/app/v1/payments/',
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
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
      throw Exception(
        e.response?.data['message'] ?? 'خطأ أثناء جلب كلمة المرور',
      );
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
    required String password,
    required String adminPassword,
  }) async {
    final endpoint =
        id == null ? '/users/createOperation' : '/users/updateOperation/$id';

    final data =
        id == null
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

    if (password.trim().isNotEmpty) {
      data["password"] = password;
    }

    if (adminPassword.trim().isNotEmpty) {
      data["adminPassword"] = adminPassword;
    }

    final options = Options(
      method: id == null ? 'POST' : 'PATCH',
      headers: {"Content-Type": "application/json"},
    );

    return await _dio.request(endpoint, data: data, options: options);
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
}


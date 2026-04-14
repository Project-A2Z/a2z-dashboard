import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/core/widgets/header_operation.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_operation.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/orders_cubit/order_details_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/orders_cubit/order_details_state.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/orders_cubit/order_products_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_model.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final TextEditingController deliveryPriceController = TextEditingController();
  DateTime? selectedDeliveryDate;

  String? selectedStatus;

  final Map<String, String> statusArabicToEnglish = {
    "قيد المراجعة": "UnderReview",
    "تم المراجعة": "Reviewed",
    "تم التجهيز": "Prepared",
    "تم الشحن": "Shipped",
    "تم التسليم": "Delivered",
    "الغاء": "Cancelled",
  };

  final List<String> statusesArabic = [
    "قيد المراجعة",
    "تم المراجعة",
    "تم التجهيز",
    "تم الشحن",
    "تم التسليم",
    "الغاء",
  ];

  Future<bool?> showConfirmChangeStatus({
    required BuildContext context,
    required String oldStatus,
    required String newStatusAr,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Text(
            "تأكيد تغيير الحالة",
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            "هل أنت متأكد من تغيير حالة الطلب من:\n\n"
            "• $oldStatus\n"
            "إلى:\n"
            "• $newStatusAr",
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: AppColors.black87,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "إلغاء",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "نعم",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  String formatArabicDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      final formatter = DateFormat("d MMMM", "ar");
      return "يوم ${formatter.format(date)}";
    } catch (e) {
      print("❌ Error parsing date: $dateString | $e");
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    const selectedKey = "الطلبات";

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  OrderDetailsCubit(context.read<ApiService>())
                    ..fetchOrderDetails(widget.orderId),
        ),
        BlocProvider(
          create: (context) => OrderProductsCubit(context.read<ApiService>()),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Sidebar_Operation(selectedKey: selectedKey),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
                    builder: (context, orderState) {
                      if (orderState is OrderDetailsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (orderState is OrderDetailsError) {
                        return Center(
                          child: Text("خطأ: ${orderState.message}"),
                        );
                      }
                      if (orderState is OrderDetailsLoaded) {
                        final order = orderState.order;
                        final statusKey = (order['status'] ?? '').toString();
                        
                        final cart = order['cartId'] ?? {};
                        final items = (cart['items'] as List?) ?? [];
                        final address = order['address'] ?? {};
                        final createdAt = order['createdAt'] ?? "";
                        final updatedAt = order['updatedAt'] ?? "";
                        final hasDeliveryInfo =
                            order['deliveryPrice'] != null &&
                            order['deliveryDate'] != null &&
                            order['deliveryDate'].toString().isNotEmpty;
                        DateTime createdDate = DateTime.parse(createdAt);
                        String formattedDate = DateFormat(
                          'yyyy-MM-dd',
                        ).format(createdDate);
                        final totalPrice = cart['totalPrice'];
                        if (deliveryPriceController.text.isEmpty &&
                            order['deliveryPrice'] != null) {
                          deliveryPriceController.text =
                              order['deliveryPrice'].toString();
                        }

                        final productIds =
                            items
                                .map((item) {
                                  final product = item['productId'];
                                  if (product is Map &&
                                      product['_id'] != null) {
                                    return product['_id'] as String;
                                  } else if (product is String) {
                                    return product;
                                  } else {
                                    return '';
                                  }
                                })
                                .where((id) => id.isNotEmpty)
                                .toList();

                        context.read<OrderProductsCubit>().fetchOrderProducts(
                          productIds,
                        );

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Column(
                                  children: [
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: DashboardHeader(title: "الطلبات",showBack: true,showRefresh: false,),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "تفاصيل الطلب ${widget.orderId}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: statusKey == "Cancelled"
      ? [
          _buildStep("قيد المراجعة", false, false, true),
          _buildLine(false, true),
          _buildStep("تم المراجعة", false, false, true),
          _buildLine(false, true),
          _buildStep("تم التجهيز", false, false, true),
          _buildLine(false, true),
          _buildStep("تم الشحن", false, false, true),
          _buildLine(false, true),
          _buildStep("تم الإلغاء", false, false, true), // آخر ستيب
        ]
      : [
          _buildStep(
            "قيد المراجعة",
            statusKey == "UnderReview",
            statusKey != "UnderReview",
            false,
          ),
          _buildLine(statusKey != "UnderReview", false),

          _buildStep(
            "تم المراجعة",
            statusKey == "Reviewed",
            statusKey == "Prepared" ||
                statusKey == "Shipped" ||
                statusKey == "Delivered",
            false,
          ),
          _buildLine(
            statusKey == "Prepared" ||
                statusKey == "Shipped" ||
                statusKey == "Delivered",
            false,
          ),

          _buildStep(
            "تم التجهيز",
            statusKey == "Prepared",
            statusKey == "Shipped" ||
                statusKey == "Delivered",
            false,
          ),
          _buildLine(
            statusKey == "Shipped" || statusKey == "Delivered",
            false,
          ),

          _buildStep(
            "تم الشحن",
            statusKey == "Shipped",
            statusKey == "Delivered",
            false,
          ),
          _buildLine(statusKey == "Delivered", false),

          _buildStep(
            "تم التسليم",
            statusKey == "Delivered",
            false,
            false,
          ),
        ],
                                    ),

                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              Row(
                                children: [
                                  Container(
                                  child:Text("اخر تحديث في :"),
                                 ),
                                 Container(
                                  child: Text(" ${DateTime.parse(updatedAt).year}/${DateTime.parse(updatedAt).month}/${DateTime.parse(updatedAt).day}"),
                                 ),
                                  Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.black8,
                                      ),
                                    ),
                                    child: DropdownButton<String>(
                                      alignment: Alignment.centerRight,
                                      underline: const SizedBox(),

                                      value:
                                          selectedStatus != null
                                              ? statusArabicToEnglish.keys
                                                  .firstWhere(
                                                    (ar) =>
                                                        statusArabicToEnglish[ar] ==
                                                        selectedStatus,
                                                    orElse:
                                                        () => statusesArabic[0],
                                                  )
                                              : statusArabicToEnglish.keys
                                                  .firstWhere(
                                                    (ar) =>
                                                        statusArabicToEnglish[ar] ==
                                                    statusKey,
                                                    orElse:
                                                        () => statusesArabic[0],
                                                  ),

                                      items:
                                          statusesArabic.map((statusAr) {
                                            return DropdownMenuItem(
                                              value: statusAr,
                                              child: Text(
                                                statusAr,
                                                textDirection:
                                                    TextDirection.rtl,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          }).toList(),

                                      onChanged: (value) {
                                        setState(() {
                                          selectedStatus =
                                              statusArabicToEnglish[value]!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "رقم الطلب: ${order['orderId']}",
                                      style: const TextStyle(
                                        color: AppColors.black60,
                                      ),
                                    ),
                                    Text(
                                      "السعر: ${totalPrice} ج",
                                      style: const TextStyle(
                                        color: AppColors.black60,
                                      ),
                                    ),
                                    Text(
                                      "تم تقديم الطلب في: $formattedDate",
                                      style: const TextStyle(
                                        color: AppColors.black60,
                                      ),
                                    ),
                                    Text(
                                      "العنوان: ${address['address']}, ${address['city']}",
                                      style: const TextStyle(
                                        color: AppColors.black60,
                                      ),
                                    ),
                                    Text(
                                      "رقم الهاتف: ${address['phoneNumber']}",
                                      style: const TextStyle(
                                        color: AppColors.black60,
                                      ),
                                    ),
                                    Text(
                                      "ب اسم: ${address['firstName']} ${address['lastName']}",
                                      style: const TextStyle(
                                        color: AppColors.black60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "المنتجات الخاصة بالطلب",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),

                              BlocBuilder<OrderProductsCubit, ProductsState>(
                                builder: (context, productState) {
                                  if (productState is ProductsLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (productState is ProductsError) {
                                    return Center(
                                      child: Text(productState.message),
                                    );
                                  }
                                  if (productState is ProductsLoaded) {
                                    final products = productState.products;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: items.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 35,
                                              mainAxisSpacing: 20,
                                              childAspectRatio: 6,
                                            ),
                                        itemBuilder: (context, index) {
                                          final item = items[index];
                                          final productId =
                                              (item['productId'] is Map)
                                                  ? item['productId']['_id']
                                                  : item['productId'];
                                          final qty = item['itemQty'];

                                          final product = products.firstWhere(
                                            (p) => p.id == productId,
                                            orElse:
                                                () => ProductModel(
                                                  id: '',
                                                  name: 'منتج غير موجود',
                                                  category: '',
                                                  description: '',
                                                  imageList: [],
                                                  price: 0,
                                                  productVariants: const [],
                                                  isKG: false,
                                                  isTON: false,
                                                  isLITER: false,
                                                  isCUBIC_METER: false,
                                                  updatedAt: '',
                                                  purchasePrice: 0,
                                                  stockQty: 0,
                                                  stockType: '',
                                                  averageRate: 0,
                                                ),
                                          );

                                          final imageUrl =
                                              (product.imageList.isNotEmpty)
                                                  ? product.imageList.first
                                                  : (item['productId'] is Map &&
                                                      item['productId']['imageList'] !=
                                                          null &&
                                                      (item['productId']['imageList']
                                                              as List)
                                                          .isNotEmpty)
                                                  ? item['productId']['imageList'][0]
                                                  : "";

                                          return Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: AppColors.black8,
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    imageUrl,
                                                    width: 120,
                                                    height: 120,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        width: 120,
                                                        height: 120,
                                                        color: Colors.grey[200],
                                                        child: const Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .broken_image,
                                                              size: 40,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            SizedBox(height: 8),
                                                            Text(
                                                              "لا توجد صورة",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      
                                                      Text(
                                                        product.name !=
                                                                'منتج غير موجود'
                                                            ? product.name
                                                            : (item['productId']
                                                                    is Map
                                                                ? item['productId']['name'] ??
                                                                    'منتج غير موجود'
                                                                : 'منتج غير موجود'),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                      Text(
                                                        "السعر: ${product.price.toInt()} ج",
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors.black60,
                                                        ),
                                                      ),
                                                      Text(
                                                        "الكمية: $qty",
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors.black60,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }

                                  return const SizedBox();
                                },
                              ),

                              const SizedBox(height: 16),

                              if (hasDeliveryInfo)
                                Column(
                                  children: [
                                    _buildSection(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "تفاصيل التوصيل",
                                            style: TextStyle(
                                              color: AppColors.black87,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "مصاريف التوصيل: ${order['deliveryPrice']} ج",
                                            style: const TextStyle(
                                              color: AppColors.black60,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            formatArabicDate(
                                              order['deliveryDate'],
                                            ),
                                            style: const TextStyle(
                                              color: AppColors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    _buildSection(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "عدد المنتجات: ${cart['totalQty']}",
                                            style: const TextStyle(
                                              color: AppColors.black60,
                                            ),
                                          ),
                                          Text(
                                            "المجموع: ${cart['totalPrice']}",
                                            style: const TextStyle(
                                              color: AppColors.black60,
                                            ),
                                          ),
                                          Text(
                                            "سعر التوصيل: ${order['deliveryPrice']}",
                                            style: const TextStyle(
                                              color: AppColors.black60,
                                            ),
                                          ),
                                          Text(
                                            "الإجمالي: ${cart['totalPrice'] + order['deliveryPrice']}",
                                            style: const TextStyle(
                                              color: AppColors.black60,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          if (order['receiptImage'] != null)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                order['receiptImage'],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              else
                                _buildSection(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "بيانات التوصيل",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: deliveryPriceController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: "سعر التوصيل",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final pickedDate =
                                              await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(2024),
                                                lastDate: DateTime(2030),
                                              );
                                          if (pickedDate != null) {
                                            setState(() {
                                              selectedDeliveryDate = pickedDate;
                                            });
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.date_range,
                                          color: Colors.white,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                        ),
                                        label: Text(
                                          selectedDeliveryDate == null
                                              ? "اختر تاريخ التوصيل"
                                              : "تاريخ التوصيل: ${DateFormat('yyyy-MM-dd').format(selectedDeliveryDate!)}",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 16),
                              const SizedBox(height: 24),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 16),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 14,
                                          ),
                                        ),
                                        onPressed: () async {
  
  if (deliveryPriceController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("من فضلك أدخل سعر التوصيل قبل تغيير الحالة"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final oldStatusEn = statusKey;
  final newStatusEn = selectedStatus ?? oldStatusEn;

  
  final oldStatusAr = statusArabicToEnglish.keys.firstWhere(
    (ar) => statusArabicToEnglish[ar] == oldStatusEn,
    orElse: () => "",
  );

  final newStatusAr = statusArabicToEnglish.keys.firstWhere(
    (ar) => statusArabicToEnglish[ar] == newStatusEn,
    orElse: () => "",
  );

  
  if (newStatusEn == oldStatusEn) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("لم يتم تغيير الحالة"),
      ),
    );
    return;
  }

  
  final confirm = await showConfirmChangeStatus(
    context: context,
    oldStatus: oldStatusAr,
    newStatusAr: newStatusAr,
  );

  if (confirm != true) return;

  
  try {
    await context.read<ApiService>().updateOrderStatus(
          orderId: order['orderId'],
          newStatus: newStatusEn,
          deliveryPrice: double.tryParse(
                deliveryPriceController.text.trim(),
              ) ??
              0,
          deliveryDate: selectedDeliveryDate ?? DateTime.now(),
        );

    
    context.read<OrderDetailsCubit>().fetchOrderDetails(order['orderId']);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✔ تم تحديث حالة الطلب بنجاح"),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("❌ خطأ: $e"),
      ),
    );
  }
},

child: Text("تاكيد"),
                                      ),
                                      const SizedBox(width: 16),

                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 14,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("إلغاء"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String text, bool isActive, bool isCompleted, bool isCancelled) {
  final Color color = isCancelled
      ? Colors.red
      : isActive
          ? Colors.green
          : (isCompleted ? AppColors.primary : AppColors.disabled);

  return Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color, width: 2),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.background, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}


Widget _buildLine(bool isCompleted, bool isCancelled) {
  final Color color = isCancelled
      ? Colors.red
      : (isCompleted ? AppColors.primary : AppColors.disabled);

  return Expanded(
    child: Container(
      height: 2,
      color: color,
    ),
  );
}

  Widget _buildSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black8),
      ),
      child: child,
    );
  }
}

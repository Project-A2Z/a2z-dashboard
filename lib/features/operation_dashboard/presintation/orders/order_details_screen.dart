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


class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});
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
          create: (context) =>
              OrderDetailsCubit(context.read<ApiService>())
                ..fetchOrderDetails(orderId),
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
                        return Center(child: Text("خطأ: ${orderState.message}"));
                      }
                      if (orderState is OrderDetailsLoaded) {
                        final order = orderState.order;
                    
                        final cart = order['cartId'] ?? {};
final items = (cart['items'] as List?) ?? [];
                        final address = order['address'] ?? {};
final createdAt = order['createdAt'] ?? "";
final deliveryDate = order['deliveryDate'] ?? "";
          DateTime createdDate = DateTime.parse(createdAt); 
          String formattedDate = DateFormat('yyyy-MM-dd').format(createdDate); 
          final totalPrice = cart['totalPrice'];
          
          
                        final productIds = items
    .map((item) {
      final product = item['productId'];
      if (product is Map && product['_id'] != null) {
        return product['_id'] as String;
      } else if (product is String) {
        return product;
      } else {
        return '';
      }
    })
    .where((id) => id.isNotEmpty)
    .toList();

          
                        context
                            .read<OrderProductsCubit>()
                            .fetchOrderProducts(productIds);
          
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              Container(
     
            child: Column(
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: DashboardHeader(title: "الطلبات")),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("تفاصيل الطلب ${orderId}",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black,fontSize: 24),),
                  ],
                ),
                 SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                    _buildStep(
                      "قيد المراجعة",
                      order['status'] == "Under review",
                      order['status'] != "Under review",
                    ),
                    _buildLine(order['status'] != "Under review"),
                          
                    _buildStep(
                      "تم المراجعة",
                      order['status'] == "reviewed",
                      order['status'] == "prepared" ||
                order['status'] == "shipped" ||
                order['status'] == "delivered",
                    ),
                    _buildLine(order['status'] == "prepared" ||
                          order['status'] == "shipped" ||
                          order['status'] == "delivered"),
                          
                    _buildStep(
                      "تم التجهيز",
                      order['status'] == "prepared",
                      order['status'] == "shipped" || order['status'] == "delivered",
                    ),
                    _buildLine(order['status'] == "shipped" || order['status'] == "delivered"),
                          
                    _buildStep(
                      "تم الشحن",
                      order['status'] == "shipped",
                      order['status'] == "delivered",
                    ),
                    _buildLine(order['status'] == "delivered"),
                          
                    _buildStep(
                      "تم التسليم",
                      order['status'] == "delivered",
                      false,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
                              const SizedBox(height: 24),
          
                              
                             _buildSection(
        
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("رقم الطلب: ${order['orderId']}",style: TextStyle(color: AppColors.black60),),
                Text(
                  "السعر: ${totalPrice} ج",
                  style: TextStyle(color: AppColors.black60),
                ),
               
                Text("تم تقديم الطلب في: $formattedDate",style: TextStyle(color: AppColors.black60),),
                Text("العنوان: ${address['address']}, ${address['city']} ",style: TextStyle(color: AppColors.black60),),
                Text("رقم الهاتف: ${address['phoneNumber']}",style: TextStyle(color: AppColors.black60),),
                Text("ب اسم: ${address['firstName']} ${address['lastName']}",style: TextStyle(color: AppColors.black60),),
              ],
            ),
          ),
          
                              const SizedBox(height: 6),
                               Text("المنتجات الخاصة بالطلب",style: TextStyle(fontSize: 20,color: Colors.black87,fontWeight: FontWeight.w600),),
                               const SizedBox(height: 10),
          
                             
BlocBuilder<OrderProductsCubit, ProductsState>(
  builder: (context, productState) {
    if (productState is ProductsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (productState is ProductsError) {
      return Center(child: Text(productState.message));
    }
    if (productState is ProductsLoaded) {
      final products = productState.products;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            crossAxisSpacing: 35,
            mainAxisSpacing: 20,
            childAspectRatio: 6, 
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final productId = item['productId'];
            final qty = item['itemQty'];

            final product = products.firstWhere(
              (p) => p.id == productId,
              orElse: () => ProductModel(
                id: '',
                name: 'منتج غير موجود',
                category: '',
                description: '',
                imageList: [],
                price: 0,
                stockQty: 0,
                stockType: '',
                averageRate: 0,
              ),
            );

            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.black8), 
                color: Colors.white,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:Image.network(
  product.imageList.isNotEmpty
      ? product.imageList.first
      : "", // سيبها فاضية عشان يدخل على errorBuilder
  width: 120,
  height: 120,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Container(
      width: 120,
      height: 120,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "لا توجد صورة",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  },
)

                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold,color: AppColors.primary),
                          overflow: TextOverflow.ellipsis,
                          
                          
                        ),
                        Text("السعر: ${product.price.toInt()} ج",style: TextStyle(color: AppColors.black60),), 
                        Text("الكمية: ${qty}",style: TextStyle(color: AppColors.black60),), 
                       
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
          
                              
                              _buildSection(
                                
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("تفاصيل التوصيل",style: TextStyle(color: AppColors.black87,fontSize: 24,fontWeight: FontWeight.w600),),
                                    SizedBox(height: 8,),
                                    Text(
                                        "مصاريف التوصيل: ${order['deliveryPrice']} ج",style: TextStyle(color: AppColors.black60,fontSize: 20,fontWeight: FontWeight.w600)),
                                    Text(formatArabicDate(deliveryDate),style: TextStyle(color: AppColors.black87,fontSize: 16,fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
          
                              
                              _buildSection(
                               
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "عدد المنتجات: ${cart['totalQty']}"),
                                    Text("المجموع: ${cart['totalPrice']}"),
                                    Text(
                                        "سعر التوصيل: ${order['deliveryPrice']}"),
                                    Text(
                                      "الإجمالي: ${cart['totalPrice'] + order['deliveryPrice']}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12),
                                    if (order['receiptImage'] != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          order['receiptImage'],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
          
                              const SizedBox(height: 24),
          
if (order['status'] == "Under review")
  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        ),
        onPressed: () async {
          try {
            await context.read<ApiService>().updateOrderStatus(
              orderId: order['orderId'], 
              newStatus: "cancelled",
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("🚫 تم إلغاء الطلب")),
            );

            
            context.read<OrderDetailsCubit>().fetchOrderDetails(order['orderId']);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("❌ خطأ: $e")),
            );
          }
        },
        child: const Text("إلغاء"),
      ),
      const SizedBox(width: 16),

      
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        ),
        onPressed: () async {
          try {
            await context.read<ApiService>().updateOrderStatus(
              orderId: order['orderId'], 
              newStatus: "reviewed",
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ تم تأكيد الطلب")),
            );

            
            context.read<OrderDetailsCubit>().fetchOrderDetails(order['orderId']);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("❌ خطأ: $e")),
            );
          }
        },
        child: const Text("تأكيد الطلب"),
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

  Widget _buildStep(String text, bool isActive, bool isCompleted) {
  return Container(
   
    decoration: BoxDecoration(
          color: isActive
              ? Colors.green
              : (isCompleted ? AppColors.primary : AppColors.disabled),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : (isCompleted ? AppColors.primary : AppColors.disabled),
            width: 2,
          ),
        ),
    child: Container(
    
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
         border: Border.all(
            color:
                 AppColors.background
                ,
            width: 2,
          ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.green
              : (isCompleted ? AppColors.primary : AppColors.disabled),
          borderRadius: BorderRadius.circular(20),
        
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}


Widget _buildLine(bool isCompleted) {
  return Expanded(
    child: Container(
      height: 2,
      color: isCompleted ? AppColors.primary : AppColors.disabled,
    ),
  );
}

  
  Widget _buildSection({ required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
       
          child,
        ],
      ),
    );
  }
   Widget _header() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        "الطلبات",
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppColors.black87,
        ),
      ),
      CircleAvatar(
        radius: 25,
        backgroundColor: AppColors.primary,
        child: const Text(
          "M",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

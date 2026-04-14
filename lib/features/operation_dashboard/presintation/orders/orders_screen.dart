import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/core/widgets/header_operation.dart';
import 'package:disctop_app/core/widgets/pagination_control.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_operation.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/orders_cubit/order_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/orders_cubit/order_state.dart';
import 'package:disctop_app/features/operation_dashboard/presintation/orders/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String selectedFilter = 'الكل';
  final String selectedKey = "الطلبات";
  String searchQuery = '';
  String selectedPaymentWay = 'طريقة الدفع';

  int rowsPerPage = 10;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().fetchOrders();
  }

  String _normalizeStatusKey(String status) {
    final cleaned = status.trim().toLowerCase().replaceAll(RegExp(r'[-_\s]'), '');
    switch (cleaned) {
      case 'underreview':
        return 'UnderReview';
      case 'reviewed':
        return 'Reviewed';
      case 'prepared':
        return 'Prepared';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  
  String _translateStatus(String status) {
    switch (_normalizeStatusKey(status)) {
      case 'UnderReview':
        return 'قيد المراجعة';
      case 'Reviewed':
        return 'تم المراجعة';
      case 'Prepared':
        return 'تم التجهيز';
      case 'Shipped':
        return 'تم الشحن';
      case 'Delivered':
        return 'تم التسليم';
      case 'Cancelled':
        return 'تم الإلغاء';
      default:
        return status;
    }
  }

  
  String _translatePaymentWay(String paymentWay) {
    switch (paymentWay.toLowerCase()) {
      case 'cash':
        return 'كاش';
      case 'online':
        return 'اونلاين';
      default:
        return paymentWay;
    }
  }

  
  Color _statusColor(String status) {
    final statusKey = _normalizeStatusKey(status);
    if (statusKey == 'Prepared' || status.contains('تم التجهيز')) {
      return AppColors.primary;
    }
    if (statusKey == 'UnderReview' || status.contains('قيد المراجعة')) {
      return  AppColors.error;
    }
    if (statusKey == 'Reviewed' || status.contains('تم المراجعة')) {
      return  AppColors.secondary2;
    }
    
    if (statusKey == 'Shipped' || status.contains('شحن')) {
      return AppColors.disabled;
    }
    if (statusKey == 'Delivered' || status.contains('تسليم')) {
      return AppColors.secondary1;
    }
    if (statusKey == 'Cancelled' || status.contains('إلغاء')) {
      return const Color(0xFFE53935);
    }
    return const Color(0xFF757575);
  }

  final List<String> orderFilters = [
    'الكل',
    'قيد المراجعة',
    'تم التجهيز',
    'تم الشحن',
    'تم التسليم',
    'تم الإلغاء',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Sidebar_Operation(selectedKey: selectedKey),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: DashboardHeader(title: "الطلبات",onRefreshTap: () {
                        setState(() {
                          context.read<OrdersCubit>().fetchOrders();
                        });
                      },)),
                    const SizedBox(height: 24),

                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: orderFilters.map((filter) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _filterButton(filter),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    
                    Row(
                      children: [
                        _buildSearchField(),
                        Spacer(),
                        _buildPaymentDropdown(),
                      ],
                    ),
                    const SizedBox(height: 20),

                    
                    Expanded(
                      child: BlocBuilder<OrdersCubit, OrdersState>(
                        builder: (context, state) {
                          if (state is OrdersLoading) {
                            return const Center(
                                child: CircularProgressIndicator(color: AppColors.primary,));
                          }

                          if (state is OrdersError) {
                            return Center(child: Text('خطأ في تحميل الطلبات',style: TextStyle(color: Colors.red,fontSize: 20),));
                          }

                          if (state is OrdersLoaded) {
                            
                            final hasOrders = state.orders.isNotEmpty;
                            var orders = _applyFilters(state.orders);

                            if (orders.isEmpty) {
                              
                              final isSearching = searchQuery.isNotEmpty || 
                                                 selectedFilter != 'الكل' || 
                                                 selectedPaymentWay != 'طريقة الدفع';
                              
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    isSearching && hasOrders? 
                                    Image.asset("assets/images/rafiki.png"):Image.asset("assets/images/Character.png"),
                                    const SizedBox(height: 16),
                                    Text(
                                      isSearching && hasOrders 
                                          ? 'لم تتوفر نتائج البحث'
                                          : 'لا يوجد طلبات بعد',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.black60,
                                      ),
                                    ),
                                    
                                  ],
                                ),
                              );
                            }

                             int totalPages =
                                (orders.length / rowsPerPage).ceil();
                            if (totalPages == 0) totalPages = 1;

                            if (currentPage < 1) currentPage = 1;
                            if (currentPage > totalPages)
                              currentPage = totalPages;

                            int startIndex = (currentPage - 1) * rowsPerPage;
                            int endIndex = startIndex + rowsPerPage;
                            if (endIndex > orders.length)
                              endIndex = orders.length;

                            var currentPageItems = orders.sublist(
                              startIndex,
                              endIndex,
                            );

                            return Column(
                              children: [
                                Expanded(
                                  child: _buildDataTable(currentPageItems),
                                ),
                                const SizedBox(height: 16),
                                PaginationControls(
                                  currentPage: currentPage - 1,
                                  totalPages: totalPages,
                                  totalItems: orders.length,
                                  displayedStart:
                                      startIndex + 1, 
                                  displayedEnd: endIndex,
                                  onNext:
                                      currentPage < totalPages
                                          ? () => setState(() => currentPage++)
                                          : null,
                                  onPrevious:
                                      currentPage > 1
                                          ? () => setState(() => currentPage--)
                                          : null,
                                ),
                              ],
                            );
                          }

                          return const SizedBox();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> orders) {
    
    if (searchQuery.isNotEmpty) {
      orders = orders.where((order) {
        final orderId = (order['orderId'] ?? '').toString().toLowerCase();
        final firstName = (order['address']?['firstName'] ?? '').toString().toLowerCase();
        final lastName = (order['address']?['lastName'] ?? '').toString().toLowerCase();
        final fullName = '$firstName $lastName';
        final query = searchQuery.toLowerCase();
        
        return orderId.contains(query) || fullName.contains(query);
      }).toList();
    }

    
    if (selectedFilter != 'الكل') {
      orders = orders.where((order) {
        final status = _translateStatus(order['status'] ?? '');
        return status == selectedFilter;
      }).toList();
    }

    
    if (selectedPaymentWay != 'طريقة الدفع') {
      orders = orders.where((order) {
        final paymentWay = order['paymentDetails']?['paymentWay'] ?? '';
        final translated = _translatePaymentWay(paymentWay);
        return translated == selectedPaymentWay;
      }).toList();
    }

    return orders;
  }

  
  Widget _buildDataTable(List<Map<String, dynamic>> orders) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowHeight: 56,
              dataRowHeight: 64,
              columnSpacing: 20,
              headingRowColor:
                  MaterialStateProperty.all(AppColors.primary),
              headingTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              dataTextStyle: const TextStyle(
                color: AppColors.black60,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              columns: const [
                DataColumn(
                  label: Expanded(
                    child: Text('رقم الطلب', textAlign: TextAlign.center),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('العميل', textAlign: TextAlign.center),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('السعر', textAlign: TextAlign.center),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('عدد المنتجات', textAlign: TextAlign.center),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('تاريخ الطلب', textAlign: TextAlign.center),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('طريقة الدفع', textAlign: TextAlign.center),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('الحالة', textAlign: TextAlign.center),
                  ),
                ),
              ],
              rows: orders.map((order) {
  final orderId = order['orderId'] ?? '---';
  final firstName = order['address']?['firstName'] ?? '';
  final lastName = order['address']?['lastName'] ?? '';
  final customerName = '$firstName $lastName'.trim();
  final totalPrice = order['cartId']?['totalPrice'] ?? 0;
  final totalQty = order['cartId']?['totalQty'] ?? 0;
  final createdAt = order['createdAt']?.toString().substring(0, 10) ?? '';
  final paymentWay = _translatePaymentWay(order['paymentDetails']?['paymentWay'] ?? '---');
  final status = _translateStatus(order['status'] ?? '');

  return DataRow(
    
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.hovered)) {
          return AppColors.primary.withOpacity(0.05); 
        }
        return null; 
      },
    ),
    cells: [
      DataCell(_buildHoverableCell(
        context,
        orderId,
        () => _openOrderDetails(context, orderId),
      )),
      DataCell(_buildHoverableCell(
        context,
        customerName.isEmpty ? '---' : customerName,
        () => _openOrderDetails(context, orderId),
      )),
      DataCell(_buildHoverableCell(
        context,
        '$totalPrice',
        () => _openOrderDetails(context, orderId),
      )),
      DataCell(_buildHoverableCell(
        context,
        '$totalQty',
        () => _openOrderDetails(context, orderId),
      )),
      DataCell(_buildHoverableCell(
        context,
        createdAt,
        () => _openOrderDetails(context, orderId),
      )),
      DataCell(_buildHoverableCell(
        context,
        paymentWay,
        () => _openOrderDetails(context, orderId),
      )),
      DataCell(_buildHoverableCell(
        context,
        status,
        () => _openOrderDetails(context, orderId),
        textColor: _statusColor(status),
        isBold: true,
      )),
    ],
  );
}).toList(),



            ),
          ),
        ),
      ),
    );
  }

  
  Widget _filterButton(String label) {
    final isSelected = selectedFilter == label;
    return OutlinedButton(
      onPressed: () => setState(() {
        selectedFilter = label;
        currentPage = 1;
      }),
      style: OutlinedButton.styleFrom(
        backgroundColor:  Colors.white,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.black16,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF757575),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  
  Widget _buildSearchField() {
    return SizedBox(
      width: 280,
      child: TextField(
        decoration: InputDecoration(
          hintText: "بحث",
          hintStyle: const TextStyle(color: AppColors.black37, fontSize: 16),
          suffixIcon: const Icon(Icons.search, color: AppColors.black37),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.black16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.black16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide:
                const BorderSide(color: AppColors.black16, width: 1),
          ),
        ),
        onChanged: (v) => setState(() {
          searchQuery = v;
          currentPage = 1;
        }),
      ),
    );
  }

  
  Widget _buildPaymentDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      width: 250,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPaymentWay,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF757575)),
          style: const TextStyle(
            color: AppColors.black60,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          onChanged: (v) => setState(() {
            selectedPaymentWay = v!;
            currentPage = 1;
          }),
          items: const [
            DropdownMenuItem(value: 'طريقة الدفع', child: Text('طريقة الدفع')),
            DropdownMenuItem(value: 'كاش', child: Text('كاش')),
            DropdownMenuItem(value: 'اونلاين', child: Text('اونلاين')),
          ],
        ),
      ),
    );
  }

  
  Widget _buildHoverableCell(BuildContext context, String text, VoidCallback onTap,
    {Color? textColor, bool isBold = false}) {
  return InkWell(
    onTap: onTap,
    hoverColor: Colors.transparent, 
    child: MouseRegion(
      cursor: SystemMouseCursors.click, 
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? AppColors.black60,
            fontWeight:  FontWeight.bold ,
            fontSize: 16,
          ),
        ),
      ),
    ),
  );
}

void _openOrderDetails(BuildContext context, String orderId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<OrdersCubit>(),
        child: OrderDetailsScreen(orderId: orderId),
      ),
    ),
  );
}

}
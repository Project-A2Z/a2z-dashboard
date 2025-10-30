import 'package:disctop_app/core/widgets/header_operation.dart';
import 'package:disctop_app/core/widgets/pagination_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_operation.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/payments_cubit/payment_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/payments_cubit/payment_state.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/payments_cubit/payment_model.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final String selectedKey = "التعاملات المالية";
  String selectedFilter = 'الكل';
  String selectedPayment = 'طريقة الدفع';
  String selectedStatus = 'الحالة';
  String searchQuery = '';

  int rowsPerPage = 7;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    context.read<PaymentCubit>().fetchPayments();
  }

  Color _statusColor(String s) {
    s = s.toLowerCase();
    if (s.contains('تم')) return const Color(0xFF4CAF50);
    if (s.contains('متأخر') || s.contains('cancel'))
      return const Color(0xFFE53935);
    return Colors.black;
  }

  String _translatePaymentWay(String paymentWay) {
    switch (paymentWay.toLowerCase()) {
      case 'cash':
      case 'كاش':
        return 'كاش';
      case 'online':
      case 'اونلاين':
        return 'اونلاين';
      default:
        return paymentWay;
    }
  }

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
                      child: DashboardHeader(
                        title: "التعاملات المالة",
                        onRefreshTap: () {
                          context.read<PaymentCubit>().fetchPayments();
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _filterButton("الكل"),
                        const SizedBox(width: 12),
                        _filterButton("مستلمة"),
                        const SizedBox(width: 12),
                        _filterButton("غير مستلمة"),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        _buildSearchField(),

                        const Spacer(),

                        _buildDropdown(
                          value: selectedPayment,
                          items: const ["طريقة الدفع", "كاش", "اونلاين"],
                          onChanged:
                              (v) => setState(() {
                                selectedPayment = v!;
                                currentPage = 1;
                              }),
                        ),
                        const SizedBox(width: 16),
                        _buildDropdown(
                          value: selectedStatus,
                          items: const ["الحالة", "تم الدفع", "متأخر"],
                          onChanged:
                              (v) => setState(() {
                                selectedStatus = v!;
                                currentPage = 1;
                              }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: BlocBuilder<PaymentCubit, PaymentState>(
                        builder: (context, state) {
                          if (state is PaymentLoading) {
                            return const Center(
                              child: CircularProgressIndicator(color: AppColors.primary,),
                            );
                          }
                          if (state is PaymentError) {
                            return Center(
                              child: Center(child: Text('خطأ في تحميل المعاملات المالية',style: TextStyle(color: Colors.red,fontSize: 20),)),
                            );
                          }
                          if (state is PaymentLoaded) {
                            var payments = state.payments;

                            payments = _applyFilters(payments);

                            if (state.payments.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/images/no_payment.png"),
                                    Text(
                                      "لا يوجد تعاملات مالية بعد",
                                      style: TextStyle(
                                        color: AppColors.black60,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            if (payments.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/images/rafiki.png"),
                                    Text(
                                      "لم تتوفر نتائج البحث",
                                      style: TextStyle(
                                        color: AppColors.black60,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            int totalPages =
                                (payments.length / rowsPerPage).ceil();
                            if (totalPages == 0) totalPages = 1;

                            if (currentPage < 1) currentPage = 1;
                            if (currentPage > totalPages)
                              currentPage = totalPages;

                            int startIndex = (currentPage - 1) * rowsPerPage;
                            int endIndex = startIndex + rowsPerPage;
                            if (endIndex > payments.length)
                              endIndex = payments.length;

                            var currentPageItems = payments.sublist(
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
                                  totalItems: payments.length,
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

  List<PaymentModel> _applyFilters(List<PaymentModel> payments) {
    if (searchQuery.isNotEmpty) {
      payments =
          payments.where((p) {
            final name =
                '${p.user?['firstName'] ?? ''} ${p.user?['lastName'] ?? ''}'
                    .toLowerCase();
            final query = searchQuery.toLowerCase();
            return name.contains(query) ||
                p.orderId.toLowerCase().contains(query) ||
                (p.numOperation ?? '').toLowerCase().contains(query);
          }).toList();
    }

    if (selectedFilter == "مستلمة") {
      payments =
          payments
              .where((p) => p.paymentStatus.toLowerCase().contains('تم'))
              .toList();
    } else if (selectedFilter == "غير مستلمة") {
      payments =
          payments
              .where((p) => !p.paymentStatus.toLowerCase().contains('تم'))
              .toList();
    }

    if (selectedPayment != "طريقة الدفع") {
      payments =
          payments.where((p) {
            final translatedWay = _translatePaymentWay(p.paymentWay);
            return translatedWay == selectedPayment;
          }).toList();
    }

    if (selectedStatus != "الحالة") {
      payments =
          payments.where((p) {
            if (selectedStatus == "تم الدفع") {
              return p.paymentStatus.toLowerCase().contains('تم');
            } else if (selectedStatus == "متأخر") {
              return !p.paymentStatus.toLowerCase().contains('تم');
            }
            return true;
          }).toList();
    }

    return payments;
  }

  Widget _buildDataTable(List<PaymentModel> payments) {
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
              headingRowColor: MaterialStateProperty.all(
                AppColors.primary,
              ),
              headingTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              dataTextStyle: const TextStyle(
                color: Color(0xFF424242),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              columns: const [
                DataColumn(
                  label: Expanded(
                    child: Text(
                      "رقم المعاملة",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      "العميل",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      "المبلغ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      "تاريخ الطلب",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      "طريقة الدفع",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text("الحالة", textAlign: TextAlign.center),
                  ),
                ),
              ],
              rows:
                  payments.map((p) {
                    final name =
                        '${p.user?['firstName'] ?? ''} ${p.user?['lastName'] ?? ''}';
                    final status =
                        p.paymentStatus.toLowerCase().contains('تم')
                            ? "تم الدفع"
                            : "متأخر";
                    final paymentWay = _translatePaymentWay(p.paymentWay);

                    return DataRow(
                      cells: [
                        DataCell(
                          Center(
                            child: Text(
                              p.numOperation ?? '---',
                              style: TextStyle(
                                color: AppColors.black60,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              name.trim().isEmpty ? 'غير محدد' : name,
                              style: TextStyle(
                                color: AppColors.black60,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              '${p.totalPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: AppColors.black60,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              p.createdAt.substring(0, 10),
                              style: TextStyle(
                                color: AppColors.black60,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              paymentWay,
                              style: TextStyle(
                                color: AppColors.black60,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _statusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
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
      onPressed:
          () => setState(() {
            selectedFilter = label;
            currentPage = 1;
          }),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.black16,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.black60,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: 250,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF757575)),
          style: const TextStyle(
            color: AppColors.black60,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          onChanged: onChanged,
          items:
              items.map((item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      width: 340,
      child: TextField(
        decoration: InputDecoration(
          hintText: "بحث",
          hintStyle: const TextStyle(color: AppColors.black37, fontSize: 16),
          suffixIcon: const Icon(
            Icons.search_outlined,
            color: AppColors.black37,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 25),
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
            borderSide: const BorderSide(color: AppColors.black16, width: 1.5),
          ),
        ),
        onChanged:
            (v) => setState(() {
              searchQuery = v;
              currentPage = 1;
            }),
      ),
    );
  }
}

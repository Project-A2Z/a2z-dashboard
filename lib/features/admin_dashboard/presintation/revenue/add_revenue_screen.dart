import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/core/widgets/header_admin.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_admin.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/revenue_cubit/add_revenue_cubit.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/revenue_cubit/add_revenue_state.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/payments_cubit/payment_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? selectedDate;

  final selectedKey = "الإيرادات";
  String paymentWay = "كاش";
  String paymentStatus = "تم الدفع";
  String type = "مبيعات";

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Sidebar_Admin(selectedKey: selectedKey),
            Expanded(
              child: BlocProvider(
  create: (context) => AddPaymentCubit(ApiService()),
  child: BlocConsumer<AddPaymentCubit, AddPaymentState>(
    listener: (context, state) {
                    if (state is AddPaymentSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("تم إنشاء الإيراد بنجاح ✅"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _amountController.clear();
                      _dateController.clear();
                    } else if (state is AddPaymentError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final cubit = context.read<AddPaymentCubit>();

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: DashboardHeader_admin(title: "إضافة إيراد"),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _amountController,
                                        label: "المبلغ",
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _dateController,
                                        label: "التاريخ",
                                        readOnly: true,
                                        suffixIcon:
                                            Icons.calendar_today_outlined,
                                        onTap: () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2100),
                                          );
                                          if (date != null) {
                                            setState(() {
                                              selectedDate = date;
                                              _dateController.text =
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(date);
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 35),
                                _buildRadioSection(
                                  title: "طريقة الدفع",
                                  options: ["كاش", "اونلاين"],
                                  selected: paymentWay,
                                  onChanged: (val) =>
                                      setState(() => paymentWay = val!),
                                ),
                                const SizedBox(height: 35),
                                _buildRadioSection(
                                  title: "الحالة",
                                  options: [
                                    "تم دفع جزء",
                                    "تم الدفع",
                                    "تم الاسترجاع",
                                    "تم الإلغاء"
                                  ],
                                  selected: paymentStatus,
                                  onChanged: (val) =>
                                      setState(() => paymentStatus = val!),
                                ),
                                const SizedBox(height: 50),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: state is PaymentLoading
                                              ? null
                                              : () {
                                                  final amount = double.tryParse(
                                                          _amountController
                                                              .text) ??
                                                      0;
                                                  if (amount <= 0) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            "من فضلك أدخل مبلغ صحيح"),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  cubit.createPayment(
                                                    totalPrice: amount,
                                                    paymentWay: paymentWay ==
                                                            "كاش"
                                                        ? "cash"
                                                        : "online",
                                                    paymentWith: "instaPay",
                                                    paymentStatus:
                                                        _mapPaymentStatus(
                                                            paymentStatus),
                                                    type:'revenues',
                                                  );
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF4CAF50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: state is PaymentLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Text(
                                                  "إضافة الإيراد",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: SizedBox(
                                        height: 50,
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                color: Color(0xFF4CAF50),
                                                width: 1.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: const Text(
                                            "إلغاء",
                                            style: TextStyle(
                                              color: Color(0xFF4CAF50),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧩 تحويل الحالات
  String _mapPaymentStatus(String status) {
    switch (status) {
      case "تم الدفع":
        return "paid";
      case "تم دفع جزء":
        return "deposit";
      case "تم الاسترجاع":
        return "refunded";
      case "تم الإلغاء":
        return "cancelled";
      default:
        return "pending";
    }
  }


  // 🧱 TextField Builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool readOnly = false,
    IconData? suffixIcon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        absorbing: readOnly,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon:
                suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            ),
          ),
        ),
      ),
    );
  }

  // 🧱 Radio Buttons Builder
  Widget _buildRadioSection({
    required String title,
    required List<String> options,
    required String selected,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.black16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            children: options.map((option) {
              final isSelected = selected == option;
              return Expanded(
                child: InkWell(
                  onTap: () => onChanged(option),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey,
                              width: 2),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF4CAF50)),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(option),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

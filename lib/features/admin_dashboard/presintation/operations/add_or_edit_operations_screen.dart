import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_admin.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/add_or_edit_operation_cubit.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/add_or_edit_operation_state.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/operations_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/operations_model.dart';

class AddOrEditEmployeeScreen extends StatefulWidget {
  final Operation? operation; 

  const AddOrEditEmployeeScreen({super.key, this.operation});

  @override
  State<AddOrEditEmployeeScreen> createState() =>
      _AddOrEditEmployeeScreenState();
}

class _AddOrEditEmployeeScreenState extends State<AddOrEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _salaryController;
  late TextEditingController _passwordController;

  DateTime? _selectedDate;
  final selectedKey = "الموظفين";

  bool get isEdit => widget.operation != null;

  @override
  void initState() {
    super.initState();
  
_passwordController = TextEditingController(); 

    _nameController =
        TextEditingController(text: widget.operation?.firstName ?? '');
    _emailController =
        TextEditingController(text: widget.operation?.email ?? '');
    _phoneController =
        TextEditingController(text: widget.operation?.phoneNumber ?? '');
    _salaryController =
        TextEditingController(text: widget.operation?.salary?.toString() ?? '');
    _selectedDate = widget.operation?.dateOfSubmission != null
        ? DateTime.tryParse(widget.operation!.dateOfSubmission!)
        : null;
  }
 
  Future<String?> _showAdminPasswordDialog(BuildContext context) async {
    final TextEditingController _controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Directionality(
            textDirection: TextDirection.rtl,
            child: const Text(
              'تأكيد الهوية',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          backgroundColor: AppColors.background,
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: _controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'اكتب كلمة المرور',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'إلغاء',
                style: TextStyle(color: AppColors.error, fontSize: 16),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text(
                'تأكيد',
                style: TextStyle(color: AppColors.primary, fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Sidebar_Admin(selectedKey: selectedKey),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: BlocConsumer<AddOrEditEmployeeCubit,
                    AddOrEditEmployeeState>(
                  listener: (context, state) {
                    if (state is AddOrEditEmployeeSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                      context.read<OperationsCubit>().fetchOperations();
                      Navigator.pop(context);
                    } else if (state is AddOrEditEmployeeError) {
                       Center(child: Text("خطأ في تحميل الموظفين",style: TextStyle(color: Colors.red,fontSize: 20),));
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            isEdit ? "تعديل بيانات الموظف" : "إضافة موظف جديد",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.black16),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    
                                    Expanded(child: _buildField("الاسم", _nameController)),
                                    const SizedBox(width: 20),
                                    Expanded(child: _buildField("رقم الهاتف", _phoneController)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(child: _buildField("البريد الإلكتروني", _emailController)),
                                    const SizedBox(width: 20),
                                    Expanded(child: _buildDatePicker(context)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(child: _buildField("المرتب", _salaryController)),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: _buildField("تعديل كلمة المرور", _passwordController),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        Row(
                          children: [
                            Expanded(child: _buildSubmitButton(context, state)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildCancelButton(context)),
                          ],
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

  Widget _buildField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Color(0xffA1A1A1)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: AppColors.black16),
        ),
        enabledBorder:OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: AppColors.black16),
        ) ,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: AppColors.black16),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
       validator: (v) {
      if (label == "كلمة المرور") return null; // Optional
      return v!.isEmpty ? "هذا الحقل مطلوب" : null;
    },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.black16),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate == null
                  ? "تاريخ التعيين"
                  : "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}",
              style: const TextStyle(color: Color(0xffA1A1A1)),
            ),
            const Icon(Icons.calendar_today, color: AppColors.black60),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text("إلغاء", style: TextStyle(color: AppColors.primary)),
    );
  }

  Widget _buildSubmitButton(
      BuildContext context, AddOrEditEmployeeState state) {
    return ElevatedButton(
onPressed: state is AddOrEditEmployeeLoading
    ? null
    : () async {
        if (_formKey.currentState!.validate()) {

          final bool isPasswordChanging = _passwordController.text.trim().isNotEmpty;
          String? adminPass;

          if (isPasswordChanging) {
            adminPass = await _showAdminPasswordDialog(context);

            if (adminPass == null || adminPass.isEmpty) return;
          }

context.read<AddOrEditEmployeeCubit>().saveEmployee(
  id: widget.operation?.id,
  firstName: _nameController.text,
  email: _emailController.text,
  phoneNumber: _phoneController.text,
  department: "e-commerce",
  dateOfSubmission: _selectedDate?.toIso8601String() ?? '',
  salary: _salaryController.text,

  password: _passwordController.text.trim().isEmpty
      ? null
      : _passwordController.text.trim(),

  adminPassword: adminPass,
);

        }
      },

      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: state is AddOrEditEmployeeLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              isEdit ? "تعديل الموظف" : "إضافة الموظف",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
    );
  }
}

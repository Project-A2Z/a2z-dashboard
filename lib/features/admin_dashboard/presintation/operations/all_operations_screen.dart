import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/core/widgets/header_admin.dart';
import 'package:disctop_app/core/widgets/pagination_control.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_admin.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/add_or_edit_operation_cubit.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/operations_cubit.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/operations_model.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/operations_stat.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/show_password_cubit.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/show_password_state.dart';
import 'package:disctop_app/features/admin_dashboard/presintation/operations/add_or_edit_operations_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disctop_app/core/app_colors.dart';

class OperationsScreen extends StatefulWidget {
  const OperationsScreen({Key? key}) : super(key: key);

  @override
  State<OperationsScreen> createState() => _OperationsScreenState();
}

class _OperationsScreenState extends State<OperationsScreen> {
  final String selectedKey = "الموظفين";
  String searchQuery = '';

  int rowsPerPage = 7;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    context.read<OperationsCubit>().fetchOperations();
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: DashboardHeader_admin(title: "الموظفين",onRefreshTap: (){
                        context.read<OperationsCubit>().fetchOperations();
                      },),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildSearchField(),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => BlocProvider(
                                      create:
                                          (_) => AddOrEditEmployeeCubit(
                                            context.read<ApiService>(),
                                          ),
                                      child: const AddOrEditEmployeeScreen(),
                                    ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "اضافة موظف",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: BlocBuilder<OperationsCubit, OperationsState>(
                        builder: (context, state) {
                          if (state is OperationsLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }
                          if (state is OperationsError) {
                            return Center(child: Text("خطأ في تحميل الموظفين",style: TextStyle(color: Colors.red,fontSize: 20),));
                          }
                          if (state is OperationsLoaded) {
                            var operations = state.operations.operations;

                            if (searchQuery.isNotEmpty) {
                              if (searchQuery.isNotEmpty) {
                                operations =
                                    operations
                                        .where(
                                          (op) => (op.firstName ?? '')
                                              .toLowerCase()
                                              .contains(
                                                searchQuery.toLowerCase(),
                                              ),
                                        )
                                        .toList();
                              }
                            }

                            if (operations.isEmpty) {
                              return const Center(
                                child: Text(
                                  "لا يوجد موظفين",
                                  style: TextStyle(
                                    color: AppColors.black60,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }

                            int totalPages =
                                (operations.length / rowsPerPage).ceil();
                            totalPages = totalPages == 0 ? 1 : totalPages;

                            if (currentPage < 1) currentPage = 1;
                            if (currentPage > totalPages) {
                              currentPage = totalPages;
                            }

                            int startIndex = (currentPage - 1) * rowsPerPage;
                            int endIndex = startIndex + rowsPerPage;
                            if (endIndex > operations.length) {
                              endIndex = operations.length;
                            }

                            var currentPageItems = operations.sublist(
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
                                  totalItems: operations.length,
                                  displayedStart: startIndex + 1,
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

  Widget _buildDataTable(List<Operation> operations) {
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
          child: DataTable(
            headingRowHeight: 56,
            dataRowHeight: 64,
            columnSpacing: 20,
            headingRowColor: MaterialStateProperty.all(AppColors.primary),
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
                  child: Center(
                    child: Text("الاسم", textAlign: TextAlign.center),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Center(
                    child: Text("رقم الهاتف", textAlign: TextAlign.center),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Center(
                    child: Text(
                      "البريد الالكتروني",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Center(
                    child: Text("كلمة المرور", textAlign: TextAlign.center),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Center(
                    child: Text("المرتب", textAlign: TextAlign.center),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Center(
                    child: Text("تاريخ التعيين", textAlign: TextAlign.center),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Center(
                    child: Text(
                      'المزيد',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            rows:
                operations.map((op) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Center(
                          child: Text(
                            op.firstName ?? "غير موجود",
                            style: TextStyle(
                              color: AppColors.black60,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(
                            op.phoneNumber ?? "غير موجود",
                            style: TextStyle(
                              color: AppColors.black60,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(
                            op.email ?? "غير موجود",
                            style: TextStyle(
                              color: AppColors.black60,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BlocProvider(
                                create:
                                    (context) => ShowPasswordCubit(
                                      context.read<ApiService>(),
                                    ),
                                child: BlocBuilder<
                                  ShowPasswordCubit,
                                  ShowPasswordState
                                >(
                                  builder: (context, passState) {
                                    String hiddenPassword = "**********";

                                    if (passState is ShowPasswordSuccess) {
                                      hiddenPassword = passState.password;
                                    }

                                    return Row(
                                      children: [
                                        Text(
                                          hiddenPassword,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.visibility_outlined,
                                          ),
                                          onPressed: () async {
                                            final cubit =
                                                context
                                                    .read<ShowPasswordCubit>();

                                            if (cubit.isVisible) {
                                              cubit.togglePassword(
                                                email: op.email ?? '',
                                                adminPassword: '',
                                              );
                                            } else {
                                              final adminPassword =
                                                  await _showAdminPasswordDialog(
                                                    context,
                                                  );
                                              if (adminPassword != null &&
                                                  adminPassword.isNotEmpty) {
                                                cubit.togglePassword(
                                                  email: op.email ?? '',
                                                  adminPassword: adminPassword,
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      DataCell(
                        Center(
                          child: Text(
                            "${op.salary ?? "غير موجود"}",
                            style: TextStyle(
                              color: AppColors.black60,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(
                            op.dateOfSubmission?.substring(0, 10) ??
                                "غير موجود",
                            style: TextStyle(
                              color: AppColors.black60,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: PopupMenuButton<String>(
                            offset: Offset(20, 20),
                            color: AppColors.background,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                                topLeft: Radius.zero,
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            itemBuilder:
                                (context) => [
                                  PopupMenuItem<String>(
                                    value: 'تعديل',
                                    child: Center(
                                      child: Text(
                                        'تعديل',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                          color: AppColors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                            onSelected: (value) {
                              if (value == 'تعديل') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => BlocProvider(
                                          create:
                                              (_) => AddOrEditEmployeeCubit(
                                                context.read<ApiService>(),
                                              ),
                                          child: AddOrEditEmployeeScreen(
                                            operation: op,
                                          ),
                                        ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
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
        onChanged: (v) {
          setState(() {
            searchQuery = v;
            currentPage = 1;
          });
        },
      ),
    );
  }
}

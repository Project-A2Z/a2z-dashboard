import 'package:disctop_app/core/widgets/bar_chart_admin_control.dart';
import 'package:disctop_app/core/widgets/header_admin.dart';
import 'package:disctop_app/core/widgets/line_chart_admin_control.dart';
import 'package:disctop_app/core/widgets/pie_chart_admin_control.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_admin.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/control_cubit/control_cubit.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/control_cubit/control_state.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/customers_cubit/Customers_state.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/customers_cubit/customers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/core/widgets/custom_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedKey = "لوحة التحكم";

  @override
  void initState() {
    super.initState();
    context.read<ProfitCubit>().fetchProfits();
    context.read<CustomersCubit>().fetchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Row(
            children: [
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(width * 0.015),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      
                     BlocBuilder<ProfitCubit, ProfitState>(
  builder: (context, profitState) {
    return BlocBuilder<CustomersCubit, CustomersState>(
      buildWhen: (p, c) => c is CustomersLoaded,
      builder: (context, customersState) {

                              if (profitState is ProfitLoading ||
                                  customersState is CustomersLoading) {
                                return const Center(child: CircularProgressIndicator(color: AppColors.primary,));
                              } else if (profitState is ProfitLoaded &&
                                  customersState is CustomersLoaded) {
                                final data = profitState.profitData;
                                final customersData = customersState.customersData;

                                return Column(
                                  children: [
                                                         DashboardHeader_admin(title: "لوحة التحكم",onRefreshTap: (){
                                                          context.read<ProfitCubit>().fetchProfits();
                                                         },),
                      SizedBox(height: height * 0.03),

                                    Row(
                                      children: [
                                        
                                        Expanded(
                                          child: CustomCard(
                                            title: "عدد العملاء",
                                            value: customersData.totalCustomers.toString(),
                                            icon: Icons.person,
                                            iconColor: AppColors.star,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                    
                                        
                                        Expanded(
                                          child: CustomCard(
                                            title: "عدد الموظفين",
                                            value: data.totalOperations.toString(),
                                            icon: Icons.people_outline,
                                            iconColor: AppColors.secondary1,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                    
                                        
                                        Expanded(
                                          child: CustomCard(
                                            title: "الأرباح",
                                            value: data.totalProfit.toString(),
                                            icon: Icons.trending_up,
                                            iconColor: AppColors.error,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                    
                                        
                                        Expanded(
                                          child: CustomCard(
                                            title: "المصروفات",
                                            value: data.expenses.totalAmount.toString(),
                                            icon: Icons.trending_down,
                                            iconColor: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                    
                                        
                                        Expanded(
                                          child: CustomCard(
                                            title: "الإيرادات",
                                            value: data.revenues.totalAmount.toString(),
                                            icon: Icons.money,
                                            iconColor: AppColors.secondary1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              } else if (profitState is ProfitError) {
                                return ElevatedButton(
          onPressed: () {
            context.read<ProfitCubit>().fetchProfits();
          },
          child: const Text("إعادة المحاولة"));
                              } else if (customersState is CustomersError) {
                                return Center(child: Text(""));
                              }
                              return const SizedBox.shrink();
                            },
                          );
                        },
                      ),

                      SizedBox(height: height * 0.04),

                      
                      BlocBuilder<ProfitCubit, ProfitState>(
                        builder: (context, profitState) {
                          return BlocBuilder<CustomersCubit, CustomersState>(
                            builder: (context, customersState) {
                              if (profitState is ProfitLoaded &&
                                  customersState is CustomersLoaded) {
                                final profitData = profitState.profitData;
                                final customerData = customersState.customersData;

                                final monthlyStats = profitData.monthlyStatistics.length > 12
    ? profitData.monthlyStatistics.sublist(
        profitData.monthlyStatistics.length - 12,
      )
    : profitData.monthlyStatistics;
                                final spotsRevenue = monthlyStats
                                    .asMap()
                                    .entries
                                    .map((e) => FlSpot(e.key.toDouble(),
                                        e.value.revenues.toDouble()))
                                    .toList();
                                final spotsExpenses = monthlyStats
                                    .asMap()
                                    .entries
                                    .map((e) => FlSpot(e.key.toDouble(),
                                        e.value.expenses.toDouble()))
                                    .toList();

                                
                                final yearlyStats = profitData.yearlyStatistics;

                                
                                final customerStats = customerData.yearlyStatistics;

                                return Column(
                                  children: [
                                    LineChartWidget(
  height: height,
  title: "الإيرادات والمصروفات",
  revenues: spotsRevenue,
  expenses: spotsExpenses,
  monthNames: monthlyStats.map((e) => e.monthName).toList(),
),


                                    SizedBox(height: height * 0.03),

                                    
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: BarChartAdminControl(
  height: height,
  title: "الأرباح في آخر سنوات",
  yearlyStats: yearlyStats,
),

                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child:PieChartAdminControl(
  height: height,
  title: "عدد العملاء في اخر سنتين",
  customerStats: customerStats,
),

                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              
              Sidebar_Admin(selectedKey: selectedKey),
            ],
          );
        },
      ),
    );
  }
}

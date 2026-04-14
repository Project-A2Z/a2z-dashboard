
import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/core/widgets/header_admin.dart';
import 'package:disctop_app/core/widgets/line_chart.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_admin.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/customers_cubit/Customers_state.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/customers_cubit/customers_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});
  final selectedKey = "العملاء";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          
          

          
          Expanded(
            child: BlocBuilder<CustomersCubit,CustomersState>(
              builder: (context, state) {
                if (state is CustomersLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary,));
                } else if (state is CustomersError) {
                  return Center(child: Text("خطأ في تحميل العملاء",style: TextStyle(color: Colors.red,fontSize: 20),));
                } else if (state is CustomersLoaded) {
                  final data = state.customersData;

                  
                  final monthlyStats = data.monthlyStatistics.length > 12
                      ? data.monthlyStatistics
                          .sublist(data.monthlyStatistics.length - 12)
                      : data.monthlyStatistics;

                  final monthlySpots = monthlyStats
                      .asMap()
                      .entries
                      .map((e) =>
                          FlSpot(e.key.toDouble(), e.value.count.toDouble()))
                      .toList();

                  final monthLabels =
                      monthlyStats.map((e) => e.monthName).toList();


                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      child: Column(
                        
                        children: [
                          Directionality(
                                  textDirection: TextDirection.ltr,
                                  child:
                                      DashboardHeader_admin(title: "العملاء",onRefreshTap: (){
                                        context.read<CustomersCubit>().fetchCustomers();
                                      },),
                                ),
                          Container(
                            padding: EdgeInsets.all(20),
                            margin: EdgeInsets.only(top: 20),
                            decoration: BoxDecoration(
                          color: AppColors.background,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.black8),
                        ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                
                                
                               Row(
                                
                                 children: [
 
                                                                      Flexible(
                                     child: Container(
                                      width: 660,
                                      height: 200,
                                        decoration: BoxDecoration(
                                                               color: AppColors.background,
                                           borderRadius: BorderRadius.circular(24),
                                           border: Border.all(color: AppColors.black8),
                                                             ),
                                                             child: Center(
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  CircleAvatar(
                                                                                        backgroundColor: Colors.amber.withOpacity(0.15),
                                                                                        radius: 25,
                                                                                        child: Icon(Icons.people, color: Colors.amber, size: 20),
                                                                                      ),
                                                                SizedBox(height: 10,),
                    Text(
                    
                    "${data.totalCustomers}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "عدد الزوار",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    ],
                                                              ),
                                                             ),
                                                             
                                     ),
                                   ),
                                   SizedBox(width: 20,),
                                   Flexible(
                                     child: Container(
                                      width: 660,
                                      height: 200,
                                        decoration: BoxDecoration(
                                                               color: AppColors.background,
                                           borderRadius: BorderRadius.circular(24),
                                           border: Border.all(color: AppColors.black8),
                                                             ),
                                                             child: Center(
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  CircleAvatar(
                                                                                        backgroundColor: Colors.amber.withOpacity(0.15),
                                                                                        radius: 25,
                                                                                        child: Icon(Icons.person, color: Colors.amber, size: 20),
                                                                                      ),
                                                                SizedBox(height: 10,),
                    Text(
                    
                    "${data.totalCustomers}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "عدد العملاء المسجلين",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    ],
                                                              ),
                                                             ),
                                                             
                                     ),
                                   ),
                                  
                                 ],
                               ),
                               SizedBox(height: 20,),
                            LineChartWidget(
  title: "عدد العملاء",
  spots: monthlySpots,
  labels: monthLabels,
),

                                const SizedBox(height: 40),
                            
                                
                                
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          Sidebar_Admin(selectedKey: selectedKey),
        ],
        
      ),
    );
  }
}
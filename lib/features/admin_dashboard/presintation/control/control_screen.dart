import 'package:disctop_app/core/widgets/header_admin.dart';
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
                                                         DashboardHeader_admin(title: "لوحة التحكم"),
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
                                return Center(child: Text(profitState.message));
                              } else if (customersState is CustomersError) {
                                return Center(child: Text(customersState.message));
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
                                    _buildLineChart(
  height,
  "الإيرادات والمصروفات",
  spotsRevenue,
  spotsExpenses,
  monthlyStats.map((e) => e.monthName).toList(), 
),

                                    SizedBox(height: height * 0.03),

                                    
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _buildBarChart(
                                            height,
                                            "الأرباح في آخر سنوات",
                                            yearlyStats,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildPieChart(
                                            height,
                                            "عدد العملاء في اخر سنتين",
                                            customerStats,
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

Widget _buildLineChart(
  double height,
  String title,
  List<FlSpot> revenues,
  List<FlSpot> expenses,
  List<String> monthNames, 
) {
  return Container(
    height: height * 0.45,
    padding: const EdgeInsets.all(16),
    decoration: _chartBox(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        
        Expanded(
          child: LineChart(
            LineChartData(
              minY: 0,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false, 
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.2), 
                  strokeWidth: 1,
                  dashArray: [4,4],

                  
                ),
              ), 
              borderData: FlBorderData(show: false), 

              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                ),

                
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < monthNames.length) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 6,
                          child: Text(
                            monthNames[index],
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

              
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  spots: revenues,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.secondary1,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.25),
                        AppColors.secondary1.withOpacity(0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  dotData: FlDotData(show: true),
                ),
                LineChartBarData(
                  isCurved: true,
                  spots: expenses,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.error,
                      AppColors.star,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromRGBO(253, 253, 253, 1),
                        const Color.fromRGBO(165, 201, 161, 1),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}



Widget _buildBarChart(double height, String title, List<dynamic> yearlyStats) {
  return Container(
    height: height * 0.45,
    padding: const EdgeInsets.all(16),
    decoration: _chartBox(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceEvenly,
              borderData: FlBorderData(show: false),

              
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false, 
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.2), 
                  strokeWidth: 1,
                  dashArray: [4,4]
                  
                ),
              ),

              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final year = yearlyStats
                          .firstWhere(
                            (e) => e.year.toDouble() == value,
                           
                          )
                          .year;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          year.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black87,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              
              barGroups: yearlyStats
                  .map(
                    (e) => BarChartGroupData(
                      x: e.year.toInt(),
                      barRods: [
                        BarChartRodData(
                          toY: e.profit.toDouble(),
                          
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                            Color.fromRGBO(253, 253, 253, 1),
                              Color.fromRGBO(165, 201, 161, 1),
                            ],
                          ),
                          width: 80,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                  )
                  .toList(),

              
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
               
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final year = yearlyStats[groupIndex].year;
                    final profit = yearlyStats[groupIndex].profit;
                    return BarTooltipItem(
                      'السنة: $year\nالربح: ${profit.toStringAsFixed(0)}',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  
Widget _buildPieChart(double height, String title, List<dynamic> customerStats) {

  
  final colors = [
    AppColors.primary,
    AppColors.error,
    AppColors.star,
    AppColors.secondary1,
  ];
    final total = customerStats.fold<double>(
      0, (sum, item) => sum + (item.count?.toDouble() ?? 0));

  
  final sortedStats = [...customerStats];
  sortedStats.sort((a, b) => (b.count ?? 0).compareTo(a.count ?? 0));

  final Map<int, Color> yearColors = {};
  for (int i = 0; i < sortedStats.length; i++) {
    final e = sortedStats[i];
    yearColors[e.year] = colors[i % colors.length];
  }

  return Container(
    height: height * 0.45,
    padding: const EdgeInsets.all(16),
    decoration: _chartBox(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        Expanded(
          child: Column(
  
            children: [
              
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 90,
                    sections: customerStats.asMap().entries.map((entry) {
                      
                      final e = entry.value;
                      final color = yearColors[e.year]!;
                      final value = e.count?.toDouble() ?? 0;
                      final percent = total == 0 ? 0 : (value / total * 100);

                      return PieChartSectionData(
                        value: value,
                        color: color,
                        title:
                            "${percent.toStringAsFixed(0)}%", 
                        radius: 40,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              
              Expanded(
                flex: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: customerStats.asMap().entries.map((entry) {
                    
                    final e = entry.value;
                    final color =  yearColors[e.year]!;
                
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                           Text(
                            "${e.year}",
                            style: const TextStyle(fontSize: 14),
                          ),
                           const SizedBox(width: 8),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                         
                         
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  
  BoxDecoration _chartBox() {
    return BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(24),
     border: Border.all(
      
      color: AppColors.black8
     )
    );
  }
}

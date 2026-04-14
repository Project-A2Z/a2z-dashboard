import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/core/widgets/header_admin.dart';
import 'package:disctop_app/core/widgets/line_chart.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_admin.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/control_cubit/control_cubit.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/control_cubit/control_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfitsScreen extends StatelessWidget {
  const ProfitsScreen({super.key});
  final selectedKey = "الأرباح";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Expanded(
            child: BlocBuilder<ProfitCubit, ProfitState>(
              builder: (context, state) {
                if (state is ProfitLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary,));
                } else if (state is ProfitError) {
                  return Center(child: Text("خطأ في تحميل الارباح",style: TextStyle(color: Colors.red,fontSize: 20),));
                } else if (state is ProfitLoaded) {
                  final data = state.profitData;

                  final monthlyStats =
                      data.monthlyStatistics.length > 12
                          ? data.monthlyStatistics.sublist(
                            data.monthlyStatistics.length - 12,
                          )
                          : data.monthlyStatistics;

                  final monthlySpots =
                      monthlyStats
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value.profit.toDouble(),
                            ),
                          )
                          .toList();

                  final monthLabels =
                      monthlyStats.map((e) => e.monthName).toList();

                  final yearlyStats = data.yearlyStatistics;

                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        children: [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: DashboardHeader_admin(title: "الأرباح",onRefreshTap: (){
                              context.read<ProfitCubit>().fetchProfits();
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
                                Text(
                                  "${data.totalProfit.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "اجمالي الارباح",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.black60,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 28),

                                LineChartWidget(
                                  title: "الأرباح الشهرية",
                                  spots: monthlySpots,
                                  labels: monthLabels,
                                ),

                                const SizedBox(height: 40),

                                _buildBarChart("الأرباح السنوية", yearlyStats),
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

  Widget _buildBarChart(String title, List<dynamic> yearlyStats) {
    return Container(
      width: double.infinity,
      height: 320,
      padding: const EdgeInsets.all(20),
      decoration: _chartBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine:
                      (value) => FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget:
                          (value, meta) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black87,
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
                        final match =
                            yearlyStats
                                .firstWhere((e) => e.year.toDouble() == value)
                                .year;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            match.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black87,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups:
                    yearlyStats
                        .map(
                          (e) => BarChartGroupData(
                            x: e.year.toInt(),
                            barRods: [
                              BarChartRodData(
                                toY: e.profit.toDouble(),
                                gradient: const LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Color.fromRGBO(253, 253, 253, 1),
                                    Color.fromRGBO(165, 201, 161, 1),
                                  ],
                                ),
                                width: 60,
                                borderRadius: BorderRadius.circular(6),
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

  BoxDecoration _chartBox() {
    return BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.black8),
    );
  }
}

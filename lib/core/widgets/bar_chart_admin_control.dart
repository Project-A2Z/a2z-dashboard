import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:disctop_app/core/app_colors.dart';

class BarChartAdminControl extends StatelessWidget {
  final double height;
  final String title;
  final List<dynamic> yearlyStats;

  const BarChartAdminControl({
    super.key,
    required this.height,
    required this.title,
    required this.yearlyStats,
  });

  @override
  Widget build(BuildContext context) {
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
                    dashArray: [4, 4],
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
                            .firstWhere((e) => e.year.toDouble() == value)
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
                            gradient: const LinearGradient(
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

  BoxDecoration _chartBox() {
    return BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.black8),
    );
  }
}

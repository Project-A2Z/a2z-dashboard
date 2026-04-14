import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:disctop_app/core/app_colors.dart';

class LineChartWidget extends StatelessWidget {
  final double height;
  final String title;
  final List<FlSpot> revenues;
  final List<FlSpot> expenses;
  final List<String> monthNames;

  const LineChartWidget({
    super.key,
    required this.height,
    required this.title,
    required this.revenues,
    required this.expenses,
    required this.monthNames,
  });

  @override
  Widget build(BuildContext context) {
    final allValues = [...revenues, ...expenses];
    final minYValue = allValues.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxYValue = allValues.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final yPadding = (maxYValue - minYValue).abs() * 0.1;

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
            child: LineChart(
              LineChartData(
                minY: minYValue - yPadding,
                maxY: maxYValue + yPadding,
                minX: 0,
                maxX: monthNames.length.toDouble() - 1,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.25),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: ((maxYValue - minYValue) / 4).abs(),
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
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
                      colors: [AppColors.primary, AppColors.secondary1],
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
                      colors: [AppColors.error, AppColors.star],
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

  BoxDecoration _chartBox() {
    return BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.black8),
    );
  }
}

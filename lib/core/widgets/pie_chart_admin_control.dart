import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:disctop_app/core/app_colors.dart';

class PieChartAdminControl extends StatelessWidget {
  final double height;
  final String title;
  final List<dynamic> customerStats;

  const PieChartAdminControl({
    super.key,
    required this.height,
    required this.title,
    required this.customerStats,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.primary,
      AppColors.error,
      AppColors.star,
      AppColors.secondary1,
    ];

    final total = customerStats.fold<double>(
      0,
      (sum, item) => sum + (item.count?.toDouble() ?? 0),
    );

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
                      sections: customerStats.map((e) {
                        final color = yearColors[e.year]!;
                        final value = e.count?.toDouble() ?? 0;
                        final percent = total == 0 ? 0 : (value / total * 100);

                        return PieChartSectionData(
                          value: value,
                          color: color,
                          title: "${percent.toStringAsFixed(0)}%",
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: customerStats.map((e) {
                      final color = yearColors[e.year]!;

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
      border: Border.all(color: AppColors.black8),
    );
  }
}

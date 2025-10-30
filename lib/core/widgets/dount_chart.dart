import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:disctop_app/core/app_colors.dart';

class PaymentMethodsChart extends StatelessWidget {
  final int cashPercent;
  final int onlinePercent;

  const PaymentMethodsChart({
    super.key,
    required this.cashPercent,
    required this.onlinePercent,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final chartWidth = width * 0.6; 

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.black8),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              "طرق الدفع",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black87,
              ),
            ),
          ),
          const SizedBox(height: 20),

          
          SizedBox(
            height: 250,
            width: chartWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                
                ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 1,
                    child: SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          startDegreeOffset: 90,
                          sectionsSpace: 1,
                          centerSpaceRadius: 70,
                          borderData: FlBorderData(show: false),
                          sections: [
                            PieChartSectionData(
                              value: cashPercent.toDouble(),
                              color: AppColors.primary,
                              radius: 50,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: onlinePercent.toDouble(),
                              color: AppColors.error,
                              radius: 50,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                
                

                
                Positioned(
                  right: chartWidth * 0.25,
                  top: 60,
                  child:Text(
                    "${((onlinePercent / (onlinePercent + cashPercent)) * 100).toInt()}%",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF757575),
                    ),
                  ),
                ),
                Positioned(
                  left: chartWidth * 0.25, 
                  top: 50,
                  child:  Text(
                    "${((cashPercent / (onlinePercent + cashPercent)) * 100).toInt()}%",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF757575),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem("كاش", const Color(0xFF66BB6A)),
              const SizedBox(width: 24),
              _legendItem("أونلاين", const Color(0xFFEF5350)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.black87,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

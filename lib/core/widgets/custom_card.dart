import 'package:disctop_app/core/app_colors.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const CustomCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;

        // 🔹 أحجام متغيرة حسب العرض
        double iconSize = width > 200 ? 28 : 22;
        double radius = width > 200 ? 24 : 18;
        double valueFont = width > 200 ? 20 : 14;
        double titleFont = width > 200 ? 14 : 11;


        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: 
               Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: iconColor.withOpacity(0.15),
                      radius: radius,
                      child: Icon(icon, color: iconColor, size: iconSize),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: valueFont,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFont,
                        color: AppColors.black60,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              
                    
              
        );
      },
    );
  }
}

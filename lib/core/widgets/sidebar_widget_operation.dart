import 'package:flutter/material.dart';
import 'package:disctop_app/core/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sidebar_Operation extends StatefulWidget {
  final String selectedKey;

  const Sidebar_Operation({super.key, required this.selectedKey});

  @override
  State<Sidebar_Operation> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar_Operation> {
  bool isExpanded = false;

  final Map<String, String> routesMap = {
    "المنتجات": "/products",
    "الطلبات": "/orders",
    "التعاملات المالية": "/payment",
    "التعليقات و المراجعات": "/review",
    "التواصل": "/connect",
    "تسجيل الخروج": "/login",
  };

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final collapsedWidth = screenWidth < 600 ? 60.0 : 80.0;
    final expandedWidth = screenWidth < 600 ? 180.0 : 220.0;
    final logoHeight = screenHeight < 600 ? 40.0 : 60.0;
    final marginValue = screenHeight < 600 ? 8.0 : 12.0;
    final itemPadding = screenHeight < 600 ? 10.0 : 13.0;

    return MouseRegion(
      onEnter: (_) => setState(() => isExpanded = true),
      onExit: (_) => setState(() => isExpanded = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.all(marginValue),
        width: isExpanded ? expandedWidth : collapsedWidth,
        height: double.infinity,        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // ✅ اللوجو
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight < 600 ? 8.0 : 16.0,
                ),
                child: SizedBox(
                  height: logoHeight,
                  child: Image.asset(
                    "assets/images/logo.png",
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported,
                        size: logoHeight * 0.8,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),

              Divider(color: Colors.grey.shade300, thickness: 1, height: 1),

              // ✅ القائمة
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenHeight < 600 ? 8.0 : 12.0,
                      vertical: screenHeight < 600 ? 8.0 : 12.0,
                    ),
                    children: [
                      _buildMenuItem("assets/images/shopping.png", "المنتجات",
                          itemPadding, screenHeight),
                      _buildMenuItem("assets/images/order.png", "الطلبات",
                          itemPadding, screenHeight),
                      _buildMenuItem("assets/images/moeny.png",
                          "التعاملات المالية", itemPadding, screenHeight),
                      _buildMenuItem("assets/images/notes.png",
                          "التعليقات و المراجعات", itemPadding, screenHeight),
                      _buildMenuItem("assets/images/inquery.png", "التواصل",
                          itemPadding, screenHeight),
                    ],
                  ),
                ),
              ),

              Divider(color: Colors.grey.shade300, thickness: 1, height: 1),

              // ✅ تسجيل الخروج في الأسفل
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenHeight < 600 ? 8.0 : 12.0,
                  vertical: screenHeight < 600 ? 10.0 : 16.0,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Center(
                    child: _buildMenuItem("assets/images/log_out.png",
                        "تسجيل الخروج", itemPadding, screenHeight),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String image,
    String key,
    double padding,
    double screenHeight, {
    Color color = AppColors.black87,
  }) {
    final bool isSelected = widget.selectedKey == key;
    final fontSize = screenHeight < 600 ? 14.0 : 16.0;
    final iconSize = screenHeight < 600 ? 20.0 : 24.0;

    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight < 600 ? 4.0 : 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () async {
          if (key == "تسجيل الخروج") {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            if (mounted) {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("/login", (route) => false);
            }
            return;
          }

          final route = routesMap[key];
          if (route != null && route.isNotEmpty) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: padding, horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: Image.asset(
                    image,
                    color: isSelected ? Colors.white : AppColors.black87,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 5,),
              if (isExpanded)
                Flexible(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Text(
                      key,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

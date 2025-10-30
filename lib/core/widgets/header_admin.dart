import 'package:disctop_app/core/widgets/user_healper.dart';
import 'package:flutter/material.dart';
import 'package:disctop_app/core/app_colors.dart';

class DashboardHeader_admin extends StatefulWidget {
  final String? userName; // خليها اختيارية
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onRefreshTap;
  final bool hasNotifications;

  const DashboardHeader_admin({
    super.key,
    this.userName,
    required this.title,
    this.onNotificationTap,
    this.onRefreshTap,
    this.hasNotifications = true,
  });

  @override
  State<DashboardHeader_admin> createState() => _DashboardHeader_adminState();
}

class _DashboardHeader_adminState extends State<DashboardHeader_admin> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    _initUserName();
  }

  Future<void> _initUserName() async {
    if (widget.userName != null && widget.userName!.isNotEmpty) {
      userName = widget.userName!;
    } else {
      userName = await UserHelper.loadUserName();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primary,
              child: Text(
                userName.trim().isNotEmpty
                    ? userName.trim().substring(0, 1).toUpperCase()
                    : "?",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),

            
           
          ],
        ),
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.black87,
          ),
        ),
      ],
    );
  }
}

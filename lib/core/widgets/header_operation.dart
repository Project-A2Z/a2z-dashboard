import 'package:disctop_app/core/widgets/user_healper.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/notification_cubit/notification_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/notification_cubit/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disctop_app/core/app_colors.dart';

class DashboardHeader extends StatefulWidget {
  final String? userName;
  final String title;
  final VoidCallback? onRefreshTap;
  final bool hasNotifications;

  const DashboardHeader({
    super.key,
    this.userName,
    required this.title,
    this.onRefreshTap,
    this.hasNotifications = true,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  String userName = '';
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

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

void _toggleNotifications() async {
  if (_overlayEntry != null) {
    _removeOverlay();
  } else {
    final cubit = context.read<OperationNotificationCubit>();

    
    if (cubit.state is! OperationNotificationLoaded) {
      cubit.loadNotifications();
    }

    
    _showOverlay();

    
    Future.delayed(const Duration(milliseconds: 300), () {
      cubit.loadNotifications();
    });
  }
}


void _showOverlay() {
  final overlay = Overlay.of(context);
  final renderBox = context.findRenderObject() as RenderBox;
  final offset = renderBox.localToGlobal(Offset.zero);

  _overlayEntry = OverlayEntry(
    builder: (context) {
      return Stack(
        children: [
          
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              behavior: HitTestBehavior.translucent,
            ),
          ),

          Positioned(
            top: offset.dy + 60,
            right: 20,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: CompositedTransformFollower(
                link: _layerLink,
                offset: const Offset(0, 40),
                showWhenUnlinked: false,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 330,
                    constraints: const BoxConstraints(maxHeight: 400),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BlocBuilder<OperationNotificationCubit, OperationNotificationState>(
                        builder: (context, state) {
                          if (state is OperationNotificationLoading) {
                            
                            return ListView.builder(
                              itemCount: 4,
                              itemBuilder: (_, __) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            width: 120,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (state is OperationNotificationLoaded) {
                            if (state.notifications.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  "لا يوجد إشعارات جديدة 🔔",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 15, color: Colors.grey),
                                ),
                              );
                            }

                            final months = [
                              'يناير',
                              'فبراير',
                              'مارس',
                              'أبريل',
                              'مايو',
                              'يونيو',
                              'يوليو',
                              'أغسطس',
                              'سبتمبر',
                              'أكتوبر',
                              'نوفمبر',
                              'ديسمبر'
                            ];

                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              itemCount: state.notifications.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: Colors.grey.shade200,
                              ),
                              itemBuilder: (context, index) {
                                final n = state.notifications[index];
                                final createdAt = n.createdAt;
                                final formattedTime =
                                    "${createdAt.day} ${months[createdAt.month - 1]}";

                                return ListTile(
                                  leading: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.notifications,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    n.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: AppColors.black87,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      n.message,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  trailing: Text(
                                    formattedTime,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                );
                              },
                            );
                          } else if (state is OperationNotificationError) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "حدث خطأ",
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  overlay.insert(_overlayEntry!);
}

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
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
            CompositedTransformTarget(
              link: _layerLink,
              child: GestureDetector(
                onTap: _toggleNotifications,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset("assets/images/Cart Large 4.png", width: 25,height: 35,),
                    if (widget.hasNotifications)
                      const Positioned(
                        top: 2,
                        right: 3,
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: widget.onRefreshTap ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("جارٍ التحديث..."),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
              label: const Row(
                children: [
                  Text(
                    "تحديث",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.refresh_rounded, color: AppColors.primary),
                ],
              ),
            ),
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

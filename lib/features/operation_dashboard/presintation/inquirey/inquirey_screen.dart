import 'package:disctop_app/core/widgets/filter_button_row.dart';
import 'package:disctop_app/core/widgets/header_operation.dart';
import 'package:disctop_app/core/widgets/pagination_control.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/inquirey_cubit/inquirey_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/inquirey_cubit/inquirey_state.dart';
import 'package:disctop_app/features/operation_dashboard/presintation/inquirey/inquirey_reply_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_operation.dart';

class InquiriesScreen extends StatefulWidget {
  const InquiriesScreen({Key? key}) : super(key: key);

  @override
  State<InquiriesScreen> createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends State<InquiriesScreen> {
  String filter = "الكل";
  int currentPage = 0;
  final int itemsPerPage = 7;

  @override
  void initState() {
    super.initState();
    context.read<InquiryCubit>().fetchInquiries();
  }

  String formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return DateFormat('yyyy-MM-dd').format(d);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    const selectedKey = "التواصل";
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  DashboardHeader(title: "التواصل",onRefreshTap: () {
                    setState(() {
                      currentPage = 0;
                    });
   
    context.read<InquiryCubit>().fetchInquiries();
  } ,),
                  const SizedBox(height: 16),
      
                  
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: FilterButtonsRow(
  filters: ["الكل", "تحت المراجعة", "تم الرد"],
  selectedFilter: filter,
  onFilterChanged: (newFilter) {
    setState(() {
      filter = newFilter;
      currentPage = 0;
    });
  },
),

                  ),
                  const SizedBox(height: 16),
      
                  
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Expanded(
                      child: BlocBuilder<InquiryCubit, InquiryState>(
                        builder: (context, state) {
                          if (state is InquiryLoading) {
                            return const Center(child: CircularProgressIndicator(color: AppColors.primary,));
                          }
                          if (state is InquiryError) {
                            return Center(child: Text('خطأ في تحميل الرسائل',style: TextStyle(color: Colors.red,fontSize: 20),));
                          }
                          if (state is InquiriesLoaded) {
                            var list = state.inquiries;
                            
                            
                            if (filter == "تم الرد") {
                              list = list.where((inq) => inq.reply != null && inq.reply!.isNotEmpty).toList();
                            } else if (filter == "تحت المراجعة") {
                              list = list.where((inq) => inq.reply == null || inq.reply!.isEmpty).toList();
                            } 
                          
                            if (list.isEmpty) {
                              return  Center(child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/messages.png"),
                                  Text('لا يوجد رسائل بعد'),
                                ],
                              ));
                            }

                            
                            final totalPages = (list.length / itemsPerPage).ceil();
                            
                            
                            if (currentPage >= totalPages) {
                              currentPage = totalPages - 1;
                            }
                            if (currentPage < 0) {
                              currentPage = 0;
                            }

                            
                            final startIndex = currentPage * itemsPerPage;
                            final endIndex = (startIndex + itemsPerPage > list.length) 
                                ? list.length 
                                : startIndex + itemsPerPage;
                            final paginatedList = list.sublist(startIndex, endIndex);
                            
                            return Column(
                              children: [
                                
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      color: Colors.white,
                                      width: double.infinity,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: DataTable(
                                          headingRowColor: MaterialStateProperty.all(AppColors.primary),
                                          headingTextStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          dataRowHeight: 70,
                                          columnSpacing: 40,
                                          columns: const [
                                            DataColumn(
                                              label: Expanded(
                                                child: Center(
                                                  child: Text('العميل', textAlign: TextAlign.center, style: TextStyle(color: AppColors.onPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Expanded(
                                                child: Center(
                                                  child: Text('الرسالة', textAlign: TextAlign.center, style: TextStyle(color: AppColors.onPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Expanded(
                                                child: Center(
                                                  child: Text('الحالة', textAlign: TextAlign.center, style: TextStyle(color: AppColors.onPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Expanded(
                                                child: Center(
                                                  child: Text('المزيد', textAlign: TextAlign.center, style: TextStyle(color: AppColors.onPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                                                ),
                                              ),
                                            ),
                                          ],
                                          rows: paginatedList.map((inq) {
                                            final userName = inq.name.isNotEmpty ? inq.name : 'عميل';
                                            final shortMsg = inq.description.length > 80
                                                ? (inq.description.substring(0, 80) + '...')
                                                : inq.description;
                                            final hasReply = (inq.reply != null && inq.reply!.isNotEmpty);

                                            return DataRow(
                                              cells: [
                                                DataCell(Center(child: Text(userName, style: TextStyle(color: AppColors.black60, fontSize: 16, fontWeight: FontWeight.w600)))),
                                                DataCell(
                                                  Center(
                                                    child: SizedBox(
                                                      width: 250,
                                                      child: Text(
                                                        shortMsg,
                                                        overflow: TextOverflow.ellipsis,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(color: AppColors.black60, fontSize: 16, fontWeight: FontWeight.w600),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                      child: Text(
                                                        _getStatusText(hasReply ? "تم الرد" : "تحت المراجعة"),
                                                        style: TextStyle(
                                                          color: _getStatusColor(hasReply ? "تم الرد" : "تحت المراجعة"),
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Center(
                                                    child: PopupMenuButton<String>(
                                                      offset: Offset(20,20),
                                                     color: AppColors.background,
                                                     shape: const RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    topRight: Radius.circular(12),
    bottomRight: Radius.circular(12),
    topLeft: Radius.zero,
    bottomLeft: Radius.circular(12),
  ),
),
                                                      itemBuilder: (context) => [
                                                        PopupMenuItem<String>(
                                                          value: 'reply',
                                                          child: Center(
                                                            child: Text(
                                                              'رد',
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 18,
                                                                color: AppColors.black87
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        
                                                     
                                                      ],
                                                      onSelected: (value) {
                                                        if (value == 'reply') {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) => BlocProvider.value(
                                                                value: context.read<InquiryCubit>(),
                                                                child: InquiryDetailScreen(inquiry: inq),
                                                              ),
                                                            ),
                                                          );
                                                        } 
                                                        
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                
                             PaginationControls(
  currentPage: currentPage,
  totalPages: totalPages,
  totalItems: list.length,
  displayedStart: startIndex + 1,
  displayedEnd: endIndex,
  onNext: () {
    setState(() {
      currentPage++;
    });
  },
  onPrevious: () {
    setState(() {
      currentPage--;
    });
  },
),
                              ],
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Sidebar_Operation(selectedKey: selectedKey),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "تم الرد":
        return AppColors.primary;
    
      case "تحت المراجعة":
        return AppColors.error;
      default:
        return AppColors.black37;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case "تم الرد":
        return "تم الرد";
    
      case "تحت المراجعة":
        return "تحت المراجعة";
      default:
        return "غير محدد";
    }
  }
}
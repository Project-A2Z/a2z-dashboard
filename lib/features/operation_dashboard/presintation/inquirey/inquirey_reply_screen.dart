import 'package:disctop_app/core/widgets/header_operation.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_operation.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/inquirey_cubit/inquirey_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/inquirey_cubit/inquirey_model.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/inquirey_cubit/inquirey_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disctop_app/core/app_colors.dart';
import 'package:intl/intl.dart' show DateFormat;

class InquiryDetailScreen extends StatefulWidget {
  final InquiryModel inquiry;
  const InquiryDetailScreen({super.key, required this.inquiry});

  @override
  State<InquiryDetailScreen> createState() => _InquiryDetailScreenState();
}

class _InquiryDetailScreenState extends State<InquiryDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  final selectedKey = "التواصل";

  @override
  void initState() {
    super.initState();
    _replyController.text = widget.inquiry.reply ?? '';
  }

  
  String _getInquiryStatus() {
    final inquiry = widget.inquiry;
    final hasReply = (inquiry.reply != null && inquiry.reply!.trim().isNotEmpty);
    
    
    
    
    
    
    
    if (hasReply) {
      return "تم الرد";
    } else {
      return "تحت المراجعة";
    }
  }

  
  Color _getStatusColor(String status) {
    switch (status) {
      case "تم الرد":
        return AppColors.primary;
      case "تم التواصل":
        return AppColors.secondary1;
      case "تحت المراجعة":
        return AppColors.error;
      default:
        return AppColors.black37;
    }
  }

  
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy/MM/dd - hh:mm a', 'ar').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final inquiry = widget.inquiry;
    final hasReply = (inquiry.reply != null && inquiry.reply!.trim().isNotEmpty);
    final status = _getInquiryStatus();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Row(
            children: [
              Sidebar_Operation(selectedKey: selectedKey),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: BlocConsumer<InquiryCubit, InquiryState>(
                    listener: (context, state) {
                     if (state is InquiryReplied) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      
      content: const Text(
        "تم إرسال الرد بنجاح.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 16,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); 
            Navigator.pop(context); 
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
          child: const Text(
            "حسناً",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

                    },
                    builder: (context, state) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: DashboardHeader(title: "التواصل", onRefreshTap: (){
                               context.read<InquiryCubit>().fetchInquiryDetails(inquiry.id);
                              },)
                            ),
                            const SizedBox(height: 20),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                   Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                     children: [
                                       Container(
                                        
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color: _getStatusColor(status),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                                                         ),
                                     ],
                                   ),
                                  
                                  
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: AppColors.primary,
                                    child: Text(
                                      inquiry.name.isNotEmpty
                                          ? inquiry.name[0].toUpperCase()
                                          : "?",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    inquiry.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  
                                  
                                  const SizedBox(height: 25),
                                 
                              
                                  
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          inquiry.description,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.black60,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        "${inquiry.createdAt.day}/${inquiry.createdAt.month}/${inquiry.createdAt.year}",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: AppColors.black60,
                                            fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),

                            
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                                const Padding(
                                  padding: EdgeInsets.only(right: 8, bottom: 8),
                                  child: Text(
                                    "الرد",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black60,
                                    ),
                                  ),
                                ),
                                
                                
                                TextField(
                                  controller: _replyController,
                                  readOnly: hasReply,
                                  maxLines: 6,
                                  decoration: InputDecoration(
                                    hintText: "اكتب ردك هنا...",
                                    contentPadding: const EdgeInsets.all(16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                          color: AppColors.black16),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                          color: AppColors.primary, width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                          color: AppColors.black16),
                                    ),
                                  ),
                                ),
                                
                                
                                
                                if (hasReply)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8, right: 8),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: AppColors.black37,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "تم الرد في: ${_formatDate(inquiry.updatedAt)}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: AppColors.black60,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                
                                // ignore: unnecessary_null_comparison
                                if (hasReply && inquiry.updatedAt == null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8, right: 8),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: AppColors.black37,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "تم الرد في: ${_formatDate(inquiry.updatedAt)}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.black37,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            
                            if (!hasReply)
                              state is InquiryLoading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                      onPressed: () {
                                        final replyText =
                                            _replyController.text.trim();
                                       
                                        context
                                            .read<InquiryCubit>()
                                            .replyInquiry(
                                                inquiry.id, replyText);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 60, vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text(
                                        "إرسال الرد",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                          ],
                        ),
                      );
                    },
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
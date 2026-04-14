import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/core/widgets/header_operation.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_operation.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/reviews_cubit/review_replay_state.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/reviews_cubit/reviews_replay_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../operation_cubit/reviews_cubit/reviews_model.dart';

class ReplyScreen extends StatefulWidget {
  final ReviewModel review;
  final Function(String) onReplySent;

  const ReplyScreen({super.key, required this.review, required this.onReplySent});

  @override
  State<ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
   TextEditingController _controller = TextEditingController();
  final selectedKey = "التعليقات و المراجعات";

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.review.reply, 
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (_) => ReplyCubit(ApiService()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Sidebar_Operation(selectedKey: selectedKey),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: DashboardHeader(title: "الرد على التعليق",showBack: true,showRefresh: false,)),
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          widget.review.user.fullName.isNotEmpty
                              ? widget.review.user.fullName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.review.user.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < widget.review.rateNum ? Icons.star_rate : Icons.star_border,
                            color: const Color(0xFFFFC107),
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.review.description.isNotEmpty
                            ? widget.review.description
                            : 'لا يوجد تعليق',
                        style: const TextStyle(fontSize: 14, color: AppColors.black60),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _controller,
                        maxLines: 6,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.black16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.black16),
                          ),
                          filled: true,
                          fillColor: Colors.white
                        ),
                      ),
                      const SizedBox(height: 24),
                 
                        BlocConsumer<ReplyCubit, ReplyState>(
                          listener: (context, state) {
                            if (state is ReplySuccess) {
                              widget.onReplySent(_controller.text);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  content: const Text(
                                    "تم إرسال الرد بنجاح.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.primary, fontSize: 16),
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 60, vertical: 14),
                                      ),
                                      child: const Text(
                                        "حسناً",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else if (state is ReplyError) {
                              
                            }
                          },
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state is ReplyLoading
                                  ? null
                                  : () {
                                      context.read<ReplyCubit>().sendReply(
                                            widget.review.id,
                                            _controller.text,
                                          );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: state is ReplyLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      "إرسال الرد",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          },
                        ),
                    ],
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

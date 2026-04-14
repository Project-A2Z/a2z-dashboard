import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/reviews_cubit/review_replay_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReplyCubit extends Cubit<ReplyState> {
  final ApiService apiService;

  ReplyCubit(this.apiService) : super(ReplyInitial());

  Future<void> sendReply(String reviewId, String message) async {
    if (message.trim().isEmpty) return;
    emit(ReplyLoading());
    try {
      await apiService.sendReply(reviewId: reviewId, message: message);
      emit(ReplySuccess());
    } catch (e) {
      emit(ReplyError(error: e.toString()));
    }
  }
}

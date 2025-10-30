import 'package:disctop_app/core/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'inquirey_state.dart';

class InquiryCubit extends Cubit<InquiryState> {
  final ApiService _service;

  InquiryCubit(this._service) : super(InquiryInitial());

  Future<void> fetchInquiries() async {
    emit(InquiryLoading());
    try {
      final data = await _service.fetchInquiries();
      emit(InquiriesLoaded(data));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> replyInquiry(String id, String reply) async {
    emit(InquiryLoading());
    try {
      final inquiry = await _service.replyToInquiry(id, reply);
      emit(InquiryReplied(inquiry));
      await fetchInquiries(); // ✅ بعد التحديث نرجع نجيب البيانات تاني
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }
}

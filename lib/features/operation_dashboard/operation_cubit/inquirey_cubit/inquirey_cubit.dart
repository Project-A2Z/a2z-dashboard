import 'package:disctop_app/features/operation_dashboard/operation_cubit/inquirey_cubit/inquirey_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disctop_app/core/api_service.dart';

class InquiryCubit extends Cubit<InquiryState> {
  final ApiService api;
  InquiryCubit(this.api) : super(InquiryInitial());

  Future<void> fetchInquiries() async {
    emit(InquiryLoading());
    try {
      final data = await api.getInquiries();
      emit(InquiriesLoaded(data));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> fetchInquiryDetails(String id) async {
    emit(InquiryLoading());
    try {
      final inquiry = await api.getInquiryById(id);
      emit(InquiryDetailsLoaded(inquiry));
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  Future<void> replyInquiry(String id, String reply) async {
    emit(InquiryLoading());
    try {
      final inquiry = await api.replyToInquiry(id, reply);
      emit(InquiryReplied(inquiry));
      await fetchInquiries(); 
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }

  /// ✅ دالة جديدة لتحديث حالة الاستعلام
  Future<void> updateInquiryStatus(String id, String newStatus) async {
    emit(InquiryLoading());
    try {
      // لو عندك endpoint لتحديث الحالة في ApiService
      await api.updateInquiryStatus(id, newStatus);

      // بعد التحديث نرجع نجيب البيانات من السيرفر علشان نحدّث الجدول
      await fetchInquiries();

      // ممكن نبعث حالة جديدة لو حبيت تتابع التغيير
      emit(InquiryStatusUpdated());
    } catch (e) {
      emit(InquiryError(e.toString()));
    }
  }
}

import 'package:disctop_app/features/operation_dashboard/operation_cubit/inquirey_cubit/inquirey_model.dart';


abstract class InquiryState {}

class InquiryInitial extends InquiryState {}

class InquiryLoading extends InquiryState {}

class InquiriesLoaded extends InquiryState {
  final List<InquiryModel> inquiries;
  InquiriesLoaded(this.inquiries);
}

class InquiryReplied extends InquiryState {
  final InquiryModel inquiry;
  InquiryReplied(this.inquiry);
}

class InquiryError extends InquiryState {
  final String message;
  InquiryError(this.message);
}

import 'package:disctop_app/features/operation_dashboard/operation_cubit/inquirey_cubit/inquirey_model.dart';
import 'package:equatable/equatable.dart';

abstract class InquiryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InquiryInitial extends InquiryState {}

class InquiryLoading extends InquiryState {}

class InquiriesLoaded extends InquiryState {
  final List<InquiryModel> inquiries;
  InquiriesLoaded(this.inquiries);
  @override
  List<Object?> get props => [inquiries];
}

class InquiryDetailsLoaded extends InquiryState {
  final InquiryModel inquiry;
  InquiryDetailsLoaded(this.inquiry);
  @override
  List<Object?> get props => [inquiry];
}
class InquiryReplied extends InquiryState {
  final InquiryModel inquiry;
  InquiryReplied(this.inquiry);
}

class InquiryUpdating extends InquiryState {}

class InquiryError extends InquiryState {
  final String message;
  InquiryError(this.message);
  @override
  List<Object?> get props => [message];
}
class InquiryStatusUpdated extends InquiryState {}

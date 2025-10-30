import 'package:disctop_app/features/operation_dashboard/operation_cubit/reviews_cubit/reviews_model.dart';

abstract class ReviewsState {}

class ReviewsInitial extends ReviewsState {}

class ReviewsLoading extends ReviewsState {}

class ReviewsLoaded extends ReviewsState {
  final List<ReviewModel> reviews;
  final int totalResults;

  ReviewsLoaded({
    required this.reviews,
    required this.totalResults,
  });
}

class ReviewsError extends ReviewsState {
  final String message;

  ReviewsError(this.message);
}

class ReviewsEmpty extends ReviewsState {}
class ReviewsDeleting extends ReviewsState {}

class ReviewDeletedSuccess extends ReviewsState {}

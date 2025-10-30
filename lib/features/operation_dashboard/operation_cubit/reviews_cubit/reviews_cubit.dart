import 'package:bloc/bloc.dart';
import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/reviews_cubit/reviews_model.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/reviews_cubit/reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  final ApiService apiService;

  ReviewsCubit(this.apiService) : super(ReviewsInitial());

  /// 🔹 تحميل كل الريفيوهات لكل المنتجات
  Future<void> fetchAllReviewsForAllProducts() async {
    try {
      emit(ReviewsLoading());

      // 1️⃣ نحصل على كل المنتجات
      final products = await apiService.getAllProducts();
      List<ReviewModel> allReviews = [];

      // 2️⃣ نجيب الريفيوهات لكل منتج
      for (final product in products) {
        try {
          final reviews = await apiService.getReviewsByProduct(product.id);
          allReviews.addAll(reviews);
        } catch (e) {
          print('⚠️ فشل في جلب مراجعات المنتج ${product.id}: $e');
        }
      }

      // 3️⃣ نتحقق إذا كانت القائمة فاضية
      if (allReviews.isEmpty) {
        emit(ReviewsEmpty());
      } else {
        emit(ReviewsLoaded(
          reviews: allReviews,
          totalResults: allReviews.length,
        ));
      }
    } catch (e) {
      emit(ReviewsError('فشل في تحميل كل المراجعات: $e'));
    }
  }

  /// 🔹 تحميل الريفيوهات الخاصة بمنتج واحد فقط
  Future<void> fetchReviewsByProduct(String productId) async {
    try {
      emit(ReviewsLoading());
      final reviews = await apiService.getReviewsByProduct(productId);
      if (reviews.isEmpty) {
        emit(ReviewsEmpty());
      } else {
        emit(ReviewsLoaded(
          reviews: reviews,
          totalResults: reviews.length,
        ));
      }
    } catch (e) {
      emit(ReviewsError('فشل في تحميل مراجعات المنتج: $e'));
    }
  }

  /// 🔹 حذف ريفيو معين
  Future<void> deleteReview(String reviewId) async {
    try {
      // نبدأ حالة تحميل أثناء الحذف
      emit(ReviewsDeleting());

      await apiService.deleteReview(reviewId);

      // بعد الحذف نحدث الحالة بعرض الريفيوهات من جديد
      await fetchAllReviewsForAllProducts();

      emit(ReviewDeletedSuccess());
    } catch (e) {
      emit(ReviewsError('فشل في حذف المراجعة: $e'));
    }
  }

  /// 🔹 تحديث البيانات (إعادة تحميل كل الريفيوهات)
  void refresh() {
    fetchAllReviewsForAllProducts();
  }
}

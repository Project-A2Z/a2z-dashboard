import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/core/widgets/header_operation.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_operation.dart';
import 'package:disctop_app/features/operation_dashboard/presintation/review/replay_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/reviews_cubit/reviews_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/reviews_cubit/reviews_state.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/reviews_cubit/reviews_model.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_model.dart';
import 'package:disctop_app/core/api_service.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int currentPage = 1;
  int itemsPerPage = 10;
  final Map<String, ProductModel?> _productCache = {};
  final ApiService _apiService = ApiService();
  final String selectedKey = "التعليقات و المراجعات";

void _onReply(ReviewModel review) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ReplyScreen(
        reviewId: review.id,
        onReplySent: (sentReply) {
          
          context.read<ReviewsCubit>().refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال الرد')),
          );
        },
      ),
    ),
  );
}


Future<void> _onHide(ReviewModel review) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('تأكيد الإخفاء'),
      content: const Text('هل تريد إخفاء هذا التقييم؟'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('إخفاء')),
      ],
    ),
  );

  if (confirmed != true) return;

  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    await ApiService().hideReview(review.id); 
    if (mounted) {
      Navigator.pop(context); 
      context.read<ReviewsCubit>().refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إخفاء التقييم بنجاح')),
      );
    }
  } catch (e) {
    if (mounted) Navigator.pop(context);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الإخفاء: ${e.toString()}')),
      );
    }
  }
}


Future<void> _onDelete(ReviewModel review) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('تأكيد الحذف'),
      content: const Text('هل أنت متأكد من حذف هذا التقييم؟'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
      ],
    ),
  );

  if (confirmed != true) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    await ApiService().deleteReview(review.id);
    if (mounted) {
      Navigator.pop(context); 
      context.read<ReviewsCubit>().refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف التقييم بنجاح'), backgroundColor: Colors.green),
      );
    }
  } catch (e) {
    if (mounted) Navigator.pop(context);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الحذف: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }
}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewsCubit>().fetchAllReviewsForAllProducts();
    });
  }

  Future<ProductModel?> _getProduct(String productId) async {
    if (productId.isEmpty) return null;
    
    if (_productCache.containsKey(productId)) {
      return _productCache[productId];
    }

    try {
      final product = await _apiService.getProductById(productId);
      _productCache[productId] = product;
      return product;
    } catch (e) {
      print('Error fetching product $productId: $e');
      _productCache[productId] = null;
      return null;

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Sidebar_Operation(selectedKey: selectedKey),
            Expanded(
              child: Column(
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: DashboardHeader(title: "التعليقات والمراجعات"),
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<ReviewsCubit, ReviewsState>(
                      builder: (context, state) {
                        if (state is ReviewsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        } else if (state is ReviewsError) {
                          return Center(child: Text('خطأ في تحميل المراجعات',style: TextStyle(color: Colors.red,fontSize: 20),));
                        } else if (state is ReviewsEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.rate_review_outlined,
                                  color: Colors.grey[400],
                                  size: 60,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد تقييمات',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (state is ReviewsLoaded) {
                          return _buildReviewsTable(state.reviews);
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTable(List<ReviewModel> reviews) {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, reviews.length);
    final paginatedReviews = reviews.sublist(startIndex, endIndex);

    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTableHeader(),
                Expanded(
                  child: ListView.builder(
                    itemCount: paginatedReviews.length,
                    itemBuilder: (context, index) {
                      return _buildTableRow(paginatedReviews[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildPagination(reviews.length),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: const Row(
        children: [
          Expanded(flex: 2, child: _HeaderCell(title: 'العميل')),
          Expanded(flex: 3, child: _HeaderCell(title: 'المنتج')),
          Expanded(flex: 4, child: _HeaderCell(title: 'التعليق')),
          Expanded(flex: 2, child: _HeaderCell(title: 'التقييم')),
          Expanded(flex: 1, child: _HeaderCell(title: 'المزيد')),
        ],
      ),
    );
  }

  Widget _buildTableRow(ReviewModel review) {
    return FutureBuilder<ProductModel?>(
      future: _getProduct(review.productId),
      builder: (context, snapshot) {
        final product = snapshot.data;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;

        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              Expanded(
                flex: 2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      review.user.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.black60,
                      ),
                    ),
                    
                  ],
                ),
              ),

              
              Expanded(
                flex: 3,
                child: isLoading
                    ? Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF5C8D4E),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('جاري التحميل...'),
                          ),
                        ],
                      )
                    : hasError || product == null
                        ? Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.grey[400],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'منتج غير متوفر',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: product.imageList.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          product.imageList.first,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.image_outlined,
                                            color: Colors.grey[400],
                                            size: 28,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.image_outlined,
                                        color: Colors.grey[400],
                                        size: 28,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.black60,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${product.price.toStringAsFixed(0)} ج',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.black60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
              ),

              
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    review.description.isNotEmpty
                        ? review.description
                        : 'لا يوجد تعليق',
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: review.description.isNotEmpty
                          ? AppColors.black60
                          : Colors.grey[500],
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(
                        index < review.rateNum ? Icons.star_rate : Icons.star_border,
                        color: const Color(0xFFFFC107),
                        size: 20,
                      ),
                    );
                  }),
                ),
              ),

              
              Expanded(
                flex: 1,
                child: Center(
                  child: PopupMenuButton<String>(
  icon: const Icon(
    Icons.more_vert,
    color: AppColors.black60,
  ),
  offset: const Offset(0, 40),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: 'reply',
      child: Row(
        children: [
          Icon(Icons.reply_outlined, size: 20),
          SizedBox(width: 10),
          Text('رد'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'hide',
      child: Row(
        children: [
          Icon(Icons.visibility_off_outlined, size: 20),
          SizedBox(width: 10),
          Text('إخفاء'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.delete_outline, color: Colors.red, size: 20),
          SizedBox(width: 10),
          Text('حذف', style: TextStyle(color: Colors.red)),
        ],
      ),
    ),
  ],
  onSelected: (value) async {
    if (value == 'reply') {
      _onReply(review);
    } else if (value == 'hide') {
      _onHide(review);
    } else if (value == 'delete') {
      _onDelete(review);
    }
  },
),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildPagination(int totalItems) {
    final totalPages = (totalItems / itemsPerPage).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'عرض $itemsPerPage من $totalItems',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: currentPage > 1 ? Colors.black87 : Colors.grey[400],
                ),
                onPressed: currentPage > 1
                    ? () {
                        setState(() {
                          currentPage--;
                        });
                      }
                    : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$currentPage',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'من',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '$totalPages',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: currentPage < totalPages ? Colors.black87 : Colors.grey[400],
                ),
                onPressed: currentPage < totalPages
                    ? () {
                        setState(() {
                          currentPage++;
                        });
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String title;

  const _HeaderCell({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      textAlign: TextAlign.center,
    );
  }
  
}
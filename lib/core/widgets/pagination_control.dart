import 'package:flutter/material.dart';
import 'package:disctop_app/core/app_colors.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int displayedStart;
  final int displayedEnd;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.displayedStart,
    required this.displayedEnd,
    this.onNext,
    this.onPrevious,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          Text(
            'عرض $displayedEnd من $totalItems',
            style: TextStyle(
              color: AppColors.black60,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          
          Row(
            children: [
              IconButton(
                onPressed: (currentPage < totalPages - 1) ? onNext : null,
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                color: AppColors.primary,
                disabledColor: AppColors.black16,
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.black16),
                ),
                child: Text(
                  'صفحة ${currentPage + 1} من $totalPages',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: (currentPage > 0) ? onPrevious : null,
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
                color: AppColors.primary,
                disabledColor: AppColors.black16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

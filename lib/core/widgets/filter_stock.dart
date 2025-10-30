import 'package:flutter/material.dart';
import 'package:disctop_app/core/app_colors.dart';

enum StockFilter { all, outOfStock, inStock }

class StockFilterRow extends StatelessWidget {
  final StockFilter currentFilter;
  final ValueChanged<StockFilter> onChanged;

  const StockFilterRow({
    super.key,
    required this.currentFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _filterButton(context, "نفذ المخزون", StockFilter.outOfStock),
        const SizedBox(width: 16),
        _filterButton(context, "في المخزون", StockFilter.inStock),
        const SizedBox(width: 16),
        _filterButton(context, "الكل", StockFilter.all),
      ],
    );
  }

  Widget _filterButton(BuildContext context, String text, StockFilter type) {
    final selected = currentFilter == type;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.black16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: () => onChanged(type),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? AppColors.primary : AppColors.black60,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

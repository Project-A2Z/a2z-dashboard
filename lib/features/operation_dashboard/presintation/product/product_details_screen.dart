
import 'package:disctop_app/core/widgets/header_operation.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_operation.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_model.dart';
import 'package:disctop_app/features/operation_dashboard/presintation/product/edit_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:disctop_app/core/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late int selectedIndex;
  late Future<Map<String, dynamic>> _adminDetailsFuture;

  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
    _adminDetailsFuture = context
        .read<ProductsCubit>()
        .apiService
        .getProductAdminDetailsById(widget.product.id);
  }

  String _asText(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final ar = (map['ar'] ?? '').toString().trim();
      final en = (map['en'] ?? '').toString().trim();
      if (ar.isNotEmpty) return ar;
      if (en.isNotEmpty) return en;
    }
    return value.toString();
  }

  double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String _buildCapacityText(dynamic conversionRateValue, dynamic baseValue) {
    final conversionRate = _asDouble(conversionRateValue);
    final base = _asText(baseValue).trim();

    if (conversionRate <= 0 && base.isEmpty) return '-';
    if (conversionRate <= 0) return base;
    if (base.isEmpty) return conversionRate.toStringAsFixed(0);
    return '${conversionRate.toStringAsFixed(0)} $base';
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.imageList;
    final fallbackVariants = widget.product.productVariants;
    final formattedDate = DateFormat('d MMMM yyyy - hh:mm a', 'ar').format(
  DateTime.parse(widget.product.updatedAt).toLocal(),
);


    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        textDirection: TextDirection.rtl,
        children: [
          const Sidebar_Operation(selectedKey: "المنتجات"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DashboardHeader(title: "المنتجات",showBack: true,showRefresh: false,),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                backgroundColor: Colors.white,
                                title: const Text('تأكيد حذف المنتج'),
                                content: const SizedBox(
                                  width: 420,
                                  child: Text(
                                    'هل تريد حذف هذا المنتج نهائياً؟',
                                    style: TextStyle(color: AppColors.black87, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                actions: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: AppColors.primary),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            child: const Text('إلغاء', style: TextStyle(color: AppColors.primary)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            child: const Text('حذف', style: TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );

                          if (confirm == true) {
                            try {
                              await context
                                  .read<ProductsCubit>()
                                  .apiService
                                  .deleteProduct(widget.product.id);
                              await context
                                  .read<ProductsCubit>()
                                  .fetchProducts();
                                  
                              Navigator.of(context).pop(true);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('فشل الحذف: $e')),
                              );
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'حذف المنتج',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final res = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder:
                                  (_) => EditProductScreen(
                                    product: widget.product,
                                  ),
                            ),
                          );
                          if (res == true) {
                            try {
                              context.read<ProductsCubit>().fetchProducts();
                            } catch (_) {}
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        label: Row(
                          children: [
                            Text(
                              'تعديل',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.edit_outlined, color: Colors.white),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Spacer(),
                      Text(
                          "اخر تحديث: ${formattedDate}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black60,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  
                  
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 500,
                    ), 
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.black8, 
                        width: 1, 
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          images.isNotEmpty
                              ? Image.network(
                                images[selectedIndex],
                                width: 350,
                                height: 450,
                                fit: BoxFit.fill,
                              )
                              : Container(
                                width: 350,
                                height: 350,
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 100,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      selectedIndex == index
                                          ? AppColors.primary
                                          : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  images[index],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 20),

                  
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        Text(
                          widget.product.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black60,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color.fromRGBO(
                                      240,
                                      240,
                                      240,
                                      1,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "${widget.product.category}",
                                  style: const TextStyle(
                                    color: Color.fromRGBO(102, 102, 102, 1),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder<Map<String, dynamic>>(
                          future: _adminDetailsFuture,
                          builder: (context, snapshot) {
                            final stockRows = <Map<String, String>>[];
                            final sellingRows = <Map<String, String>>[];

                            if (snapshot.hasData) {
                              final groups = (snapshot.data!['variantGroups'] as List?)
                                      ?.whereType<Map>()
                                      .map((e) => Map<String, dynamic>.from(e))
                                      .toList() ??
                                  const <Map<String, dynamic>>[];

                              for (final group in groups) {
                                final groupVariants =
                                    (group['productVariants'] as List?)
                                            ?.whereType<Map>()
                                            .map((e) => Map<String, dynamic>.from(e))
                                            .toList() ??
                                        const <Map<String, dynamic>>[];

                                final inventories =
                                    (group['invetorys'] as List?)
                                            ?.whereType<Map>()
                                            .map((e) => Map<String, dynamic>.from(e))
                                            .toList() ??
                                        (group['inventories'] as List?)
                                                ?.whereType<Map>()
                                                .map((e) => Map<String, dynamic>.from(e))
                                                .toList() ??
                                            const <Map<String, dynamic>>[];

                                for (final v in groupVariants) {
                                  final unitObj = v['unitId'] is Map
                                      ? Map<String, dynamic>.from(v['unitId'])
                                      : <String, dynamic>{};
                                  final unitName = _asText(unitObj['name']);
                                  final capacityText = _buildCapacityText(
                                    unitObj['conversionRate'],
                                    unitObj['base'],
                                  );
                                  sellingRows.add({
                                    'unit': unitName.isEmpty ? 'الوحدة' : unitName,
                                    'capacity': capacityText,
                                    'price': '${_asDouble(v['price']).toStringAsFixed(0)} ج',
                                  });
                                }

                                // Try inv['unitId'] first (populated), then group['unitId'], then fallback to selling unit
                                for (final inv in inventories) {
                                  String invUnitName = _asText((inv['unitId'] as Map?)?['name']);
                                  if (invUnitName.isEmpty) {
                                    invUnitName = _asText((group['unitId'] as Map?)?['name']);
                                  }
                                  if (invUnitName.isEmpty && groupVariants.isNotEmpty) {
                                    invUnitName = _asText((groupVariants.first['unitId'] as Map?)?['name']);
                                  }
                                  stockRows.add({
                                    'unit': invUnitName.isEmpty ? 'الوحدة' : invUnitName,
                                    'qty': _asDouble(inv['quantity']).toStringAsFixed(0),
                                    'purchase': '${_asDouble(inv['purchasePrice']).toStringAsFixed(0)} ج',
                                  });
                                }
                              }
                            }

                            if (stockRows.isEmpty && sellingRows.isEmpty) {
                              for (final variant in fallbackVariants) {
                                final unit =
                                    variant.unitName.isEmpty ? 'الوحدة' : variant.unitName;
                                sellingRows.add({
                                  'unit': unit,
                                  'capacity': '-',
                                  'price': '${variant.price.toStringAsFixed(0)} ج',
                                });
                                final purchase =
                                    variant.purchasePrice ?? widget.product.purchasePrice;
                                stockRows.add({
                                  'unit': unit,
                                  'qty': variant.totalQuantity.toStringAsFixed(0),
                                  'purchase': '${purchase.toStringAsFixed(0)} ج',
                                });
                              }
                            }

                            final uniqueSellingRows = <Map<String, String>>[];
                            final seenSellingKeys = <String>{};
                            for (final row in sellingRows) {
                              final key =
                                  '${row['unit'] ?? ''}|${row['capacity'] ?? ''}|${row['price'] ?? ''}';
                              if (seenSellingKeys.add(key)) {
                                uniqueSellingRows.add(row);
                              }
                            }

                            final inStock = stockRows.isNotEmpty
                                ? stockRows.any((row) => _asDouble(row['qty']) > 0)
                                : widget.product.stockQty > 0;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: inStock ? AppColors.primary : AppColors.disabled,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    inStock ? 'متوفر في المخزون' : 'نفذ في المخزون',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const SizedBox(height: 8),
                                const Text(
                                  'المخزون',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black60,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (stockRows.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Expanded(child: _smallHeaderBox('الوحدة')),
                                      const SizedBox(width: 120),
                                      Expanded(child: _smallHeaderBox('الكمية')),
                                      const SizedBox(width: 120),
                                      Expanded(child: _smallHeaderBox('سعر الشراء')),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...stockRows.map((row) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Expanded(child: _smallInfoBox(row['unit'] ?? 'الوحدة')),
                                          const SizedBox(width: 120),
                                          Expanded(child: _smallInfoBox(row['qty'] ?? '0')),
                                          const SizedBox(width: 120),
                                          Expanded(child: _smallInfoBox(row['purchase'] ?? '0 ج')),
                                        ],
                                      ),
                                    );
                                  })
                                ] else
                                  const Text(
                                    'لا يوجد مخزون',
                                    style: TextStyle(color: AppColors.black60),
                                  ),
                                const SizedBox(height: 8),
                                const Text(
                                  'طريقة البيع',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black60,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (uniqueSellingRows.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Expanded(child: _smallHeaderBox('الوحدة')),
                                      const SizedBox(width: 80),
                                      Expanded(child: _smallHeaderBox('السعة')),
                                      const SizedBox(width: 80),
                                      Expanded(child: _smallHeaderBox('السعر')),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...uniqueSellingRows.map((row) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Expanded(child: _smallInfoBox(row['unit'] ?? 'الوحدة')),
                                          const SizedBox(width: 80),
                                          Expanded(child: _smallInfoBox(row['capacity'] ?? '-')),
                                          const SizedBox(width: 80),
                                          Expanded(child: _smallInfoBox(row['price'] ?? '0 ج')),
                                        ],
                                      ),
                                    );
                                  })
                                ] else
                                  const Text(
                                    'لا توجد طرق بيع',
                                    style: TextStyle(color: AppColors.black60),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Divider(height: 1, color: AppColors.black16),
                        const SizedBox(height: 10),
                        Text(
                          "مواصفات المنتج",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.4,
                            color: AppColors.black60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.product.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            height: 1.4,
                            color: AppColors.black60,
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outlinedInfoBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color.fromRGBO(240, 240, 240, 1)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.black60,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _smallHeaderBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.black8,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.black60,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _smallInfoBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color.fromRGBO(240, 240, 240, 1)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.black60,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}


import 'dart:async';
import 'package:disctop_app/core/widgets/filter_stock.dart';
import 'package:disctop_app/core/widgets/header_operation.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/notification_cubit/notification_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/category_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/category_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_operation.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_state.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_model.dart';
import 'package:disctop_app/features/operation_dashboard/presintation/product/add_product_screen.dart';
import 'package:disctop_app/features/operation_dashboard/presintation/product/product_details_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String? selectedValue;
  StockFilter currentFilter = StockFilter.all;
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  int currentPage = 1;
int itemsPerPage = 12;

  Timer? _notificationTimer;

  bool _isInStock(ProductModel product) {
    if (product.stockQty > 0) return true;
    return product.productVariants.any((variant) => variant.totalQuantity > 0);
  }

@override
void initState() {
  super.initState();
    context.read<ProductsCubit>().fetchProducts();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final cubit = context.read<OperationNotificationCubit>();

    
    cubit.loadNotifications();

    
    _notificationTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      cubit.loadNotifications();
    });
  });
}

@override
void dispose() {
  _notificationTimer?.cancel();
  _debounce?.cancel();
    _searchCtrl.dispose();
  super.dispose();
}



  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final q = value.trim();
      if (q.isEmpty) {
        context.read<ProductsCubit>().fetchProducts();
      } else {
        context.read<ProductsCubit>().searchProducts(nameRegex: q);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        textDirection: TextDirection.rtl,
        children: [
          const Sidebar_Operation(selectedKey: "المنتجات"),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: BlocBuilder<ProductsCubit, ProductsState>(
                  builder: (context, state) {
                    
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
  DashboardHeader(
  title: "المنتجات",
  
  onRefreshTap: () {
    setState(() {
      currentPage = 1; 
    });
    context.read<ProductsCubit>().fetchProducts();
  },
  ),

                            const SizedBox(height: 25),
                            _addButtonRow(),
                            const SizedBox(height: 25),
                            StockFilterRow(
                              currentFilter: currentFilter,
                              onChanged: (filter) {
                                setState(() => currentFilter = filter);
                              },
                            ),
                            const SizedBox(height: 25),
                            _dropdownSearch(),
                            const SizedBox(height: 25),
                            Expanded(
                              child: _buildProductsGrid(state, constraints),
                            ),
                            const SizedBox(height: 10),
                            _pagination(state is ProductsLoaded ? state.products : [])
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildProductsGrid(ProductsState state, BoxConstraints constraints) {
  if (state is ProductsLoading) {
    return const Center(child: CircularProgressIndicator(color: AppColors.primary,));
  } else if (state is ProductsLoaded) {
    List<ProductModel> products = state.products;

    if (currentFilter == StockFilter.outOfStock) {
      products = products.where((p) => !_isInStock(p)).toList();
    } else if (currentFilter == StockFilter.inStock) {
      products = products.where((p) => _isInStock(p)).toList();
    }

    if (selectedValue != null &&
        selectedValue!.isNotEmpty &&
        selectedValue != "الكل") {
      products = products.where((p) => p.category == selectedValue).toList();
    }

    if (products.isEmpty) {
      return  Center(child: Column(
        children: [
          Image.asset("assets/images/rafiki.png",height: 200,width: 200,),
          Text("لم تتوفر نتائج البحث",style: TextStyle(color: AppColors.black60,fontSize: 16,fontWeight: FontWeight.bold),),
        ],
      ));
    }

    int totalItems = products.length;
    int totalPages = (totalItems / itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1; 

    final int effectivePage = currentPage.clamp(1, totalPages);
    int startIndex = (effectivePage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > totalItems) endIndex = totalItems;

    List<ProductModel> paginated = products.sublist(startIndex, endIndex);

    
    int crossAxisCount = 6;
    double width = constraints.maxWidth;
    if (width < 600) {
      crossAxisCount = 2;
    } else if (width < 900) {
      crossAxisCount = 3;
    } else if (width < 1200) {
      crossAxisCount = 4;
    } else if (width < 1600) {
      crossAxisCount = 6;
    } else {
      crossAxisCount = 6;
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: paginated.length,
      itemBuilder: (_, i) {
        final p = paginated[i];
        final inStock = _isInStock(p);
         return InkWell(
  onTap: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: p),
      ),
    );
    if (!mounted) return;
    context.read<ProductsCubit>().fetchProducts();
  },
  child: LayoutBuilder(
    builder: (context, cardConstraints) {
      double cardWidth = cardConstraints.maxWidth;
      double imageHeight = cardWidth * 0.5;
      double fontSize = cardWidth < 150 ? 14 : 16; 
      double categoryFontSize = cardWidth < 150 ? 10 : 12;

      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.black16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.black16),
                    ),
                    child: p.imageList.isNotEmpty
                        ? Image.network(
                            p.imageList.first,
                            height: imageHeight,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : SizedBox(
                            height: imageHeight,
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 40),
                            ),
                          ),
                  ),
                  Positioned(
                    top: imageHeight - 34,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: inStock
                            ? AppColors.primary
                            : AppColors.disabled,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        inStock ? "متوفر في المخزون" : "نفذ في المخزون",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.black16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    child: Text(
                      p.category,
                      style: TextStyle(
                        color: AppColors.black60,
                        fontSize: categoryFontSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    p.name,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.black60,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ),
            ),
           
          ],
        ),
      );
    },
  ),
);

      },
    );
  } else if (state is ProductsError) {
    return Center(child: Text('خطأ في تحميل المنتجات',style: TextStyle(color: Colors.red,fontSize: 20),));
  }
  return const SizedBox();
}


  Widget _addButtonRow() => Row(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddProductScreen()),
              ).then((_) {
                context.read<ProductsCubit>().fetchProducts();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
           
            label: Row(children: [
              
               Text(
              "إضافة منتج",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            SizedBox(width: 5,),
            Icon(Icons.dashboard_customize_outlined, color: Colors.white),
            ],)
          ),
          const Spacer(),
        ],
      );

  Widget _dropdownSearch() {
  return BlocBuilder<CategoriesCubit, CategoriesState>(
    builder: (context, state) {
      List<String> items = ["الكل"];

      if (state is CategoriesLoading) {
        return const CircularProgressIndicator();
      }

      if (state is CategoriesLoaded) {
        items.addAll(state.categories.map((e) => e.toString()).toList());
      }

      return Row(
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              width: 250,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.black16),
                borderRadius: BorderRadius.circular(32),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedValue,
                  hint: const Text('الفئة'),
                  isExpanded: true,
                  onChanged: (val) {
                    setState(() => selectedValue = val);
                  },
                  items: items.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          const Spacer(),
          SizedBox(
            width: 328,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: "بحث",
                  hintStyle: TextStyle(color: AppColors.black37),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search_rounded, color: AppColors.black37),
                    onPressed: () {
                      final q = _searchCtrl.text.trim();
                      if (q.isEmpty) {
                        context.read<ProductsCubit>().fetchProducts();
                      } else {
                        context
                            .read<ProductsCubit>()
                            .searchProducts(nameRegex: q);
                      }
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(color: AppColors.black16)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(color: AppColors.black16)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(color: AppColors.black16)
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
        ],
      );});}


Widget _pagination(List<ProductModel> allProducts) {
  int totalItems = allProducts.length;
  int totalPages = (totalItems / itemsPerPage).ceil();
  if (totalPages == 0) totalPages = 1;

  
  
  final int effectivePage = currentPage.clamp(1, totalPages);

  int start = (effectivePage - 1) * itemsPerPage + 1;
  int end = effectivePage * itemsPerPage;
  if (end > totalItems) end = totalItems;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        
        Row(
          children: [
            IconButton(
              onPressed: effectivePage > 1
                  ? () => setState(() => currentPage = effectivePage - 1)
                  : null, 
              icon: const Icon(Icons.chevron_left),
            ),
            Container(
              width: 40,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                "$effectivePage",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            IconButton(
              onPressed: effectivePage < totalPages
                  ? () => setState(() => currentPage = effectivePage + 1)
                  : null, 
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),

        Text(
          "عرض $start - $end من $totalItems",
          style: const TextStyle(color: AppColors.black60, fontSize: 13),
        ),
      ],
    ),
  );
}

}

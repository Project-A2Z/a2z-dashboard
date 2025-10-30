
import 'dart:async';
import 'package:disctop_app/core/widgets/filter_stock.dart';
import 'package:disctop_app/core/widgets/header_operation.dart';
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
int itemsPerPage = 20;

  
  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().fetchProducts();
  }

 
  @override
  void dispose() {
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
                    final List<String> categories = (state is ProductsLoaded)
                        ? state.products.map((p) => p.category).toSet().toList()
                        : [];
                    final List<String> dropItems = ["الكل", ...categories];

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
                            _dropdownSearch(dropItems),
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
      products = products.where((p) => p.stockQty == 0).toList();
    } else if (currentFilter == StockFilter.inStock) {
      products = products.where((p) => p.stockQty > 0).toList();
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
        mainAxisSpacing: 20,
        crossAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: paginated.length,
      itemBuilder: (_, i) {
        final p = paginated[i];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: p),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.black16),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    children: [
                       Container(
                            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.black16),
            ),
                            child: p.imageList.isNotEmpty
                          ?
                            Image.network(
                                p.imageList.first,
                                height: 130,
                                width: double.infinity,
                                fit: BoxFit.fill,
                              )
                          
                          : const SizedBox(
                              height: 130,
                              child: Center(
                                child:
                                    Icon(Icons.image_not_supported, size: 40),
                              ),
                            ),),
                      Positioned(
                        top: 90,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: p.stockQty > 0
                                ? AppColors.primary
                                : AppColors.disabled,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            p.stockQty > 0
                                ? "متوفر في المخزون"
                                : "نفذ في المخزون",
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
                const SizedBox(height: 5),
               Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   Container(
                           decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.black16),
                            ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 2),
                    child: Text(
                      p.category,
                      style: const TextStyle(
                        color: AppColors.black60,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
               
                
                ],
               ),
               SizedBox(height: 7,),
               Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   
                   Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.black60,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                
                ],
               ),
               Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                  'ج ${p.price}',
                  style: const TextStyle(
                    color: AppColors.black60,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                                  ),
                ],
               )
              ],
            ),
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

  Widget _dropdownSearch(List<String> items) => Row(
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
                  hint: const Text('الفئة', textDirection: TextDirection.rtl,style: TextStyle(color: AppColors.black60),),
                  icon:  Icon(Icons.arrow_drop_down_outlined, color: AppColors.black60),
                  style: const TextStyle(fontSize: 16, color: AppColors.black60),
                  borderRadius: BorderRadius.circular(15),
                  
                  isExpanded: true,
                  onChanged: (val) {
                    setState(() => selectedValue = val);
                  },
                  items: items
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item, textDirection: TextDirection.rtl),
                        ),
                      )
                      .toList(),
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
      );


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

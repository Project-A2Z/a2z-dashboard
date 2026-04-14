import 'dart:io';
import 'dart:typed_data';
import 'package:disctop_app/core/api_service.dart';
import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/core/widgets/header_operation.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_operation.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_model.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/update_product_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/update_products_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController descCtrl;
  late TextEditingController qtyCtrl;
  late TextEditingController catCtrl;

  bool inStock = true;
  List<Uint8List> pickedImages = [];
  List<String> existingImages = [];
  int mainImageIndex = 0; 

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.product.name);
    priceCtrl = TextEditingController(text: widget.product.price.toString());
    descCtrl = TextEditingController(text: widget.product.description);
    qtyCtrl = TextEditingController(text: widget.product.stockQty.toString());
    catCtrl = TextEditingController(text: widget.product.category);
    inStock = widget.product.stockQty > 0;
    existingImages = List<String>.from(widget.product.imageList);
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      final newImages = <Uint8List>[];
      for (final f in result.files) {
        Uint8List? bytes = f.bytes;
        if (bytes == null && f.path != null) {
          bytes = await File(f.path!).readAsBytes();
        }
        if (bytes != null) newImages.add(bytes);
      }

      final total = existingImages.length + pickedImages.length + newImages.length;
      if (total > 5) {
        final allowed = 5 - (existingImages.length + pickedImages.length);
        pickedImages.addAll(newImages.take(allowed));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ الحد الأقصى 5 صور فقط")),
        );
      } else {
        pickedImages.addAll(newImages);
      }
      setState(() {});
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      existingImages.removeAt(index);
      if (mainImageIndex >= existingImages.length + pickedImages.length) {
        mainImageIndex = 0;
      }
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      pickedImages.removeAt(index);
      if (mainImageIndex >= existingImages.length + pickedImages.length) {
        mainImageIndex = 0;
      }
    });
  }

  
  void _setMainImage(int index) {
    setState(() => mainImageIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UpdateProductCubit(ApiService()),
      child: Scaffold(
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
                  child: BlocConsumer<UpdateProductCubit, UpdateProductState>(
                    listener: (context, state) {
                      if (state is UpdateProductSuccess) {
                        context.read<ProductsCubit>().fetchProducts();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تعديل المنتج بنجاح')),
                        );
                        Navigator.pushReplacementNamed(context, '/products');
                      } else if (state is UpdateProductError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(' خطأ في التعديل: ${state.message}')),
                        );
                      }
                    },
                    builder: (context, state) {
                      return Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DashboardHeader(
  title: "تعديل المنتج",
  
  
),
                            const SizedBox(height: 30),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _imagesGrid(),
                                  const SizedBox(width: 30),
                                  Expanded(flex: 5, child: _formFields()),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _actionButtons(state),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagesGrid() {
    final allImages = [
      ...existingImages.map((e) => {'type': 'url', 'data': e}),
      ...pickedImages.map((e) => {'type': 'bytes', 'data': e}),
    ];

    return Expanded(
      flex: 3,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (allImages.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: allImages[mainImageIndex]['type'] == 'url'
                      ? Image.network(
                          allImages[mainImageIndex]['data'] as String,
                          width: double.infinity,
                          height: 350,
                          fit: BoxFit.fill,
                        )
                      : Image.memory(
                          allImages[mainImageIndex]['data'] as Uint8List,
                          width: double.infinity,
                          height: 350,
                          fit: BoxFit.fill,
                        ),
                ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...allImages.asMap().entries.map((entry) {
                    final i = entry.key;
                    final img = entry.value;
                    return GestureDetector(
                      onTap: () => _setMainImage(i),
                      child: _smallImageTile(
                        imageUrl: img['type'] == 'url' ? img['data'] as String : null,
                        imageBytes: img['type'] == 'bytes' ? img['data'] as Uint8List : null,
                        onRemove: img['type'] == 'url'
                            ? () => _removeExistingImage(
                                existingImages.indexOf(img['data'] as String))
                            : () => _removeNewImage(pickedImages.indexOf(img['data'] as Uint8List)),
                      ),
                    );
                  }),
                  if (allImages.length < 5) _addImageButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallImageTile({String? imageUrl, Uint8List? imageBytes, required VoidCallback onRemove}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageUrl != null
              ? Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover)
              : Image.memory(imageBytes!, width: 80, height: 80, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addImageButton() => InkWell(
        onTap: _pickImage,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.black37),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.add_a_photo_outlined,
                size: 24, color: AppColors.black37),
          ),
        ),
      );

  Widget _formFields() => Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            _textField(nameCtrl, 'اسم المنتج'),
            const SizedBox(height: 16),
            _textField(priceCtrl, 'السعر', keyboard: TextInputType.number),
            const SizedBox(height: 16),
            _textField(descCtrl, 'مواصفات المنتج', maxLines: 4),
            const SizedBox(height: 16),
            _textField(catCtrl, 'الفئة'),
            const SizedBox(height: 16),
            _textField(qtyCtrl, 'الكمية بالمخزون', keyboard: TextInputType.number),
            const SizedBox(height: 16),
            _stockRadio(),
          ],
        ),
      );

  Widget _actionButtons(UpdateProductState state) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            ),
            child: const Text("إلغاء", style: TextStyle(color: AppColors.primary)),
          ),
          const SizedBox(width: 20),
          ElevatedButton.icon(
            onPressed: state is UpdateProductLoading ? null : _submit,
            icon: state is UpdateProductLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            label: const Text("تعديل", style: TextStyle(color: Colors.white)),
          ),
        ],
      );

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final deleteImages = widget.product.imageList
          .where((element) => !existingImages.contains(element))
          .toList();

      context.read<UpdateProductCubit>().updateProduct(
            id: widget.product.id,
            name: nameCtrl.text,
            price: priceCtrl.text,
            purchasePrice: '0', 
            description: descCtrl.text,
            category: catCtrl.text,
            stockQty: int.tryParse(qtyCtrl.text) ?? widget.product.stockQty,
            newImages: pickedImages,
            isKG: false,
            isTON: false,
            isLITER: false,
            isCUBIC_METER: false,
            deleteImages: deleteImages,
          );
    }
  }

  Widget _textField(TextEditingController c, String hint,
      {TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.black37),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _stockRadio() => Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: inStock,
              onChanged: (v) => setState(() => inStock = v ?? true),
              activeColor: AppColors.primary,
            ),
            const Text("متوفر بالمخزون",
                style: TextStyle(color: AppColors.black37)),
            const SizedBox(width: 30),
            Radio<bool>(
              value: false,
              groupValue: inStock,
              onChanged: (v) => setState(() => inStock = v ?? false),
              activeColor: AppColors.primary,
            ),
            const Text("غير متوفر", style: TextStyle(color: AppColors.black37)),
          ],
        ),
      );
}

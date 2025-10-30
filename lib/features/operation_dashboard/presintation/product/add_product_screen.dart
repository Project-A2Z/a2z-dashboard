import 'dart:typed_data';
import 'dart:io';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/add_product_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/add_product_cubit.dart';
import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_operation.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final catCtrl = TextEditingController();

  String? selectedCategory;
  bool inStock = true;

  
  final List<Uint8List> pickedImages = [];

  Future<void> _pickImage() async {
    if (pickedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ لا يمكنك إضافة أكثر من 5 صور")),
      );
      return;
    }

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

      final total = pickedImages.length + newImages.length;
      if (total > 5) {
        final allowed = 5 - pickedImages.length;
        pickedImages.addAll(newImages.take(allowed));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ تم الاكتفاء بـ 5 صور كحد أقصى")),
        );
      } else {
        pickedImages.addAll(newImages);
      }
      setState(() {});
    }
  }

  void _removeImage(int index) {
    setState(() => pickedImages.removeAt(index));
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
                child: BlocConsumer<AddProductCubit, AddProductState>(
                  listener: (context, state) {
                    if (state is AddProductSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ تمت الإضافة بنجاح')),
                      );
                      nameCtrl.clear();
                      priceCtrl.clear();
                      descCtrl.clear();
                      qtyCtrl.clear();
                      setState(() {
                        selectedCategory = null;
                        pickedImages.clear();
                        inStock = true;
                      });
                      _formKey.currentState?.reset();
                    } else if (state is AddProductFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ ${state.message}')),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _header(),
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
    );
  }

  Widget _header() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primary,
            child: Text(
              "M",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "إضافة منتج",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.black87,
            ),
          ),
        ],
      );

  
Widget _imagesGrid() => Expanded(
      flex: 3,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildMainImage(),
            ),
            const SizedBox(height: 10),

            
            Directionality(
              textDirection: TextDirection.rtl,
              child: Expanded(
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _gridItemCount(),
                  itemBuilder: (_, index) {
                    
                    final bool isAddButton =
                        index == _gridItemCount() - 1 &&
                        pickedImages.length - 1 < 4; 
              
                    if (isAddButton) return _addImageButton();
              
                    
                    final img = pickedImages[index + 1];
                    return _smallImageTile(img, index + 1);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );


Widget _buildMainImage() {
  if (pickedImages.isEmpty) {
    return _addImageButton();
  }
  return Stack(
    fit: StackFit.expand,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(pickedImages[0], fit: BoxFit.cover),
      ),
      Positioned(
        top: 4,
        right: 4,
        child: InkWell(
          onTap: () => _removeImage(0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: const Icon(Icons.close, color: Colors.white, size: 18),
          ),
        ),
      ),
    ],
  );
}


Widget _addImageButton() => InkWell(
      onTap: _pickImage,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.black37),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  size: 40, color: AppColors.black37),
              Text("صورة المنتج",style: TextStyle(color: AppColors.black37 ),)    
            ],
          ),
        ),
      ),
    );


int _gridItemCount() {
  if (pickedImages.isEmpty) {
    
    return 0;
  }
  final remaining = pickedImages.length - 1;
  
  return remaining + (pickedImages.length < 5 ? 1 : 0);
}


Widget _smallImageTile(Uint8List img, int index) {
  return Stack(
    fit: StackFit.expand,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(img, fit: BoxFit.cover),
      ),
      Positioned(
        top: 4,
        right: 4,
        child: InkWell(
          onTap: () => _removeImage(index),
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

  Widget _actionButtons(AddProductState state) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            ),
            child:
                const Text("إلغاء", style: TextStyle(color: AppColors.primary)),
          ),
          const SizedBox(width: 20),
          ElevatedButton.icon(
            onPressed: state is AddProductLoading ? null : _submit,
            icon: state is AddProductLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            label:
                const Text("إضافة", style: TextStyle(color: Colors.white)),
          ),
        ],
      );

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (pickedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يجب إضافة صورة واحدة على الأقل")),
        );
        return;
      }

      context.read<AddProductCubit>().addProduct(
            name: nameCtrl.text,
            price: priceCtrl.text,
            description: descCtrl.text,
            category:catCtrl.text,
            stockQty: int.tryParse(qtyCtrl.text) ?? 0,
            inStock: inStock,
            
            imageBytesList: pickedImages,
            
            imageNames: List.generate(
              pickedImages.length,
              (i) =>
                  'product_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
            ),
          );
    }
  }

  Widget _textField(
    TextEditingController c,
    String hint, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
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

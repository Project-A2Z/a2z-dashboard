import 'dart:typed_data';
import 'dart:io';
import 'package:disctop_app/core/widgets/header_operation.dart';
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
  final nameEnCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final purchasepriceCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final descEnCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final catCtrl = TextEditingController();
  final catEnCtrl = TextEditingController();

  // Step 2 fields
  final quantityCtrl = TextEditingController();
  final capacityCtrl = TextEditingController();
  final totalPurchasePriceCtrl = TextEditingController();

  // Product details in Arabic (multiple fields)
  final List<TextEditingController> detailsArCtrls = [TextEditingController()];

  // Product details in English (multiple fields)
  final List<TextEditingController> detailsEnCtrls = [TextEditingController()];

  String? selectedCategory;
  bool inStock = true;
  bool isKG = false;
  bool isTON = false;
  bool isLITER = false;
  bool isCUBIC_METER = false;

  // Multi-step wizard
  int currentStep = 0;

  // Step 2 dropdowns
  String? selectedCategoryStep2;

  // API data lists (will be fetched from API)
  List<String> unitsList = ['كيلو', 'طن', 'لتر', 'متر مكعب', 'قطعة'];
  List<Map<String, dynamic>> attributesList = [];
  final List<String> categoriesList = [
    'كيماويات',
    'معدات',
    'أدوات',
    'مواد خام',
  ];
  List<String> capacityUnitsList = [
    'كيلو',
    'طن',
    'لتر',
    'متر مكعب',
    'جرام',
    'ملليلتر',
  ];
  final List<String> sellingMethodsList = [
    'بالجملة',
    'بالتجزئة',
    'أونلاين',
    'مباشر',
  ];
  List<Map<String, dynamic>> unitsCatalog = [];

  Map<String, Map<String, String>> unitNameArToObject = {
    'كيلو': {'ar': 'كيلو', 'en': 'kilogram'},
    'طن': {'ar': 'طن', 'en': 'ton'},
    'لتر': {'ar': 'لتر', 'en': 'liter'},
    'متر مكعب': {'ar': 'متر مكعب', 'en': 'cubic_meter'},
    'قطعة': {'ar': 'قطعة', 'en': 'piece'},
  };

  Map<String, Map<String, String>> baseUnitArToObject = {
    'كيلو': {'ar': 'كيلو', 'en': 'kilogram'},
    'طن': {'ar': 'طن', 'en': 'ton'},
    'لتر': {'ar': 'لتر', 'en': 'liter'},
    'جرام': {'ar': 'جرام', 'en': 'gram'},
    'ملليلتر': {'ar': 'ملليلتر', 'en': 'milliliter'},
    'قطعة': {'ar': 'قطعة', 'en': 'piece'},
  };

  // Step 2 stocks (repeatable)
  final List<Map<String, dynamic>> stockEntries = [];

  @override
  void initState() {
    super.initState();
    stockEntries.add(_createStockEntry());
    _loadConstantsUnits();
    _loadUnitsCatalog();
  }

  Future<void> _loadUnitsCatalog() async {
    try {
      final api = context.read<AddProductCubit>().apiService;
      final units = await api.getUnits();
      final attributes = await api.getAttributes();
      if (!mounted) return;
      setState(() {
        unitsCatalog = units;
        attributesList = attributes;
      });
    } catch (_) {
      // Keep current UI values if units API is unavailable.
    }
  }

  void _applyUnitFromCatalog(int stockIndex, String unitStr) {
    final stock = stockEntries[stockIndex];

    if (unitStr.trim().isEmpty) {
      (stock['capacityCtrl'] as TextEditingController).clear();
      (stock['baseUnitCtrl'] as TextEditingController).clear();
      return;
    }

    Map<String, dynamic>? found;
    for (final unit in unitsCatalog) {
      final name = (unit['name'] ?? '').toString().trim();
      final rate = (unit['conversionRate'] ?? '').toString().trim();
      final base = (unit['base'] ?? '').toString().trim();
      if ('$name($rate $base)' == unitStr) {
        found = unit;
        break;
      }
    }

    if (found == null) {
      (stock['capacityCtrl'] as TextEditingController).clear();
      (stock['baseUnitCtrl'] as TextEditingController).clear();
      return;
    }

    (stock['capacityCtrl'] as TextEditingController).text =
        (found['conversionRate'] ?? '').toString();
    (stock['baseUnitCtrl'] as TextEditingController).text =
        (found['base'] ?? '').toString();
  }

  Future<void> _loadConstantsUnits() async {
    try {
      final api = context.read<AddProductCubit>().apiService;
      final constants = await api.getProductUnitConstants();
      final unitNameFromApi = constants['unitName'] ?? [];
      final baseUnitFromApi = constants['baseUnit'] ?? [];

      if (!mounted) return;

      setState(() {
        if (unitNameFromApi.isNotEmpty) {
          unitsList =
              unitNameFromApi
                  .map((e) => (e['ar'] ?? '').trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
          unitNameArToObject = {
            for (final item in unitNameFromApi)
              if ((item['ar'] ?? '').trim().isNotEmpty)
                (item['ar'] ?? '').trim(): {
                  'ar': (item['ar'] ?? '').trim(),
                  'en': (item['en'] ?? '').trim().toLowerCase(),
                },
          };
          for (final stock in stockEntries) {
            final selected =
                (stock['unitNameCtrl'] as TextEditingController).text.trim();
            if (selected.isNotEmpty && !unitsList.contains(selected)) {
              (stock['unitNameCtrl'] as TextEditingController).clear();
            }
          }
        }

        if (baseUnitFromApi.isNotEmpty) {
          capacityUnitsList =
              baseUnitFromApi
                  .map((e) => (e['ar'] ?? '').trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
          baseUnitArToObject = {
            for (final item in baseUnitFromApi)
              if ((item['ar'] ?? '').trim().isNotEmpty)
                (item['ar'] ?? '').trim(): {
                  'ar': (item['ar'] ?? '').trim(),
                  'en': (item['en'] ?? '').trim().toLowerCase(),
                },
          };
          for (final stock in stockEntries) {
            final selected =
                (stock['baseUnitCtrl'] as TextEditingController).text.trim();
            if (selected.isNotEmpty && !capacityUnitsList.contains(selected)) {
              (stock['baseUnitCtrl'] as TextEditingController).clear();
            }
          }
        }
      });
    } catch (_) {
      // Keep fallback lists when constants API fails.
    }
  }

  final List<Uint8List> pickedImages = [];
  Future<void> _pickImage() async {
    if (pickedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(" لا يمكنك إضافة أكثر من 5 صور")),
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
          const SnackBar(content: Text("تم الاكتفاء بـ 5 صور كحد أقصى")),
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
                        const SnackBar(content: Text(' تمت الإضافة بنجاح')),
                      );

                      nameCtrl.clear();
                      nameEnCtrl.clear();
                      priceCtrl.clear();
                      purchasepriceCtrl.clear();
                      descCtrl.clear();
                      descEnCtrl.clear();
                      qtyCtrl.clear();
                      catCtrl.clear();
                      catEnCtrl.clear();
                      for (final c in detailsArCtrls) {
                        c.clear();
                      }
                      for (final c in detailsEnCtrls) {
                        c.clear();
                      }

                      _formKey.currentState?.reset();

                      setState(() {
                        selectedCategory = null;
                        pickedImages.clear();
                        inStock = true;
                        for (final stock in stockEntries) {
                          _disposeStockEntry(stock);
                        }
                        stockEntries
                          ..clear()
                          ..add(_createStockEntry());
                      });

                    } else if (state is AddProductFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${state.message}')),
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
                            title: "اضافة منتج",
                            showBack: true,
                            showRefresh: false,
                          ),
                          const SizedBox(height: 30),
                          Expanded(
                            child:
                                currentStep == 0
                                    ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _imagesGrid(),
                                        const SizedBox(width: 30),
                                        Expanded(
                                          flex: 5,
                                          child: _step1Content(),
                                        ),
                                      ],
                                    )
                                    : _step2Content(),
                          ),
                          const SizedBox(height: 20),
                          _stepActionButtons(state),
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

  Widget _imagesGrid() => Expanded(
    flex: 3,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.black8),
      ),
      child: Column(
        children: [
          AspectRatio(aspectRatio: 4 / 3, child: _buildMainImage()),
          const SizedBox(height: 10),
          Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              height: 72,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (pickedImages.length < 5) _smallAddTile(),
                  ..._smallImages(),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  List<Widget> _smallImages() {
    final thumbs = <Widget>[];
    if (pickedImages.length <= 1) return thumbs;
    for (var i = 1; i < pickedImages.length; i++) {
      thumbs.add(_smallImageTile(pickedImages[i], i));
    }
    return thumbs;
  }

  Widget _smallAddTile() => InkWell(
    onTap: _pickImage,
    child: Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.black16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 22,
              color: AppColors.black37,
            ),
            SizedBox(height: 4),
            Text(
              "صورة المنتج",
              style: TextStyle(color: AppColors.black37, fontSize: 10),
            ),
          ],
        ),
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
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 40,
              color: AppColors.black37,
            ),
            Text("صورة المنتج", style: TextStyle(color: AppColors.black37)),
          ],
        ),
      ),
    ),
  );

  Widget _smallImageTile(Uint8List img, int index) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
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
      ),
    );
  }

  // Step 1: Product Data
  Widget _step1Content() => Directionality(
    textDirection: TextDirection.rtl,
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepIndicator(),
          const SizedBox(height: 18),
          _sectionTitle('بيانات المنتج'),
          const SizedBox(height: 12),

          // اسم المنتج باللغة العربية
          _textField(nameCtrl, 'اسم المنتج باللغة العربية', required: true),
          const SizedBox(height: 12),

          // اسم المنتج باللغة الانجليزية
          _textField(
            nameEnCtrl,
            'اسم المنتج باللغة الانجليزية',
            required: true,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 12),

          // مواصفات المنتج باللغة العربية
          _textField(
            descCtrl,
            'مواصفات المنتج باللغة العربية',
            maxLines: 4,
            required: true,
          ),
          const SizedBox(height: 12),

          // مواصفات المنتج باللغة الانجليزية
          _textField(
            descEnCtrl,
            'مواصفات المنتج باللغة الانجليزية',
            maxLines: 4,
            required: true,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 18),

          // تفاصيل المنتج
          _sectionTitle('تفاصيل المنتج (عربي وإنجليزي)'),
          const SizedBox(height: 12),
          _combinedDetailsSection(),
          const SizedBox(height: 18),

          // الفئة باللغة العربية
          _textField(catCtrl, 'الفئة باللغة العربية', required: true),
          const SizedBox(height: 12),

          // الفئة باللغة الانجليزية
          _textField(
            catEnCtrl,
            'الفئة باللغة الانجليزية',
            required: true,
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    ),
  );

  Widget _step2Content() => Directionality(
    textDirection: TextDirection.rtl,
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepIndicator(),
          const SizedBox(height: 24),

          ...List.generate(stockEntries.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _stockCard(index),
            );
          }),

          ElevatedButton(
            onPressed: _addNewStock,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'إضافة مخزون',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _stockCard(int index) {
    final stock = stockEntries[index];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.black8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value:
                          ((stock['unitNameCtrl'] as TextEditingController).text
                                  .trim()
                                  .isEmpty)
                              ? null
                              : (stock['unitNameCtrl'] as TextEditingController)
                                  .text
                                  .trim(),
                      decoration: InputDecoration(
                        labelText: 'الوحدة',
                        hintText: 'اختر الوحدة',
                        hintStyle: const TextStyle(color: AppColors.black37),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      items:
                          unitsCatalog
                              .map((u) {
                                final name =
                                    (u['name'] ?? '').toString().trim();
                                final rate =
                                    (u['conversionRate'] ?? '')
                                        .toString()
                                        .trim();
                                final base =
                                    (u['base'] ?? '').toString().trim();
                                if (name.isEmpty) return '';
                                return '$name($rate $base)';
                              })
                              .where((str) => str.isNotEmpty)
                              .toSet()
                              .map(
                                (str) => DropdownMenuItem<String>(
                                  value: str,
                                  child: Text(str),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          (stock['unitNameCtrl'] as TextEditingController)
                              .text = value;
                          _applyUnitFromCatalog(index, value);
                        });
                      },
                      validator: (val) => val == null ? 'مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _showAddUnitDialog(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'إضافة وحدة جديدة',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      stock['capacityCtrl'],
                      'السعة',
                      keyboard: TextInputType.number,
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textField(
                      stock['totalPurchasePriceCtrl'],
                      'سعر الشراء الإجمالي',
                      keyboard: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      stock['quantityCtrl'],
                      'الكمية',
                      keyboard: TextInputType.number,
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textField(
                      stock['baseUnitCtrl'],
                      'الوحدة',
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      final list = stock['classifications'] as List<Map<String, dynamic>>;
                      list.add(_createClassificationEntry());
                    });
                  },
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text(
                    'إضافة تصنيف',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...(stock['classifications'] as List<Map<String, dynamic>>)
                  .asMap()
                  .entries
                  .map((entry) {
                final cIndex = entry.key;
                final cls = entry.value;
                final classificationsLength = (stock['classifications'] as List).length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: cls['selectedClassification'],
                              decoration: InputDecoration(
                                labelText: 'التصنيف',
                                hintText: 'اختر التصنيف',
                                hintStyle: const TextStyle(color: AppColors.black37),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              items: attributesList.map((attr) {
                                final text = (attr['name'] ?? '').toString();
                                return DropdownMenuItem<String>(
                                  value: text.isEmpty ? null : text,
                                  child: Text(text),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  cls['selectedClassification'] = val;
                                  if (cls['selectedClassificationValues'] == null) {
                                    cls['selectedClassificationValues'] = <String>[];
                                  }
                                  (cls['selectedClassificationValues'] as List<String>).clear();
                                });
                              },
                            ),
                          ),
                          if (classificationsLength > 1) ...[
                            const SizedBox(width: 6),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  (stock['classifications'] as List).removeAt(cIndex);
                                });
                              },
                              icon: const Icon(Icons.close, size: 18, color: AppColors.black60),
                              splashRadius: 18,
                            ),
                          ],
                        ],
                      ),
                      if (cls['selectedClassification'] != null)
                        Builder(
                          builder: (context) {
                            final attr = attributesList.firstWhere(
                              (a) => a['name'] == cls['selectedClassification'],
                              orElse: () => {},
                            );
                            final attrValues = attr['values'] as List<dynamic>? ?? [];
                            if (attrValues.isEmpty) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 12,
                                textDirection: TextDirection.rtl,
                                children: attrValues.map((v) {
                                  final valStr = (v is Map ? (v['value'] ?? v['name'] ?? v).toString() : v).toString();
                                  final selectedList = cls['selectedClassificationValues'] as List<String>;
                                  final isSelected = selectedList.contains(valStr);
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Checkbox(
                                        value: isSelected,
                                        activeColor: AppColors.primary,
                                        onChanged: (checked) {
                                          setState(() {
                                            if (checked == true) {
                                              selectedList.add(valStr);
                                            } else {
                                              selectedList.remove(valStr);
                                            }
                                          });
                                        },
                                      ),
                                      Text(valStr),
                                    ],
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              _sellingMethodsSection(index),
            ],
          ),
        ),
        Positioned(
          top: -10,
          left: 12,
          child: InkWell(
            onTap: stockEntries.length > 1 ? () => _removeStock(index) : null,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color:
                    stockEntries.length > 1 ? Colors.white : AppColors.black8,
                border: Border.all(color: AppColors.black16),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 14,
                color:
                    stockEntries.length > 1
                        ? AppColors.black60
                        : AppColors.black37,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepIndicator() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepDot(isActive: currentStep >= 0),
          Container(width: 36, height: 2, color: AppColors.black16),
          _stepDot(isActive: currentStep >= 1),
        ],
      ),
    );
  }

  Widget _stepDot({required bool isActive}) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.black16),
      ),
      child:
          isActive
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : const SizedBox.shrink(),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.black87,
      ),
    );
  }

  // تفاصيل المنتج (قابل للتكرار)
  Widget _combinedDetailsSection() {
    // Ensure both lists have the same length in case of issues
    final length =
        detailsArCtrls.length > detailsEnCtrls.length
            ? detailsArCtrls.length
            : detailsEnCtrls.length;

    while (detailsArCtrls.length < length) {
      detailsArCtrls.add(TextEditingController());
    }
    while (detailsEnCtrls.length < length) {
      detailsEnCtrls.add(TextEditingController());
    }

    return Column(
      children: List.generate(length, (index) {
        final isLast = index == length - 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _combinedDetailsRow(index, isLast: isLast),
        );
      }),
    );
  }

  Widget _combinedDetailsRow(int index, {required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detailsArCtrls.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: IconButton(
              onPressed: () {
                setState(() {
                  detailsArCtrls.removeAt(index);
                  detailsEnCtrls.removeAt(index);
                });
              },
              icon: const Icon(Icons.close, size: 18, color: AppColors.black60),
              splashRadius: 18,
            ),
          ),
        Expanded(
          child: _textField(detailsArCtrls[index], 'تفاصيل إضافية (عربي)'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _textField(
            detailsEnCtrls[index],
            'Additional Details (EN)',
            textDirection: TextDirection.ltr,
          ),
        ),
        const SizedBox(width: 10),
        if (isLast)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  detailsArCtrls.add(TextEditingController());
                  detailsEnCtrls.add(TextEditingController());
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text('إضافة', style: TextStyle(color: Colors.white)),
            ),
          ),
      ],
    );
  }

  // Selling Methods Section for Step 2
  Widget _sellingMethodsSection(int stockIndex) {
    final sellingMethods =
        stockEntries[stockIndex]['sellingMethods']
            as List<Map<String, dynamic>>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _addNewSellingMethod(stockIndex),
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text(
              'إضافة طريقة بيع',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(sellingMethods.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _sellingMethodRow(stockIndex, index),
          );
        }),
      ],
    );
  }

  Widget _sellingMethodRow(int stockIndex, int index) {
    final sellingMethods =
        stockEntries[stockIndex]['sellingMethods']
            as List<Map<String, dynamic>>;
    final method = sellingMethods[index];
    return Row(
      children: [
        // Selling method dropdown
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: method['sellingMethod'],
            decoration: InputDecoration(
              labelText: 'طريقة البيع',
              hintText: 'اختر طريقة البيع',
              hintStyle: const TextStyle(color: AppColors.black37),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            items: unitsCatalog
                .map((u) {
                  final name = (u['name'] ?? '').toString().trim();
                  final rate = (u['conversionRate'] ?? '').toString().trim();
                  final base = (u['base'] ?? '').toString().trim();
                  if (name.isEmpty) return '';
                  return '$name($rate $base)';
                })
                .where((str) => str.isNotEmpty)
                .toSet()
                .map((str) => DropdownMenuItem(value: str, child: Text(str)))
                .toList(),
            onChanged: (val) {
              setState(() => method['sellingMethod'] = val);
            },
          ),
        ),
        const SizedBox(width: 12),
        // Price field
        Expanded(
          flex: 2,
          child: _textField(
            method['priceCtrl'],
            'سعر البيع',
            keyboard: TextInputType.number,
          ),
        ),
        if (sellingMethods.length > 1) ...[
          const SizedBox(width: 6),
          IconButton(
            onPressed: () => _removeSellingMethod(stockIndex, index),
            icon: const Icon(Icons.close, size: 18, color: AppColors.black60),
            splashRadius: 18,
          ),
        ],
      ],
    );
  }

  void _addNewSellingMethod(int stockIndex) {
    final sellingMethods =
        stockEntries[stockIndex]['sellingMethods']
            as List<Map<String, dynamic>>;
    setState(() {
      sellingMethods.add(_createSellingMethodEntry());
    });
  }

  void _addNewStock() {
    setState(() {
      stockEntries.add(_createStockEntry());
    });
  }

  void _removeStock(int index) {
    final stock = stockEntries.removeAt(index);
    _disposeStockEntry(stock);
    setState(() {});
  }

  Map<String, dynamic> _createClassificationEntry() {
    return {
      'selectedClassification': null,
      'selectedClassificationValues': <String>[],
    };
  }

  Map<String, dynamic> _createStockEntry() {
    return {
      'unitNameCtrl': TextEditingController(),
      'classifications': [_createClassificationEntry()],
      'baseUnitCtrl': TextEditingController(),
      'quantityCtrl': TextEditingController(),
      'capacityCtrl': TextEditingController(),
      'totalPurchasePriceCtrl': TextEditingController(),
      'sellingMethods': [_createSellingMethodEntry()],
    };
  }

  Map<String, dynamic> _createSellingMethodEntry() {
    return {
      'sellingMethod': null,
      'priceCtrl': TextEditingController(),
    };
  }

  void _removeSellingMethod(int stockIndex, int index) {
    final sellingMethods =
        stockEntries[stockIndex]['sellingMethods']
            as List<Map<String, dynamic>>;
    final method = sellingMethods.removeAt(index);
    (method['priceCtrl'] as TextEditingController).dispose();
    setState(() {});
  }

  void _disposeStockEntry(Map<String, dynamic> stock) {
    (stock['unitNameCtrl'] as TextEditingController).dispose();
    (stock['baseUnitCtrl'] as TextEditingController).dispose();
    (stock['quantityCtrl'] as TextEditingController).dispose();
    (stock['capacityCtrl'] as TextEditingController).dispose();
    (stock['totalPurchasePriceCtrl'] as TextEditingController).dispose();

    final sellingMethods =
        stock['sellingMethods'] as List<Map<String, dynamic>>;
    for (final method in sellingMethods) {
      (method['priceCtrl'] as TextEditingController).dispose();
    }
  }

  // Step action buttons with navigation
  Widget _stepActionButtons(AddProductState state) => Directionality(
    textDirection: TextDirection.rtl,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Cancel button
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          ),
          child: const Text(
            "إلغاء",
            style: TextStyle(color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 20),

        // Submit button (final step only)
        if (currentStep == 1)
          ElevatedButton(
            onPressed: state is AddProductLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child:
                state is AddProductLoading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      "إضافة",
                      style: TextStyle(color: Colors.white),
                    ),
          ),

        // Next button (first step only)
        if (currentStep == 0)
          ElevatedButton(
            onPressed: _goToNextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text("متابعة", style: TextStyle(color: Colors.white)),
          ),
      ],
    ),
  );

  Future<void> _showAddUnitDialog(int stockIndex) async {
    final initialUnitName =
        (stockEntries[stockIndex]['unitNameCtrl'] as TextEditingController).text
            .trim();
    String? dialogUnitName =
        initialUnitName.isNotEmpty && unitsList.contains(initialUnitName)
            ? initialUnitName
            : null;
    final unitCapacityCtrl = TextEditingController();
    final initialBaseUnit =
        (stockEntries[stockIndex]['baseUnitCtrl'] as TextEditingController).text
            .trim();
    String? dialogCapacityUnit =
        initialBaseUnit.isNotEmpty &&
                capacityUnitsList.contains(initialBaseUnit)
            ? initialBaseUnit
            : null;
    bool isSubmitting = false;

    if (dialogUnitName == null && unitsList.isNotEmpty) {
      dialogUnitName = unitsList.first;
    }
    if (dialogCapacityUnit == null && capacityUnitsList.isNotEmpty) {
      dialogCapacityUnit = capacityUnitsList.first;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('إضافة وحدة جديدة'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            content: StatefulBuilder(
              builder: (context, setDialogState) {
                return SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: dialogUnitName,
                        decoration: InputDecoration(
                          hintText: 'اسم الوحدة',
                          hintStyle: const TextStyle(color: AppColors.black37),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        items:
                            unitsList.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                        onChanged: (val) {
                          setDialogState(() => dialogUnitName = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      _dialogTextField(
                        unitCapacityCtrl,
                        'السعة',
                        keyboard: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: dialogCapacityUnit,
                        decoration: InputDecoration(
                          hintText: 'الوحدة',
                          hintStyle: const TextStyle(color: AppColors.black37),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 217, 207, 207),
                            ),
                          ),
                        ),
                        items:
                            capacityUnitsList.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                        onChanged: (val) {
                          setDialogState(() => dialogCapacityUnit = val);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            actions: [
              StatefulBuilder(
                builder: (context, setDialogState) {
                  return SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                isSubmitting
                                    ? null
                                    : () async {
                                      if (dialogUnitName == null ||
                                          dialogUnitName!.trim().isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('اسم الوحدة مطلوب'),
                                          ),
                                        );
                                        return;
                                      }

                                      final conversionRate = num.tryParse(
                                        unitCapacityCtrl.text.trim(),
                                      );
                                      if (conversionRate == null ||
                                          conversionRate <= 0) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'السعة يجب أن تكون رقم أكبر من صفر',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      final unitObject =
                                          unitNameArToObject[dialogUnitName!
                                              .trim()] ??
                                          {
                                            'ar': dialogUnitName!.trim(),
                                            'en':
                                                dialogUnitName!
                                                    .trim() == 'قطعة' ? 'piece' : dialogUnitName!.trim().toLowerCase(),
                                          };
                                      final baseObject =
                                          baseUnitArToObject[(dialogCapacityUnit ??
                                                  '')
                                              .trim()] ??
                                          {
                                            'ar':
                                                (dialogCapacityUnit ?? '')
                                                    .trim(),
                                            'en':
                                                (dialogCapacityUnit ?? '').trim() == 'قطعة' ? 'piece' : (dialogCapacityUnit ?? '').trim().toLowerCase(),
                                          };

                                      if ((baseObject['en'] ?? '')
                                          .trim()
                                          .isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'الوحدة الأساسية مطلوبة',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      setDialogState(() => isSubmitting = true);

                                      try {
                                        final api =
                                            context
                                                .read<AddProductCubit>()
                                                .apiService;
                                        await api.createUnit(
                                          name: (unitObject['en'] ?? unitObject['name'] ?? dialogUnitName!).trim(),
                                          conversionRate: conversionRate,
                                          base: (baseObject['en'] ?? baseObject['base'] ?? dialogCapacityUnit!).trim(),
                                        );
                                        await _loadUnitsCatalog();

                                        if (!mounted) return;

                                        setState(() {
                                          final name =
                                              (unitObject['ar'] ?? unitObject['name'] ?? dialogUnitName!).trim();
                                          final rate =
                                              conversionRate.toString();
                                          final base =
                                              (baseObject['ar'] ?? baseObject['base'] ?? dialogCapacityUnit!).trim();
                                          final newUnitStr =
                                              '$name($rate $base)';

                                          (stockEntries[stockIndex]['unitNameCtrl']
                                                  as TextEditingController)
                                              .text = newUnitStr;
                                          _applyUnitFromCatalog(
                                            stockIndex,
                                            newUnitStr,
                                          );
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'تمت إضافة الوحدة بنجاح',
                                            ),
                                          ),
                                        );
                                        Navigator.pop(context);
                                      } catch (e) {
                                        if (!mounted) return;
                                        setDialogState(
                                          () => isSubmitting = false,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'فشل إضافة الوحدة: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child:
                                isSubmitting
                                    ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      'إضافة',
                                      style: TextStyle(color: Colors.white),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dialogTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
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

  void _goToNextStep() {
    if (_formKey.currentState!.validate()) {
      if (pickedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يجب إضافة صورة واحدة على الأقل")),
        );
        return;
      }
      setState(() => currentStep = 1);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final advProduct = <Map<String, String>>[];
      final maxLen =
          detailsArCtrls.length > detailsEnCtrls.length
              ? detailsArCtrls.length
              : detailsEnCtrls.length;

      for (int i = 0; i < maxLen; i++) {
        final ar =
            i < detailsArCtrls.length ? detailsArCtrls[i].text.trim() : '';
        final en =
            i < detailsEnCtrls.length ? detailsEnCtrls[i].text.trim() : '';
        if (ar.isNotEmpty || en.isNotEmpty) {
          advProduct.add({'ar': ar, 'en': en});
        }
      }

      final variantsDataList = <Map<String, dynamic>>[];
      for (final stock in stockEntries) {
        final unitStr = (stock['unitNameCtrl'] as TextEditingController).text.trim();
        Map<String, dynamic>? foundUnit;
        for (final u in unitsCatalog) {
          final uName = (u['name'] ?? '').toString().trim();
          final uRate = (u['conversionRate'] ?? '').toString().trim();
          final uBase = (u['base'] ?? '').toString().trim();
          if ('$uName($uRate $uBase)' == unitStr) {
            foundUnit = u;
            break;
          }
        }
        
        final qtyText = (stock['quantityCtrl'] as TextEditingController).text.trim();
        final priceText = (stock['totalPurchasePriceCtrl'] as TextEditingController).text.trim();
        
        final List<String> attrIds = [];
        final classifications = stock['classifications'] as List<dynamic>? ?? [];
        for (final cls in classifications) {
          final selectedCategoryName = cls['selectedClassification'] as String?;
          final selectedVals = cls['selectedClassificationValues'] as List<String>? ?? [];
          if (selectedCategoryName != null && selectedVals.isNotEmpty) {
            final catObj = attributesList.firstWhere(
              (a) => a['name'] == selectedCategoryName,
              orElse: () => <String, dynamic>{},
            );
            final cVals = catObj['values'] as List<dynamic>? ?? [];
            for (final selectedVal in selectedVals) {
              for (final v in cVals) {
                if (v is Map) {
                  final vName = (v['value'] ?? v['name'] ?? '').toString();
                  if (vName == selectedVal && v['_id'] != null) {
                    attrIds.add(v['_id'].toString());
                  }
                }
              }
            }
          }
        }
        
        final sellingMethodsList = stock['sellingMethods'] as List<dynamic>? ?? [];
        final List<Map<String, dynamic>> subVariants = [];
        for (final sm in sellingMethodsList) {
          final smUnitStr = sm['sellingMethod'] as String?;
          final smPriceText = (sm['priceCtrl'] as TextEditingController).text.trim();
          
          if (smUnitStr != null) {
             Map<String, dynamic>? smFoundUnit;
             for (final u in unitsCatalog) {
               final uName = (u['name'] ?? '').toString().trim();
               final uRate = (u['conversionRate'] ?? '').toString().trim();
               final uBase = (u['base'] ?? '').toString().trim();
               if ('$uName($uRate $uBase)' == smUnitStr) {
                 smFoundUnit = u;
                 break;
               }
             }
             if (smFoundUnit != null && smFoundUnit['_id'] != null) {
               subVariants.add({
                 "unitId": smFoundUnit['_id'],
                 "price": num.tryParse(smPriceText) ?? 0,
               });
             }
          }
        }

        if (foundUnit != null && foundUnit['_id'] != null) {
          variantsDataList.add({
            "unitId": foundUnit['_id'],
            "quantity": num.tryParse(qtyText) ?? 0,
            "purchasePrice": num.tryParse(priceText) ?? 0,
            "warehouseLoc": {
              "en": "A1",
              "ar": "ا1"
            },
            "attributeValueIds": attrIds,
            "variants": subVariants
          });
        }
      }

      context.read<AddProductCubit>().addProduct(
        nameAr: nameCtrl.text.trim(),
        nameEn: nameEnCtrl.text.trim(),
        categoryAr: catCtrl.text.trim(),
        categoryEn: catEnCtrl.text.trim(),
        descriptionAr: descCtrl.text.trim(),
        descriptionEn: descEnCtrl.text.trim(),
        advProduct: advProduct,
        imageBytesList: pickedImages,
        variantsDataList: variantsDataList,
      );
    }
  }

  Widget _textField(
    TextEditingController c,
    String hint, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool required = false,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
    TextDirection? textDirection,
  }) {
    final isLtr = textDirection == TextDirection.ltr;
    return Directionality(
      textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        maxLines: maxLines,
        readOnly: readOnly,
        onChanged: onChanged,
        textDirection: textDirection,
        textAlign: isLtr ? TextAlign.left : TextAlign.start,
        validator:
            required
                ? (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null
                : null,
        decoration: InputDecoration(
          hintText: hint,
          alignLabelWithHint: true,
          hintStyle: const TextStyle(color: AppColors.black37),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}

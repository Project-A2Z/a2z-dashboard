// ignore_for_file: unused_element

import 'dart:io';

import 'package:disctop_app/core/widgets/dount_chart.dart';
import 'package:disctop_app/core/widgets/header_admin.dart';
import 'package:disctop_app/core/widgets/line_chart.dart';
import 'package:disctop_app/core/widgets/pagination_control.dart';
import 'package:disctop_app/core/widgets/sidebar_widget_admin.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/control_cubit/control_cubit.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/control_cubit/control_state.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/expenses_cubit/expenses_cubit.dart';
import 'package:disctop_app/features/admin_dashboard/presintation/expens/add_expense_screen.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/payments_cubit/payment_model.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/payments_cubit/payment_state.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:disctop_app/core/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String selectedKey = "المصروفات";
  String searchQuery = '';
  int rowsPerPage = 7;
  int currentPage = 1;
@override
void initState() {
  super.initState();
  context.read<PaymentCubit_expenses>().fetchPayments();
  context.read<ProfitCubit>().fetchProfits();
}

Future<void> _printReport(List<PaymentModel> payments) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Table.fromTextArray(
          headers: ["رقم العملية", "المبلغ", "تاريخ الطلب", "طريقة الدفع"],
          data: payments.map((p) {
            final paymentWay = _translatePaymentWay(p.paymentWay);
            
            return [
              p.numOperation ?? p.orderId,
              p.totalPrice.toStringAsFixed(0),
              p.createdAt.substring(0, 10),
              paymentWay,
              
            ];
          }).toList(),
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}


Future<void> _exportToExcel(List<PaymentModel> payments) async {
  try {
    final excel = Excel.createExcel();
    const sheetName = 'الإيرادات';
    excel.rename(excel.getDefaultSheet()!, sheetName);
    final Sheet sheetObject = excel[sheetName];

    
    final headers = ["رقم العملية", "المبلغ", "تاريخ الطلب", "طريقة الدفع"];
    for (int i = 0; i < headers.length; i++) {
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
    }

    
    for (int i = 0; i < payments.length; i++) {
      final p = payments[i];
      final paymentWay = _translatePaymentWay(p.paymentWay);
      

      final values = [
        p.numOperation ?? p.orderId,
        p.totalPrice.toStringAsFixed(0),
        (p.createdAt.length >= 10 ? p.createdAt.substring(0, 10) : p.createdAt),
        paymentWay,
        
      ];

      for (int j = 0; j < values.length; j++) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
            .value = TextCellValue(values[j].toString());
      }
    }

    
    final bytes = excel.encode();
    if (bytes == null) return;

    final now = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(now);
    final filename = 'expenses_$formattedDate.xlsx';

    
    Directory? directory;
    if (Platform.isAndroid || Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getDownloadsDirectory();
    }

    final filePath = '${directory!.path}/$filename';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ الملف بنجاح في: $filePath'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('حدث خطأ أثناء التصدير: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  

  String _translatePaymentWay(String paymentWay) {
    switch (paymentWay.toLowerCase()) {
      case 'cash':
      case 'كاش':
        return 'كاش';
      case 'online':
      case 'اونلاين':
        return 'اونلاين';
      default:
        return paymentWay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Expanded(
            child: BlocBuilder<ProfitCubit, ProfitState>(
              builder: (context, state) {
                if (state is ProfitLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary,));
                } else if (state is ProfitError) {
                  return Center(child: Text(state.message));
                } else if (state is ProfitLoaded) {
                  final data = state.profitData;

                  final monthlyStats = data.monthlyStatistics.length > 12
                      ? data.monthlyStatistics.sublist(
                          data.monthlyStatistics.length - 12,
                        )
                      : data.monthlyStatistics;

                  final monthlySpots = monthlyStats
                      .asMap()
                      .entries
                      .map((e) => FlSpot(
                            e.key.toDouble(),
                            e.value.expenses.toDouble(),
                          ))
                      .toList();

                  final monthLabels = monthlyStats.map((e) => e.monthName).toList();

                  return Padding(
                    padding: EdgeInsets.all(width * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DashboardHeader_admin(title: "المصروفات"),
                        const SizedBox(height: 24),

                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                               OutlinedButton.icon(
  onPressed: () async {
    final paymentState = context.read<PaymentCubit_expenses>().state;
    if (paymentState is PaymentLoaded) {
      await _exportToExcel(paymentState.payments);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('البيانات غير جاهزة للتصدير')),
      );
    }
  },
  icon: const Icon(Icons.upload_file),
  label: Text(
    "تصديرها كملف اكسل",
    style: TextStyle(color: AppColors.primary),
  ),
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: AppColors.primary),
    iconColor: AppColors.primary,
  ),
),

                                const SizedBox(width: 10),
                                
OutlinedButton.icon(
  onPressed: () async {
    try {
      final paymentState = context.read<PaymentCubit_expenses>().state;
      
      if (paymentState is! PaymentLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('البيانات غير جاهزة للطباعة')),
        );
        return;
      }

      final payments = paymentState.payments;
      final pdf = pw.Document();

      
      final fontData = await rootBundle.load("assets/fonts/Cairo/static/Cairo-Regular.ttf");
      final ttf = pw.Font.ttf(fontData);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                
                pw.Center(
                  child: pw.Text(
                    'تقرير المصروفات',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                
                pw.Text(
                  'التاريخ: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                  style: pw.TextStyle(font: ttf, fontSize: 12),
                ),
                pw.SizedBox(height: 20),

                
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        _buildTableCell('رقم العملية', ttf, isHeader: true),
                        _buildTableCell('المبلغ', ttf, isHeader: true),
                        _buildTableCell('التاريخ', ttf, isHeader: true),
                        _buildTableCell('طريقة الدفع', ttf, isHeader: true),
                      ],
                    ),
                    
                    ...payments.map((p) {
                      final paymentWay = _translatePaymentWay(p.paymentWay);
                      
                      return pw.TableRow(
                        children: [
                          _buildTableCell(p.numOperation ?? p.orderId, ttf),
                          _buildTableCell(p.totalPrice.toStringAsFixed(0), ttf),
                          _buildTableCell(
                            p.createdAt.length >= 10
                                ? p.createdAt.substring(0, 10)
                                : (p.createdAt),
                            ttf,
                          ),
                          _buildTableCell(paymentWay, ttf),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      
      final bytes = await pdf.save();
      
      if (Platform.isAndroid || Platform.isIOS) {
        
        final dir = await getApplicationDocumentsDirectory();
        final file = File("${dir.path}/expenses_report.pdf");
        await file.writeAsBytes(bytes);
        await OpenFilex.open(file.path);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء وفتح التقرير بنجاح')),
          );
        }
      } else {
        
        await Printing.layoutPdf(
          onLayout: (format) async => bytes,
        );
      }
    } catch (e) {
      debugPrint('Print error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء إنشاء الملف: $e')),
        );
      }
    }
  },
  icon: const Icon(Icons.print_outlined),
  label: Text(
    "طباعة التقرير",
    style: TextStyle(color: AppColors.primary),
  ),
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: AppColors.primary),
    iconColor: AppColors.primary,
  ),
)

                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: height * 0.02),

                        
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.only(top: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: AppColors.black8),
                                  ),
                                  child: Column(
                                    children: [
                                      
                                      Column(
                                        children: [
                                          Text(
                                            "${data.expenses.totalAmount}",
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          Text(
                                            "اجمالي المصروفات",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.black60,
                                            ),
                                          ),
                                        ],
                                      ),
                                
                                      SizedBox(height: height * 0.03),
                                
                                      
                                      LineChartWidget(
                                        title: "المصروفات",
                                        spots: monthlySpots,
                                        labels: monthLabels,
                                      ),
                                
                                      SizedBox(height: height * 0.03),
                                
                                      
                                      PaymentMethodsChart(
                                        cashPercent: data.expenses.cashCount,
                                        onlinePercent: data.expenses.onlineCount,
                                      ),
                                
                                    ],
                                  ),
                                ),
                                
                                  
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: BlocBuilder<PaymentCubit_expenses, PaymentState>(
                                      builder: (context, paymentState) {
                                        if (paymentState is PaymentLoading) {
                                          return const Padding(
                                            padding: EdgeInsets.all(20),
                                            child: CircularProgressIndicator(color: AppColors.primary),
                                          );
                                        }
                                    
                                        if (paymentState is PaymentError) {
                                          return Center(
                                            child: Text('حدث خطأ: ${paymentState.message}'),
                                          );
                                        }
                                    
                                        if (paymentState is PaymentLoaded) {
                                          var payments = paymentState.payments;

                                         payments =  _applyFilters(payments);

                                          
                                    
                                          final totalPages = (payments.length / rowsPerPage).ceil().clamp(1, double.infinity).toInt();
                                          currentPage = currentPage.clamp(1, totalPages);
                                    
                                          final startIndex = (currentPage - 1) * rowsPerPage;
                                          final endIndex = (startIndex + rowsPerPage).clamp(0, payments.length);
                                          final currentPageItems = payments.sublist(startIndex, endIndex);
                                    
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 24),
                                            child: Column(
                                              children:[
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children:[ _buildSearchField(),
                                                ElevatedButton(onPressed: (){
                                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> AddExpenseScreen()));
                                                },style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,), child: Row(children: [
                                                  Icon(Icons.add_circle_outline,color: Colors.white,),
                                                  SizedBox(width: 5,),
                                                  Text("اضافة نفقة",style: TextStyle(color:Colors.white),),
                                                  
                                                ],))
                                                ]),
                                                SizedBox(height: 10,),
                                                 _buildDataTable(currentPageItems),
                                              
                                              PaginationControls(
                                    currentPage: currentPage - 1,
                                    totalPages: totalPages,
                                    totalItems: payments.length,
                                    displayedStart:
                                        startIndex + 1, 
                                    displayedEnd: endIndex,
                                    onNext:
                                        currentPage < totalPages
                                            ? () => setState(() => currentPage++)
                                            : null,
                                    onPrevious:
                                        currentPage > 1
                                            ? () => setState(() => currentPage--)
                                            : null,
                                                                    ),]),
                                          );
                                          
                                        }
                                    
                                        return const SizedBox();
                                      },
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

                return const SizedBox();
              },
            ),
          ),

          
          Sidebar_Admin(selectedKey: selectedKey),
        ],
      ),
    );
  }

  
  Widget _buildDataTable(List<PaymentModel> payments) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowHeight: 56,
              dataRowHeight: 64,
              columnSpacing: 20,
              headingRowColor: MaterialStateProperty.all(
                AppColors.primary,
              ),
              headingTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              dataTextStyle: const TextStyle(
                color: Color(0xFF424242),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              columns: const [
                DataColumn(
                  label: Expanded(
                    child: Text(
                      "رقم العملية",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                DataColumn(
                  label: Expanded(
                    child: Text(
                      "المبلغ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      "تاريخ الطلب",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      "طريقة الدفع",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
              ],
              rows:
                  payments.map((p) {
                    if(p.paymentStatus.toLowerCase()=="paid"){
                    }else if(p.paymentStatus.toLowerCase()=="deposit"){
                    }else if(p.paymentStatus.toLowerCase()=="refunded"){
                    }
                    else if(p.paymentStatus.toLowerCase()=="cancelled"){
                    }else{
                    }
                    
                    final paymentWay = _translatePaymentWay(p.paymentWay);

                    return DataRow(
                      cells: [
                        DataCell(
                          Center(
                            child: Text(
                              p.numOperation ?? p.orderId,
                              style: TextStyle(
                                color: AppColors.black60,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        
                        DataCell(
                          Center(
                            child: Text(
                              '${p.totalPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: AppColors.black60,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              p.createdAt.substring(0, 10),
                              style: TextStyle(
                                color: AppColors.black60,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              paymentWay,
                              style: TextStyle(
                                color: AppColors.black60,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
    
  }
  

pw.Widget _buildTableCell(String text, pw.Font font, {bool isHeader = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        font: font,
        fontSize: isHeader ? 12 : 10,
        fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}
  Widget _buildSearchField() {
    return SizedBox(
      width: 340,
      child: TextField(
        decoration: InputDecoration(
          hintText: "بحث",
          hintStyle: const TextStyle(color: AppColors.black37, fontSize: 16),
          suffixIcon: const Icon(
            Icons.search_outlined,
            color: AppColors.black37,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 25),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.black16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.black16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.black16, width: 1.5),
          ),
        ),
        onChanged:
            (v) => setState(() {
              searchQuery = v;
              currentPage = 1;
            }),
      ),
    );
    
  }
  

List<PaymentModel> _applyFilters(List<PaymentModel> payments) {
  
    if (searchQuery.isNotEmpty) {
      payments =
          payments.where((p) {
            final name =
                '${p.user?['firstName'] ?? ''} ${p.user?['lastName'] ?? ''}'
                    .toLowerCase();
            final query = searchQuery.toLowerCase();
            return name.contains(query) ||
                p.orderId.toLowerCase().contains(query) ||
                (p.numOperation ?? '').toLowerCase().contains(query);
          }).toList();
    }
    return payments;
    }

  }

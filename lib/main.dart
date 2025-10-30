import 'package:disctop_app/features/admin_dashboard/cubit/control_cubit/control_cubit.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/customers_cubit/customers_cubit.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/expenses_cubit/expenses_cubit.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/add_or_edit_operation_cubit.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/operations_cubit/operations_cubit.dart';
import 'package:disctop_app/features/admin_dashboard/cubit/revenue_cubit/revenue_cubit.dart';
import 'package:disctop_app/features/admin_dashboard/presintation/control/control_screen.dart';
import 'package:disctop_app/features/admin_dashboard/presintation/customers/customers_screen.dart';
import 'package:disctop_app/features/admin_dashboard/presintation/expens/expenses_screen.dart';
import 'package:disctop_app/features/admin_dashboard/presintation/operations/all_operations_screen.dart';
import 'package:disctop_app/features/admin_dashboard/presintation/profit/profit_screen.dart';
import 'package:disctop_app/features/admin_dashboard/presintation/revenue/revenue_screen.dart';
import 'package:disctop_app/features/auth/auth_repository/auth_repository_impl.dart';
import 'package:disctop_app/features/auth/auth_repository/login_usecaes.dart';
import 'package:disctop_app/features/auth/cubit/cubit_login..dart';
import 'package:disctop_app/features/auth/cubit/otp_cubit.dart';
import 'package:disctop_app/features/auth/presintation/login_screen.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/inquirey_cubit/inquirey_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/notification_cubit/notification_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/orders_cubit/order_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/payments_cubit/payment_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/add_product_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/product_cubit/product_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/operation_cubit/reviews_cubit/reviews_cubit.dart';
import 'package:disctop_app/features/operation_dashboard/presintation/inquirey/inquirey_screen.dart';
import 'package:disctop_app/features/operation_dashboard/presintation/orders/orders_screen.dart';
import 'package:disctop_app/features/operation_dashboard/presintation/payment/payment_screen.dart';
import 'package:disctop_app/features/operation_dashboard/presintation/product/products_screen.dart';
import 'package:disctop_app/features/operation_dashboard/presintation/review/review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/api_service.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
 
  await initializeDateFormatting('ar', null);

  final api = ApiService();
  final repo = AuthRepositoryImpl(api);
  
  runApp(MyApp(api: api, repo: repo));
}

class MyApp extends StatelessWidget {
  final ApiService api;
  final AuthRepositoryImpl repo;
  const MyApp({super.key, required this.repo, required this.api});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value( 
      value: api,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LoginCubit(LoginUseCase(repo))),
          BlocProvider(create: (context) => AddProductCubit(context.read<ApiService>())),
          BlocProvider(create: (context) => ProductsCubit(context.read<ApiService>())..fetchProducts()),
          BlocProvider(create: (context) => OrdersCubit(context.read<ApiService>())),
          BlocProvider(create: (context) => InquiryCubit(context.read<ApiService>())..fetchInquiries()),
          BlocProvider(create: (context) => PaymentCubit(context.read<ApiService>())..fetchPayments()),
          BlocProvider(create: (context) => ReviewsCubit(context.read<ApiService>())),
          BlocProvider(create: (context) => ProfitCubit(context.read<ApiService>())),
          BlocProvider(create: (context) => CustomersCubit(context.read<ApiService>())),
          BlocProvider(create: (context) => PaymentCubit_revenue(context.read<ApiService>())),
          BlocProvider(create: (context) => PaymentCubit_expenses(context.read<ApiService>())),
          BlocProvider(create: (context) => OperationsCubit(context.read<ApiService>())),
          BlocProvider(create: (context) => AddOrEditEmployeeCubit(context.read<ApiService>())),
          BlocProvider(create: (context) => OtpCubit(context.read<ApiService>())),
          BlocProvider(create: (context) => OperationNotificationCubit(context.read<ApiService>())),
        ],
        
        child: MaterialApp(
          theme: ThemeData(
            textTheme: GoogleFonts.beirutiTextTheme()
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: '/login',
          routes: {
            '/login': (_) => const LoginScreen(),
            '/dashboard': (_) => const AdminDashboard(),
            '/revenues': (_) => const RevenuesPage(),
            '/expenses': (_) => const ExpensesScreen(),
            '/profits': (_) => const ProfitsScreen(),
            '/employees': (_) => const OperationsScreen(),
            '/clients': (_) => const CustomersScreen(),
            '/products': (_) => const ProductsScreen(),
            '/orders': (_) => const OrdersScreen(),
            '/payment': (_) => const PaymentsScreen(),
            '/review': (_) => const ReviewsScreen(),
            '/connect': (_) => const InquiriesScreen(),
          },
        ),
      ),
    );
  }
}

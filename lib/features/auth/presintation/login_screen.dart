import 'package:dio/dio.dart';
import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/features/admin_dashboard/presintation/control/control_screen.dart';
import 'package:disctop_app/features/auth/cubit/cubit_login..dart';
import 'package:disctop_app/features/auth/cubit/cubit_state.dart';
import 'package:disctop_app/features/auth/presintation/otp_screen.dart';
import 'package:disctop_app/features/operation_dashboard/presintation/product/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isButtonEnabled = false;
  String? _errorMessage; 

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateInputs);
    _passwordController.addListener(_validateInputs);
  }

  void _validateInputs() {
    setState(() {
      _isButtonEnabled =
          _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          } else if (state is LoginSuccess) {
            
            Navigator.pop(context);
            setState(() {
              _errorMessage = null;
            });
          
            if (state.role == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboard()),
              );
            } else if (state.role == 'operation') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProductsScreen()),
              );
            }
          } else if (state is LoginFailure) {
            Navigator.pop(context);
            
            setState(() {
              _errorMessage = "البريد الإلكتروني أو كلمة المرور غير صحيحة";
            });
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {

            return Stack(
              children: [
                
                Positioned(top: -50, left: 300, child: _buildCircle(350)),
                Positioned(bottom: -10, right: 10, child: _buildCircle(350)),
                Positioned(bottom: -100, left: 150, child: _buildCircle(350)),

                
                Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 850),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 32),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(232, 244, 244, 1),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(201, 238, 234, 234),
                              blurRadius: 0,
                              
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            
                            Image.asset("assets/images/logo.png", height: 60),
                            const SizedBox(height: 16),

                            const Text(
                              "تسجيل الدخول",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 24),

                            
                            _buildTextField(
                              controller: _emailController,
                              hint: "البريد الإلكتروني",
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),

                            
                            _buildTextField(
                              controller: _passwordController,
                              hint: "كلمة المرور",
                              obscure: _obscurePassword,
                              preifix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.black45,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
Align(
  alignment: Alignment.centerLeft,
  child: TextButton(
    onPressed: () async {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        setState(() {
              _errorMessage = "من فضلك ادخل البريد الالكتروني ";
            });
        return;
      }

      try {
        final dio = Dio();
        final response = await dio.post(
          'https://a2z-backend.fly.dev/app/v1/users/forgetPassword',
          data: {"email": email},
        );

        if (response.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(email: email),
            ),
          );
        } else {
          setState(() {
              _errorMessage = "ادخل البريد الالكتروني و كلمة المرور";
            });
        }
      } on DioException {
        setState(() {
              _errorMessage = "ادخل البريد الالكتروني بشكل صحيح";
            });
      }
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          "نسيت كلمة المرور ؟",
          style: TextStyle(
            color: AppColors.black37,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    ),
  ),
),


                            
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 24),

                            
                            SizedBox(
                              width: 172,
                              height: 43,
                              child: ElevatedButton(
                                onPressed: _isButtonEnabled
                                    ? () {
                                        context.read<LoginCubit>().login(
                                              _emailController.text.trim(),
                                              _passwordController.text.trim(),
                                            );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isButtonEnabled
                                      ? AppColors.primary
                                      : AppColors.disabled,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "تسجيل الدخول",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? preifix,
    TextInputAction? textInputAction,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      textAlign: TextAlign.right,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.black37,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        fillColor: const Color.fromARGB(62, 255, 255, 255),
        filled: true,
        prefixIcon: preifix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(color: AppColors.black16),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(color: AppColors.black16),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }

  Widget _buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color.fromRGBO(162, 183, 159, 0.018),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(44, 199, 220, 183).withOpacity(0.8),
            blurRadius: 20,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

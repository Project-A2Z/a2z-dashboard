import 'package:dio/dio.dart';
import 'package:disctop_app/features/auth/presintation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:disctop_app/core/app_colors.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  bool loading = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  String? errorText;

  Future<void> resetPassword() async {
    if (newPassword.text != confirmPassword.text) {
      setState(() {
        errorText = 'كلمتا المرور غير متطابقتين';
      });
      return;
    }

    setState(() {
      errorText = null;
      loading = true;
    });

    try {
      final dio = Dio();
      final response = await dio.patch(
        'https://a2z-backend.fly.dev/app/v1/users/ResetPassword',
        data: {
          "email": widget.email,
          "Newpassword": newPassword.text,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          errorText = null;
        });
          Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => LoginScreen()), // خلي LoginScreen موجود عندك
  );
     
        
      } else {
        setState(() {
          errorText = 'فشل العملية (${response.statusCode})';
        });
      }
    } on DioException {
      setState(() {
        errorText = "ادخل كلمة المرور الجديدة";
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    newPassword.addListener(() => setState(() {}));
    confirmPassword.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(top: -50, left: 300, child: _buildCircle(350)),
          Positioned(bottom: -10, right: 10, child: _buildCircle(350)),
          Positioned(bottom: -100, left: 150, child: _buildCircle(350)),
          Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 850),
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(232, 244, 244, 1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/images/logo.png", height: 60),
                    const SizedBox(height: 16),
                    const Text(
                      "أدخل كلمة المرور الجديدة",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(newPassword, "أدخل كلمة المرور الجديدة", showNewPassword, () {
                      setState(() => showNewPassword = !showNewPassword);
                    }),
                    const SizedBox(height: 12),
                    _buildTextField(confirmPassword, "تأكيد كلمة المرور الجديدة", showConfirmPassword, () {
                      setState(() => showConfirmPassword = !showConfirmPassword);
                    }),
                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(errorText!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
  width: 160,
  height: 45,
  child: ElevatedButton(
    onPressed:  resetPassword ,
    style: ElevatedButton.styleFrom(
      backgroundColor:  AppColors.primary ,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
    ),
    child: loading
        ? const CircularProgressIndicator(color: Colors.white)
        : const Text("متابعة", style: TextStyle(color: Colors.white)),
  ),
),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool showPassword,
    VoidCallback toggleShow,
  ) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
        controller: controller,
        obscureText: !showPassword,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color.fromARGB(180, 253, 247, 247),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: AppColors.black16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: AppColors.black16),
          ),
          suffixIcon: IconButton(
            icon: Icon(showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: toggleShow,
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(162, 183, 159, 0.018),
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

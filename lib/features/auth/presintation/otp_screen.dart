import 'dart:async';
import 'package:disctop_app/core/app_colors.dart';
import 'package:disctop_app/features/auth/cubit/opt_state.dart';
import 'package:disctop_app/features/auth/cubit/otp_cubit.dart';
import 'package:disctop_app/features/auth/presintation/rest_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  int seconds = 60;
  Timer? timer;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    seconds = 60;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        t.cancel();
      }
    });
  }

  String getOtpCode() {
    return controllers.map((c) => c.text).join();
  }

  void verifyOtp(BuildContext context) {
    final code = getOtpCode();
    if (code.length < 6) {
      setState(() {
        errorMessage = 'من فضلك أدخل رمز التحقق بالكامل';
      });
      return;
    }
    setState(() => errorMessage = null);
    context.read<OtpCubit>().verifyOtp(widget.email, code);
  }

  void resendOtp(BuildContext context) {
    if (seconds == 0) {
      startTimer();
      context.read<OtpCubit>().resendOtp(widget.email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<OtpCubit, OtpState>(
        listener: (context, state) {
          if (state is OtpSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ResetPasswordScreen(email: widget.email),
              ),
            );
          } else if (state is OtpError) {
            setState(() {
              errorMessage = "خطأ في رمز التحقق";
            });
          } else if (state is OtpResent) {
            setState(() {
              errorMessage = "تم إرسال الرمز مجددًا";
            });
          }
        },
        builder: (context, state) {
          bool loading = state is OtpLoading;

          return Stack(
            children: [
              Positioned(top: -50, left: 300, child: _buildCircle(350)),
              Positioned(bottom: -10, right: 10, child: _buildCircle(350)),
              Positioned(bottom: -100, left: 150, child: _buildCircle(350)),

              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 850),
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 32),
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
                        "رجاء إدخال رمز التحقق المرسل إلى بريدك الإلكتروني",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: List.generate(6, (i) {
    return Container(
      width: 45,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          // لما المستخدم يضغط Backspace
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            if (controllers[i].text.isEmpty && i > 0) {
              // لو الخانة الحالية فاضية، نرجع للخانة اللي قبلها ونمسحها
              controllers[i - 1].clear();
              focusNodes[i - 1].requestFocus();
            }
          }
        },
        child: TextField(
          controller: controllers[i],
          focusNode: focusNodes[i],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (val) {
            if (val.isNotEmpty && i < 5) {
              FocusScope.of(context).requestFocus(focusNodes[i + 1]);
            } else if (val.isEmpty && i > 0) {
              FocusScope.of(context).requestFocus(focusNodes[i - 1]);
            }
          },
          onTap: () => setState(() {
            errorMessage = null;
          }),
        ),
      ),
    );
  }),
),


                      const SizedBox(height: 25),

                      // Verify Button
                      SizedBox(
                        width: 170,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: loading ? null : () => verifyOtp(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  "تحقق",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Resend text
                      GestureDetector(
                        onTap: () => resendOtp(context),
                        child: Text(
                          seconds == 0
                              ? "إعادة إرسال الرمز الآن"
                              : "إعادة إرسال بعد: 00:${seconds.toString().padLeft(2, '0')}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),

                      // Error text under timer
                      if (errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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

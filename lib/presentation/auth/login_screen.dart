import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/auth/auth_provider.dart';
import '../../core/router/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(WidgetRef ref) {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Consumer(
        builder: (context, ref, child) {
          // Listen to state errors
          ref.listen(authProvider, (previous, next) {
            if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(next.errorMessage!),
                  backgroundColor: const Color(0xFFE94560),
                ),
              );
            }
          });

          final authState = ref.watch(authProvider);

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // House icon logo centered
                      const Center(
                        child: Icon(
                          Icons.home_work_outlined,
                          size: 80,
                          color: Color(0xFFE94560),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // App name "The House Wins"
                      const Text(
                        'The House Wins',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF5F5F5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle "Mô phỏng cá cược · Không tiền thật"
                      const Text(
                        'Mô phỏng cá cược · Không tiền thật',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 14,
                          color: Color(0xFFA0A0B0),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Card wrapper for inputs
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF0F3460)),
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email',
                              style: TextStyle(
                                color: Color(0xFFF5F5F5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Color(0xFFF5F5F5)),
                              decoration: InputDecoration(
                                hintText: 'Nhập địa chỉ email của bạn',
                                hintStyle: const TextStyle(color: Color(0xFFA0A0B0)),
                                filled: true,
                                fillColor: const Color(0xFF1A1A2E),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Vui lòng nhập email';
                                }
                                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                if (!emailRegex.hasMatch(value.trim())) {
                                  return 'Email không hợp lệ';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Mật khẩu',
                                  style: TextStyle(
                                    color: Color(0xFFF5F5F5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.push(AppRoutes.forgot),
                                  child: const Text(
                                    'Quên mật khẩu?',
                                    style: TextStyle(
                                      color: Color(0xFFA0A0B0),
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Color(0xFFF5F5F5)),
                              decoration: InputDecoration(
                                hintText: 'Nhập mật khẩu',
                                hintStyle: const TextStyle(color: Color(0xFFA0A0B0)),
                                filled: true,
                                fillColor: const Color(0xFF1A1A2E),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: const Color(0xFFA0A0B0),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Large red button "Đăng nhập"
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE94560),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: authState.isLoading ? null : () => _submit(ref),
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF5F5F5),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Text link "Chưa có tài khoản? Đăng ký"
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.register),
                        child: const Text.rich(
                          TextSpan(
                            text: 'Chưa có tài khoản? ',
                            style: TextStyle(color: Color(0xFFA0A0B0), fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Đăng ký',
                                style: TextStyle(
                                  color: Color(0xFFE94560),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

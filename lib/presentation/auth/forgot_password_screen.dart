import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/auth/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit(WidgetRef ref) {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).resetPassword(
            _emailController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF5F5F5)),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final authState = ref.watch(authProvider);
          final isSuccess = authState.errorMessage == "Email đã được gửi. Kiểm tra hộp thư của bạn";

          // Listen to state changes to show generic errors via SnackBar if it is NOT the success message
          ref.listen(authProvider, (previous, next) {
            if (next.errorMessage != null &&
                next.errorMessage != previous?.errorMessage &&
                next.errorMessage != "Email đã được gửi. Kiểm tra hộp thư của bạn") {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(next.errorMessage!),
                  backgroundColor: const Color(0xFFE94560),
                ),
              );
            }
          });

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      const Text(
                        'Quên mật khẩu',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF5F5F5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Vui lòng nhập email đăng ký. Chúng tôi sẽ gửi liên kết để bạn thiết lập lại mật khẩu.',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 14,
                          color: Color(0xFFA0A0B0),
                        ),
                      ),
                      const SizedBox(height: 32),

                      if (isSuccess) ...[
                        // Success state indicator
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16213E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF00D4AA)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.check_circle_outline, color: Color(0xFF00D4AA), size: 48),
                              SizedBox(height: 12),
                              Text(
                                'Email đã được gửi. Kiểm tra hộp thư của bạn',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00D4AA),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        // Input card
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Action Button "Gửi email đặt lại mật khẩu"
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
                                    'Gửi email đặt lại mật khẩu',
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
                      ],
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

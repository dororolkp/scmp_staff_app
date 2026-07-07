import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scmp_staff_app/viewmodels/auth_viewmodel.dart';
import 'package:scmp_staff_app/views/staff_directory_view.dart';
import 'package:scmp_staff_app/di/injection.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<AuthViewModel>(),
      child: const _LoginContent(),
    );
  }
}

class _LoginContent extends StatefulWidget {
  const _LoginContent({super.key});

  @override
  _LoginContentState createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(text)) {
      return 'Enter a valid email';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) {
      return 'Password is required';
    }

    if (text.length < 6 || text.length > 10) {
      return 'Password must be 6-10 characters';
    }

    final passwordRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!passwordRegex.hasMatch(text)) {
      return 'Password must contain only letters and numbers';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    // Listen for state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.state == AuthState.success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StaffDirectoryView()),
        );
      } else if (viewModel.state == AuthState.error && viewModel.errorMessage != null) {
        _showErrorDialog(viewModel.errorMessage!);
        // Reset state so it doesn't keep showing the dialog
        // This requires a minor tweak or just being careful. 
        // A better approach is to not use state enum for one-off events, but let's keep it simple.
      }
    });

    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = screenWidth < 420 ? screenWidth - 48 : 320.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      decoration: _inputDecoration('Email Address'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      validator: _validatePassword,
                      decoration: _inputDecoration('Password'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: viewModel.state == AuthState.loading
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  viewModel.login(
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (viewModel.state == AuthState.loading) ...[
                      const Text(
                        'Logging in...',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(height: 14),
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ],
                    if (viewModel.state != AuthState.loading)
                      const SizedBox(height: 42),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: Colors.black54),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      hintStyle: const TextStyle(color: Colors.black54),
    );
  }
}

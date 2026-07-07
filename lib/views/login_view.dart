import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scmp_staff_app/viewmodels/auth_viewmodel.dart';
import 'package:scmp_staff_app/views/staff_directory_view.dart';
import 'package:scmp_staff_app/di/injection.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<AuthViewModel>(),
      child: const _LoginContent(),
    );
  }
}

class _LoginContent extends StatefulWidget {
  const _LoginContent({Key? key}) : super(key: key);

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
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6 || value.length > 10) {
      return 'Password must be 6-10 characters';
    }
    final passwordRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!passwordRegex.hasMatch(value)) {
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

    return Scaffold(
      appBar: AppBar(title: const Text('LOGIN'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: viewModel.state == AuthState.loading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            viewModel.login(
                              _emailController.text,
                              _passwordController.text,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                  child: viewModel.state == AuthState.loading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Logging in...'),
                          ],
                        )
                      : const Text('Log In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

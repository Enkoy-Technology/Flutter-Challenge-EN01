import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'chat_list_screen.dart';
import '../theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      User? user;

      if (_isLogin) {
        user = await authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        user = await authService.registerWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
      }

      if (user != null && mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          if (_isLogin) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            );
          } else {
            Navigator.of(context).pushReplacementNamed('/login');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Registration successful! Login to continue.'),
                  backgroundColor: AppColors.green),
            );
          }
        }
        return;
      }

      if (mounted && user == null) {
        final authServiceCheck = ref.read(authServiceProvider);
        final checkUser = authServiceCheck.currentUser;
        if (checkUser != null && mounted) {
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            );
          }
          return;
        }
      }
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('PigeonUserDetails') ||
          errorStr.contains('List<Object?>') ||
          errorStr.contains('type cast')) {
        await Future.delayed(const Duration(milliseconds: 300));
        final authServiceCheck = ref.read(authServiceProvider);
        final checkUser = authServiceCheck.currentUser;
        if (checkUser != null && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ChatListScreen()),
          );
          return;
        }
      }

      if (mounted) {
        String errorMessage = 'An error occurred';
        if (errorStr.contains('channel-error')) {
          errorMessage = 'Firebase not initialized. Please restart the app.';
        } else if (errorStr.contains('weak-password')) {
          errorMessage = 'Password should be at least 6 characters';
        } else if (errorStr.contains('email-already-in-use')) {
          final authServiceCheck = ref.read(authServiceProvider);
          final checkUser = authServiceCheck.currentUser;
          if (checkUser != null && mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            );
            return;
          }
          errorMessage = 'Email is already registered';
        } else if (errorStr.contains('user-not-found')) {
          errorMessage = 'No account found with this email';
        } else if (errorStr.contains('wrong-password')) {
          errorMessage = 'Incorrect password';
        } else if (errorStr.contains('invalid-email')) {
          errorMessage = 'Invalid email format';
        } else if (!errorStr.contains('PigeonUserDetails') &&
            !errorStr.contains('List<Object?>')) {
          errorMessage = errorStr
              .replaceAll('Exception: ', '')
              .replaceAll('PlatformException: ', '');
        }

        if (!errorStr.contains('PigeonUserDetails') &&
            !errorStr.contains('List<Object?>')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGradientStart,
              AppColors.primaryGradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 80,
                      color: AppColors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'Welcome Back' : 'Create Account',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 48),
                    if (!_isLogin)
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter your name'
                            : null,
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter your email'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter your password'
                          : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.primaryGradientEnd,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : Text(
                                _isLogin ? 'Login' : 'Register',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  _emailController.text = 'demo@gmail.com';
                                  _passwordController.text = 'demo12';

                                  if (!_isLogin) {
                                    setState(() => _isLogin = true);
                                  }

                                  _handleSubmit();
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 6,
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: AppColors.white,
                            shadowColor: AppColors.deepPurple.withOpacity(0.25),
                          ),
                          child: const Text(
                            'Test Demo Account',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin
                            ? 'Don\'t have an account? Register'
                            : 'Already have an account? Login',
                        style: const TextStyle(color: AppColors.whiteText70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

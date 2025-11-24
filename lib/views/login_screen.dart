import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Login screen for user authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'customer';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final authViewModel = context.read<AuthViewModel>();
      authViewModel.login(
        _emailController.text.trim(),
        _passwordController.text,
        _selectedRole,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo/Icon with enhanced design
                    // Center(
                    //   child: Container(
                    //     width: 120,
                    //     height: 120,
                    //     decoration: BoxDecoration(
                    //       gradient: const LinearGradient(
                    //         colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    //         begin: Alignment.topLeft,
                    //         end: Alignment.bottomRight,
                    //       ),
                    //       borderRadius: BorderRadius.circular(32),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: const Color(
                    //             0xFF3B82F6,
                    //           ).withValues(alpha: 0.5),
                    //           blurRadius: 32,
                    //           spreadRadius: 4,
                    //           offset: const Offset(0, 8),
                    //         ),
                    //       ],
                    //     ),
                    //     child: const Icon(
                    //       Icons.chat_bubble_rounded,
                    //       size: 60,
                    //       color: Colors.white,
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 48),

                    // App Title with enhanced typography
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sign in to continue your conversations',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 56),

                    // Email Field with enhanced styling
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'you@example.com',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 22,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF161B22),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF30363D),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF30363D),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF3B82F6),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 20),

                    // Password Field with enhanced styling
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outlined,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 22,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF161B22),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF30363D),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF30363D),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF3B82F6),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 32),

                    // Role Selector with enhanced design
                    Text(
                      'Select Your Role',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = 'customer';
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: _selectedRole == 'customer'
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF3B82F6),
                                          Color(0xFF2563EB),
                                        ],
                                      )
                                    : null,
                                color: _selectedRole == 'customer'
                                    ? null
                                    : const Color(0xFF161B22),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _selectedRole == 'customer'
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFF30363D),
                                  width: 1.5,
                                ),
                                boxShadow: _selectedRole == 'customer'
                                    ? [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF3B82F6,
                                          ).withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_outline_rounded,
                                    color: _selectedRole == 'customer'
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.5),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Customer',
                                    style: TextStyle(
                                      color: _selectedRole == 'customer'
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = 'vendor';
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: _selectedRole == 'vendor'
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF3B82F6),
                                          Color(0xFF2563EB),
                                        ],
                                      )
                                    : null,
                                color: _selectedRole == 'vendor'
                                    ? null
                                    : const Color(0xFF161B22),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _selectedRole == 'vendor'
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFF30363D),
                                  width: 1.5,
                                ),
                                boxShadow: _selectedRole == 'vendor'
                                    ? [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF3B82F6,
                                          ).withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.store_outlined,
                                    color: _selectedRole == 'vendor'
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.5),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Vendor',
                                    style: TextStyle(
                                      color: _selectedRole == 'vendor'
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // Login Button with enhanced design (MVVM)
                    Consumer<AuthViewModel>(
                      builder: (context, authViewModel, child) {
                        // Show error message if exists
                        if (authViewModel.errorMessage != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        authViewModel.errorMessage!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFFEF4444),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                                elevation: 8,
                              ),
                            );
                            authViewModel.clearError();
                          });
                        }

                        // Navigate to chat list if authenticated
                        if (authViewModel.isAuthenticated) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.of(context).pushReplacementNamed('/chat-list');
                          });
                        }

                        final isLoading = authViewModel.isLoading;

                        return Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _handleLogin(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Footer text
                    Center(
                      child: Text(
                        'Secure authentication powered by encryption',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
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

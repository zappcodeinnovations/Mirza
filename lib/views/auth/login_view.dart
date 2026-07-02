import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';
import 'dart:io';
import '../main_navigation_shell.dart';
import 'register_view.dart';
import 'register_admin_view.dart';
import 'forgot_password_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.errorMessage ?? 'Authentication failed.',
          ),
          backgroundColor: AppTheme.neonPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon logo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.darkSurface,
                        border: Border.all(
                          color: AppTheme.darkAccent,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonBlue.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        AppIcons.lock,
                        size: 40,
                        color: AppTheme.neonBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Headings
                  Center(
                    child: Text(
                      "Welcome Back",
                      style: Theme.of(
                        context,
                      ).textTheme.displayLarge?.copyWith(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      "Access your Mirza analytics dashboard",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    cursorColor: AppTheme.neonGreen,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      hintText: "Enter your username",
                      prefixIcon: Icon(
                        AppIcons.person,
                        color: Color(0xFF475569),
                      ),
                    ),
                    style: const TextStyle(color: Color(0xFF223025)),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your username";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    cursorColor: AppTheme.neonGreen,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Enter your password",
                      prefixIcon: const Icon(
                        AppIcons.lock,
                        color: Color(0xFF475569),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? AppIcons.hide : AppIcons.show,
                          color: const Color(0xFF475569),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(color: Color(0xFF223025)),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your password";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Forgot Password Trigger
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordView(),
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: AppTheme.neonBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button with premium gradient background
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppTheme.purpleBlueGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonPurple.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: authController.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: authController.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              "LOG IN",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Optional Signup Redirection (only if enabled on the backend!)
                  if (authController.isRegistrationEnabled)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterView(),
                              ),
                            );
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              color: AppTheme.neonOrange,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                  // if (Platform.isIOS && authController.isAdminRegistrationEnabled) ...[
                  //   const SizedBox(height: 16),
                  //   Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       const Text(
                  //         "Admin user? ",
                  //         style: TextStyle(color: Color(0xFF94A3B8)),
                  //       ),
                  //       GestureDetector(
                  //         onTap: () {
                  //           Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //               builder: (_) => const RegisterAdminView(),
                  //             ),
                  //           );
                  //         },
                  //         child: const Text(
                  //           "Register Admin",
                  //           style: TextStyle(
                  //             color: AppTheme.neonBlue,
                  //             fontWeight: FontWeight.bold,
                  //             decoration: TextDecoration.underline,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

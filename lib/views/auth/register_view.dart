import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.register(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully! Please log in.'),
          backgroundColor: AppTheme.neonGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context); // Return to login
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'Registration failed.'),
          backgroundColor: AppTheme.neonPink,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
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
                    ),
                    child: const Icon(
                      AppIcons.addUser,
                      size: 40,
                      color: AppTheme.neonOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Headings
                Center(
                  child: Text(
                    "Create Account",
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge?.copyWith(fontSize: 28),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    "Sign up to get started with Mirza BI",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 40),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    hintText: "Enter desired username",
                    prefixIcon: Icon(AppIcons.person, color: Color(0xFF475569)),
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter a username";
                    }
                    if (value.trim().length < 4) {
                      return "Username must be at least 4 characters long";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Create secure password",
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
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a password";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters long";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  decoration: const InputDecoration(
                    labelText: "Confirm Password",
                    hintText: "Repeat secure password",
                    prefixIcon: Icon(
                      AppIcons.lockReset,
                      color: Color(0xFF475569),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please confirm your password";
                    }
                    if (value != _passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Submit Button
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.orangePinkGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonOrange.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: authController.isLoading
                        ? null
                        : _handleRegister,
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
                            "REGISTER",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';

class RegisterAdminView extends StatefulWidget {
  const RegisterAdminView({super.key});

  @override
  State<RegisterAdminView> createState() => _RegisterAdminViewState();
}

class _RegisterAdminViewState extends State<RegisterAdminView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.registerAdmin(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Admin Registration Successful. Please login.'),
          backgroundColor: AppTheme.neonGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.errorMessage ?? 'Registration failed.',
          ),
          backgroundColor: AppTheme.neonPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Registration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.darkSurface,
                        border: Border.all(color: AppTheme.darkAccent, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonGreen.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        AppIcons.person,
                        size: 40,
                        color: AppTheme.neonGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      "Create Admin Account",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          style: const TextStyle(color: Colors.black),
                          decoration: _inputDecoration("First Name"),
                          validator: (value) => value == null || value.isEmpty ? "Required" : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          style: const TextStyle(color: Colors.black),
                          decoration: _inputDecoration("Last Name"),
                          validator: (value) => value == null || value.isEmpty ? "Required" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.black ),
                    decoration: _inputDecoration("Email", icon: AppIcons.person),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Required";
                      if (!value.contains('@')) return "Invalid email";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _mobileController,
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration("Mobile Number", icon: Icons.phone),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration("Username", icon: AppIcons.person),
                    validator: (value) => value == null || value.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.black),
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(
                      "Password",
                      icon: AppIcons.lock,
                      suffix: IconButton(
                        icon: Icon(_obscurePassword ? AppIcons.hide : AppIcons.show, color: const Color(0xFF475569)),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) => value == null || value.length < 6 ? "Minimum 6 characters" : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _confirmPasswordController,
                    style: const TextStyle(color: Colors.black),
                    obscureText: _obscureConfirmPassword,
                    decoration: _inputDecoration(
                      "Confirm Password",
                      icon: AppIcons.lock,
                      suffix: IconButton(
                        icon: Icon(_obscureConfirmPassword ? AppIcons.hide : AppIcons.show, color: const Color(0xFF475569)),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) return "Passwords do not match";
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  
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
                      onPressed: authController.isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: authController.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            )
                          : const Text(
                              "REGISTER",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF475569)) : null,
      suffixIcon: suffix,
    );
  }
}

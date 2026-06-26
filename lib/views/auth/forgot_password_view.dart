import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  int _currentStep = 1; // 1: Email, 2: OTP, 3: New Password
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    if (!_formKey1.currentState!.validate()) return;

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.requestForgotPasswordOtp(
      _emailController.text.trim(),
    );
    if (success && mounted) {
      setState(() {
        _currentStep = 2;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "OTP sent successfully to ${_emailController.text.trim()}",
          ),
          backgroundColor: AppTheme.neonGreen,
        ),
      );
    } else if (mounted) {
      _showError(authController.errorMessage ?? 'Failed to send OTP.');
    }
  }

  Future<void> _submitOtp() async {
    if (!_formKey2.currentState!.validate()) return;

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.verifyForgotPasswordOtp(
      _otpController.text.trim(),
    );
    if (success && mounted) {
      setState(() {
        _currentStep = 3;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "OTP verified successfully. Set your new password.",
          ),
          backgroundColor: AppTheme.neonGreen,
        ),
      );
    } else if (mounted) {
      _showError(authController.errorMessage ?? 'OTP verification failed.');
    }
  }

  Future<void> _submitNewPassword() async {
    if (!_formKey3.currentState!.validate()) return;

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.resetPassword(
      _newPasswordController.text.trim(),
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Password reset successfully. Please login."),
          backgroundColor: AppTheme.neonGreen,
        ),
      );
      Navigator.pop(context); // Go back to login
    } else if (mounted) {
      _showError(authController.errorMessage ?? 'Password reset failed.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.neonPink,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        title: const Text(
          "Reset Password",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Progress tracker indicator
            Row(
              children: [
                _buildStepIndicator(1, "Email", _currentStep >= 1),
                _buildStepDivider(_currentStep >= 2),
                _buildStepIndicator(2, "OTP", _currentStep >= 2),
                _buildStepDivider(_currentStep >= 3),
                _buildStepIndicator(3, "Finish", _currentStep >= 3),
              ],
            ),
            const SizedBox(height: 40),

            // Main Forms based on state
            Expanded(
              child: SingleChildScrollView(child: _buildForm(authController)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepNum, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppTheme.neonBlue : AppTheme.darkSurface,
            border: Border.all(
              color: active ? AppTheme.neonBlue : AppTheme.darkAccent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              "$stepNum",
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF475569),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? Colors.white : const Color(0xFF475569),
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? AppTheme.neonBlue : AppTheme.darkAccent,
        margin: const EdgeInsets.only(bottom: 18),
      ),
    );
  }

  Widget _buildForm(AuthController authController) {
    if (_currentStep == 1) {
      return Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Forgot your password?",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              "Enter your registered email address and we'll send you an OTP to verify your account identity.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email Address",
                hintText: "example@gmail.com",
                prefixIcon: Icon(AppIcons.email),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter your email";
                }
                if (!RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                ).hasMatch(value)) {
                  return "Please enter a valid email address";
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            _buildSubmitButton(
              "SEND OTP",
              authController.isLoading,
              _submitEmail,
            ),
          ],
        ),
      );
    } else if (_currentStep == 2) {
      return Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Enter Verification Code",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              "We have sent a 6-digit OTP code to ${_emailController.text}. Please enter the code below to continue.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: "OTP Verification Code",
                hintText: "Enter 6-digit OTP",
                prefixIcon: Icon(AppIcons.security),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter the OTP";
                }
                if (value.trim().length < 4) {
                  return "Please enter a valid OTP code";
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            _buildSubmitButton(
              "VERIFY OTP",
              authController.isLoading,
              _submitOtp,
            ),
          ],
        ),
      );
    } else {
      return Form(
        key: _formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Define New Password",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              "Specify your secure new login password below.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                hintText: "Enter secure new password",
                prefixIcon: Icon(AppIcons.lock),
              ),
              style: const TextStyle(color: Colors.white),
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
            const SizedBox(height: 30),
            _buildSubmitButton(
              "RESET PASSWORD",
              authController.isLoading,
              _submitNewPassword,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSubmitButton(
    String label,
    bool loading,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: AppTheme.purpleBlueGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/api_client.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isRegistrationEnabled = true;
  bool _isAdminRegistrationEnabled = false;
  String? _otpResetToken;
  String? _resetEmail;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isRegistrationEnabled => _isRegistrationEnabled;
  bool get isAdminRegistrationEnabled => _isAdminRegistrationEnabled;
  String? get otpResetToken => _otpResetToken;
  String? get resetEmail => _resetEmail;

  bool get isAuthenticated => _currentUser != null;

  // Initialize and check authentication state (for splash screen)
  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check server signup availability in background
      _isRegistrationEnabled = await _authService.checkRegistrationEnabled();
      _isAdminRegistrationEnabled = await _authService.checkAdminRegistrationEnabled();
      
      final loggedIn = await _apiClient.isLoggedIn();
      if (loggedIn) {
        _currentUser = await _authService.getProfile();
        if (_currentUser == null) {
          // Token might be stale or invalid, clear
          await _apiClient.clearSession();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return isAuthenticated;
  }

  // Reload user profile in settings/profile screens
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _authService.getProfile();
      if (profile != null) {
        _currentUser = profile;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle User Registration
  Future<bool> register({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        username: username,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (result['success'] == true) {
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle Admin Registration
  Future<bool> registerAdmin({
    required String username,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String email,
    required String mobileNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.registerAdmin(
        username: username,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
        email: email,
        mobileNumber: mobileNumber,
      );

      if (result['success'] == true) {
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Admin registration failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle User Login
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(username: username, password: password);
      if (result['success'] == true) {
        _currentUser = await _authService.getProfile();
        return _currentUser != null;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Profile parameters
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String mobileNumber,
    required String gender,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        mobileNumber: mobileNumber,
        gender: gender,
      );

      if (success) {
        await loadProfile();
        return true;
      } else {
        _errorMessage = 'Failed to update profile details.';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request Forget Password OTP
  Future<bool> requestForgotPasswordOtp(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.forgotPassword(email);
      if (result['success'] == true) {
        _resetEmail = email;
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify Forgot Password OTP
  Future<bool> verifyForgotPasswordOtp(String otp) async {
    if (_resetEmail == null) {
      _errorMessage = 'Email address is missing.';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.verifyOtp(email: _resetEmail!, otp: otp);
      if (result['success'] == true) {
        _otpResetToken = result['reset_token'];
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Complete Password Reset
  Future<bool> resetPassword(String newPassword) async {
    if (_resetEmail == null || _otpResetToken == null) {
      _errorMessage = 'Reset flow configuration missing. Please request OTP again.';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.resetPassword(
        email: _resetEmail!,
        resetToken: _otpResetToken!,
        newPassword: newPassword,
      );

      if (result['success'] == true) {
        _otpResetToken = null;
        _resetEmail = null;
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change Password for Logged In User
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (result['success'] == true) {
        await logout(); // Force login again as per comments
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete Account
  Future<bool> deleteAccount(String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.deleteAccount(password);
      if (result['success'] == true) {
        await logout();
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout session
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}

import 'dart:convert';
import '../core/api_client.dart';
import '../core/api_endpoints.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // Check if registration is allowed on the server
  Future<bool> checkRegistrationEnabled() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.registrationStatus, requireAuth: false);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['registration_enabled'] as bool? ?? false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // Register a new account
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final body = {
        'username': username,
        'password': password,
        'confirm_password': confirmPassword,
      };
      final response = await _apiClient.post(ApiEndpoints.register, body: body, requireAuth: false);
      final data = jsonDecode(response.body);
      
      return {
        'success': data['success'] as bool? ?? response.statusCode == 200 || response.statusCode == 210,
        'message': data['message']?.toString() ?? 'Registration status received.',
        'user_id': data['user_id']?.toString() ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': 'Register error: $e'};
    }
  }

  // Log in using username and password
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final body = {
        'username': username,
        'password': password,
        'device_id': 'flutter-mobile-client',
        'fcm_token': 'fcm-placeholder-token',
      };
      final response = await _apiClient.post(ApiEndpoints.login, body: body, requireAuth: false);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final tokens = data['tokens'];
        if (tokens != null) {
          final String access = tokens['access'] ?? '';
          final String refresh = tokens['refresh'] ?? '';
          await _apiClient.saveTokens(access, refresh);
        }
        return {'success': true, 'message': data['message'] ?? 'Login successful'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Invalid username or password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Login server error: $e'};
    }
  }

  // Fetch logged in user profile details
  Future<UserModel?> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['profile'] != null) {
          return UserModel.fromJson(data['profile']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Update profile attributes
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String mobileNumber,
    required String gender,
  }) async {
    try {
      final body = {
        'first_name': firstName,
        'last_name': lastName,
        'mobile_number': mobileNumber,
        'gender': gender,
      };
      final response = await _apiClient.patch(ApiEndpoints.profileUpdate, body: body, requireAuth: true);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Send request for verification OTP to registered email
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final body = {'email': email};
      final response = await _apiClient.post(ApiEndpoints.forgotPassword, body: body, requireAuth: false);
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] as bool? ?? false,
        'message': data['message']?.toString() ?? 'OTP requested.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Forgot password error: $e'};
    }
  }

  // Verify OTP token code
  Future<Map<String, dynamic>> verifyOtp({required String email, required String otp}) async {
    try {
      final body = {'email': email, 'otp': otp};
      final response = await _apiClient.post(ApiEndpoints.verifyOtp, body: body, requireAuth: false);
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] as bool? ?? false,
        'message': data['message']?.toString() ?? 'OTP verified.',
        'reset_token': data['reset_token']?.toString() ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': 'OTP verification error: $e'};
    }
  }

  // Reset password using reset token
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final body = {
        'email': email,
        'reset_token': resetToken,
        'new_password': newPassword,
      };
      final response = await _apiClient.post(ApiEndpoints.resetPassword, body: body, requireAuth: false);
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] as bool? ?? false,
        'message': data['message']?.toString() ?? 'Password reset complete.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Reset password error: $e'};
    }
  }

  // Change password for logged in session
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final body = {
        'old_password': oldPassword,
        'new_password': newPassword,
      };
      final response = await _apiClient.post(ApiEndpoints.changePassword, body: body, requireAuth: true);
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] as bool? ?? false,
        'message': data['message']?.toString() ?? 'Password changed successfully.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Change password error: $e'};
    }
  }

  // Logout session
  Future<void> logout() async {
    await _apiClient.clearSession();
  }
}

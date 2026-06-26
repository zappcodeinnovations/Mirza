import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';
import 'app_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';

  final http.Client _client = http.Client();

  // Save tokens to device
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  // Get current access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  // Get current refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  // Clear authentication session
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // General Headers
  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // GET request wrapper
  Future<http.Response> get(String endpoint, {bool requireAuth = true}) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);

    try {
      var response = await _client.get(url, headers: headers);
      
      // Auto-refresh token if expired (401 Unauthorized)
      if (response.statusCode == 401 && requireAuth) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          final newHeaders = await _getHeaders(requireAuth: true);
          response = await _client.get(url, headers: newHeaders);
        }
      }
      return response;
    } on SocketException catch (_) {
      throw AppException('Please check your internet connection.');
    } on TimeoutException catch (_) {
      throw AppException('The connection timed out. Please try again later.');
    } on FormatException catch (_) {
      throw AppException('Invalid response format from server.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('An unexpected network error occurred.');
    }
  }

  // POST request wrapper
  Future<http.Response> post(String endpoint, {Object? body, bool requireAuth = true}) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);
    final encodedBody = body != null ? jsonEncode(body) : null;

    try {
      var response = await _client.post(url, headers: headers, body: encodedBody);
      
      if (response.statusCode == 401 && requireAuth) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          final newHeaders = await _getHeaders(requireAuth: true);
          response = await _client.post(url, headers: newHeaders, body: encodedBody);
        }
      }
      return response;
    } on SocketException catch (_) {
      throw AppException('Please check your internet connection.');
    } on TimeoutException catch (_) {
      throw AppException('The connection timed out. Please try again later.');
    } on FormatException catch (_) {
      throw AppException('Invalid response format from server.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('An unexpected network error occurred.');
    }
  }

  // PATCH request wrapper
  Future<http.Response> patch(String endpoint, {Object? body, bool requireAuth = true}) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);
    final encodedBody = body != null ? jsonEncode(body) : null;

    try {
      var response = await _client.patch(url, headers: headers, body: encodedBody);
      
      if (response.statusCode == 401 && requireAuth) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          final newHeaders = await _getHeaders(requireAuth: true);
          response = await _client.patch(url, headers: newHeaders, body: encodedBody);
        }
      }
      return response;
    } on SocketException catch (_) {
      throw AppException('Please check your internet connection.');
    } on TimeoutException catch (_) {
      throw AppException('The connection timed out. Please try again later.');
    } on FormatException catch (_) {
      throw AppException('Invalid response format from server.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('An unexpected network error occurred.');
    }
  }

  // Perform Token Refresh
  Future<bool> _attemptTokenRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await clearSession();
      return false;
    }

    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.tokenRefresh}');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String newAccess = data['access'];
        final String? newRefresh = data['refresh'] ?? refreshToken; // Keep old refresh if not returned
        
        await saveTokens(newAccess, newRefresh!);
        return true;
      } else {
        // Refresh token itself expired, force logout
        await clearSession();
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

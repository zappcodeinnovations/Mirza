import 'dart:convert';

import '../core/api_client.dart';
import '../core/api_endpoints.dart';
import '../models/new_launch_model.dart';

class NewLaunchService {
  final ApiClient _apiClient = ApiClient();

  Future<NewLaunchDashboardModel?> getNewLaunchDashboard() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.newLaunch,
        requireAuth: true,
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] != true) {
        return null;
      }

      return NewLaunchDashboardModel.fromJson(data);
    } catch (e) {
      print('Error fetching new launch dashboard: $e');
      return null;
    }
  }

  Future<NewLaunchProductDetailsModel?> getNewLaunchDetails(String skuCode) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.newLaunchDetails(skuCode),
        requireAuth: true,
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] != true) {
        return null;
      }

      return NewLaunchProductDetailsModel.fromJson(data);
    } catch (e) {
      print('Error fetching new launch product details: $e');
      return null;
    }
  }
}

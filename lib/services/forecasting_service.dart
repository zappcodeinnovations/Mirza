import 'dart:convert';

import '../core/api_client.dart';
import '../core/api_endpoints.dart';
import '../models/forecasting_model.dart';

class ForecastingService {
  final ApiClient _apiClient = ApiClient();

  Future<ForecastingDashboardModel?> getForecastingDashboard() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.forecasting,
        requireAuth: true,
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] != true || data['kpis'] == null) {
        return null;
      }

      return ForecastingDashboardModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}

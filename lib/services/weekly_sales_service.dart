import 'dart:convert';
import '../core/api_client.dart';
import '../core/api_endpoints.dart';
import '../models/weekly_sales_model.dart';

class WeeklySalesService {
  final ApiClient _apiClient;

  WeeklySalesService(this._apiClient);

  Future<WeeklySalesResponseModel?> getWeeklySales({
    int page = 1,
    List<String>? financialYears,
  }) async {
    try {
      List<String> queryParams = ['page=$page'];
      
      if (financialYears != null && financialYears.isNotEmpty) {
        queryParams.add('financial_years=${Uri.encodeComponent(financialYears.join(','))}');
      }
      
      final queryString = queryParams.join('&');
      final endpoint = '${ApiEndpoints.weeklySales}?$queryString';

      final response = await _apiClient.get(endpoint, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return WeeklySalesResponseModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Fetch weekly sales exception: $e');
      return null;
    }
  }

  Future<WeeklySalesFilterOptionsModel?> getWeeklySalesFilters() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.weeklySalesFilters, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return WeeklySalesFilterOptionsModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Fetch weekly sales filters exception: $e');
      return null;
    }
  }
}

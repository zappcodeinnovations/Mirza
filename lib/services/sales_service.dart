import 'dart:convert';
import '../core/api_client.dart';
import '../core/api_endpoints.dart';
import '../models/sales_model.dart';

class SalesService {
  final ApiClient _apiClient;

  SalesService(this._apiClient);

  Future<SalesResponseModel?> getSales({
    int page = 1,
    List<String>? platforms,
    List<String>? brands,
  }) async {
    try {
      // Build the query string manually since we might need multiple values per key
      // Or we can comma-separate them. Based on common REST practices, we'll comma-separate
      // platforms=ASOS,NEXT&brands=OTH
      
      List<String> queryParams = ['page=$page'];
      
      if (platforms != null && platforms.isNotEmpty) {
        queryParams.add('platforms=${Uri.encodeComponent(platforms.join(','))}');
      }
      
      if (brands != null && brands.isNotEmpty) {
        queryParams.add('brands=${Uri.encodeComponent(brands.join(','))}');
      }
      
      final queryString = queryParams.join('&');
      final endpoint = '${ApiEndpoints.sales}?$queryString';

      final response = await _apiClient.get(endpoint, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return SalesResponseModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Fetch sales exception: $e');
      return null;
    }
  }

  Future<SalesFilterOptionsModel?> getSalesFilters() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.salesFilters, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return SalesFilterOptionsModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Fetch sales filters exception: $e');
      return null;
    }
  }
}

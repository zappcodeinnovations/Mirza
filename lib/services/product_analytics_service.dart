import 'dart:convert';
import '../core/api_client.dart';
import '../core/api_endpoints.dart';
import '../models/product_analytics_model.dart';

class ProductAnalyticsService {
  final ApiClient _apiClient;

  ProductAnalyticsService(this._apiClient);

  Future<ProductAnalyticsModel?> getProductAnalytics(
    String sku, {
    String? weeks,
    String? from,
    String? to,
  }) async {
    try {
      List<String> queryParams = [];
      
      if (weeks != null && weeks.isNotEmpty) {
        queryParams.add('weeks=$weeks');
      } else {
        if (from != null && from.isNotEmpty) queryParams.add('from=$from');
        if (to != null && to.isNotEmpty) queryParams.add('to=$to');
      }
      
      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final endpoint = '${ApiEndpoints.productAnalytics(sku)}$queryString';

      final response = await _apiClient.get(endpoint, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return ProductAnalyticsModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Fetch product analytics exception: $e');
      return null;
    }
  }
}

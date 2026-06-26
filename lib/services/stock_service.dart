import 'dart:convert';
import '../core/api_client.dart';
import '../core/api_endpoints.dart';
import '../models/stock_model.dart';
import 'package:http/http.dart' as http;

class StockService {
  final ApiClient _apiClient;

  StockService(this._apiClient);

  Future<StockResponseModel?> getStock({
    int page = 1,
    List<String>? brands,
    List<String>? businessUnits,
  }) async {
    try {
      List<String> queryParams = ['page=$page'];
      
      if (brands != null && brands.isNotEmpty) {
        queryParams.add('brands=${Uri.encodeComponent(brands.join(','))}');
      }
      
      if (businessUnits != null && businessUnits.isNotEmpty) {
        queryParams.add('business_units=${Uri.encodeComponent(businessUnits.join(','))}');
      }
      
      final queryString = queryParams.join('&');
      final endpoint = '${ApiEndpoints.stock}?$queryString';

      final response = await _apiClient.get(endpoint, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return StockResponseModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Fetch stock exception: $e');
      return null;
    }
  }

  Future<StockFilterOptionsModel?> getStockFilters() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.stockFilters, requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return StockFilterOptionsModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Fetch stock filters exception: $e');
      return null;
    }
  }

  Future<http.Response?> downloadStockReport({
    List<String>? brands,
    List<String>? businessUnits,
  }) async {
    try {
      List<String> queryParams = [];
      
      if (brands != null && brands.isNotEmpty) {
        queryParams.add('brands=${Uri.encodeComponent(brands.join(','))}');
      }
      
      if (businessUnits != null && businessUnits.isNotEmpty) {
        queryParams.add('business_units=${Uri.encodeComponent(businessUnits.join(','))}');
      }
      
      final queryString = queryParams.join('&');
      final endpoint = '${ApiEndpoints.stockDownload}?$queryString';

      return await _apiClient.get(endpoint, requireAuth: true);
    } catch (e) {
      print('Download stock report exception: $e');
      return null;
    }
  }
}

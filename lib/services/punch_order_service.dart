import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_client.dart';
import '../core/api_endpoints.dart';
import '../models/punch_order_model.dart';

class PunchOrderService {
  final ApiClient _apiClient;

  PunchOrderService(this._apiClient);

  Future<PunchOrderCreateResponseModel?> createPunchOrder(Map<String, dynamic> requestData) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.punchOrderCreate,
        body: requestData,
        requireAuth: true,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PunchOrderCreateResponseModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Create punch order exception: $e');
      return null;
    }
  }

  Future<PunchOrderHistoryResponseModel?> getPunchOrderHistory() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.punchOrderHistory,
        requireAuth: true,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return PunchOrderHistoryResponseModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Get punch order history exception: $e');
      return null;
    }
  }

  Future<bool> deletePunchOrders({List<int>? ids, bool deleteAll = false}) async {
    try {
      final body = {
        if (ids != null && !deleteAll) "ids": ids,
        "delete_all": deleteAll,
      };
      
      final response = await _apiClient.post(
        ApiEndpoints.punchOrderDelete,
        body: body,
        requireAuth: true,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Delete punch order exception: $e');
      return false;
    }
  }

  Future<http.Response?> exportPunchOrders() async {
    try {
      // It can be a GET or POST depending on how backend is implemented. 
      // The instructions say GET API for history, and for export it didn't specify the method but gave a URL. 
      // Most of the exports are GET. Using GET.
      return await _apiClient.get(
        ApiEndpoints.punchOrderExport,
        requireAuth: true,
      );
    } catch (e) {
      print('Export punch orders exception: $e');
      return null;
    }
  }

  Future<PunchOrderOptionsResponseModel?> getPunchOrderOptions() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.punchOrderOptions,
        requireAuth: true,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return PunchOrderOptionsResponseModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Get punch order options exception: $e');
      return null;
    }
  }

  Future<List<String>> searchSkuOptions(String query) async {
    try {
      if (query.isEmpty) return [];
      
      final response = await _apiClient.get(
        '${ApiEndpoints.punchOrderSearch}?query=$query',
        requireAuth: true,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['success'] == true) {
          if (data['suggestions'] is List) {
            return (data['suggestions'] as List).map((e) => e.toString()).toList();
          } else if (data['data'] is List) {
            return (data['data'] as List).map((e) => e.toString()).toList();
          } else if (data['results'] is List) {
            return (data['results'] as List).map((e) => e.toString()).toList();
          }
        } else if (data is List) {
           return data.map((e) => e.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      print('Search SKU options exception: $e');
      return [];
    }
  }
}

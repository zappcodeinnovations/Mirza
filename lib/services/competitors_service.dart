import 'dart:convert';
import '../core/api_client.dart';
import '../core/api_endpoints.dart';
import '../models/competitors_model.dart';

class CompetitorsService {
  final ApiClient _apiClient;

  CompetitorsService(this._apiClient);

  Future<CompetitorResponseModel?> getCompetitors({int page = 1}) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.competitors}?page=$page', requireAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return CompetitorResponseModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Fetch competitors exception: $e');
      return null;
    }
  }
}

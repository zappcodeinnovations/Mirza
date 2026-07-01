import 'dart:convert';
import 'dart:io';
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

  Future<Map<String, dynamic>> addCompetitor(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.competitors, body: data, requireAuth: true);
      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'] == true || response.statusCode == 200 || response.statusCode == 201,
        'message': responseData['message'] ?? 'Competitor added successfully.',
      };
    } catch (e) {
      print('Add competitor exception: $e');
      return {'success': false, 'message': 'Failed to add competitor: $e'};
    }
  }

  Future<Map<String, dynamic>> uploadCompetitors(File file) async {
    try {
      final response = await _apiClient.postMultipart(
        ApiEndpoints.competitorUpload,
        fileField: 'file',
        file: file,
        requireAuth: true,
      );
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);
      return {
        'success': responseData['success'] == true || response.statusCode == 200 || response.statusCode == 201,
        'message': responseData['message'] ?? 'Competitors uploaded successfully.',
      };
    } catch (e) {
      print('Upload competitors exception: $e');
      return {'success': false, 'message': 'Failed to upload competitors: $e'};
    }
  }
}

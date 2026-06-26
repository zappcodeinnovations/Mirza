import 'dart:convert';
import '../core/api_client.dart';
import '../core/api_endpoints.dart';
import '../models/trend_model.dart';

class TrendService {
  final ApiClient _apiClient = ApiClient();

  Future<List<TrendPopularKeyword>> getPopularKeywords() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.trendPopular,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['top_keywords'] != null) {
          final List<dynamic> keywordsList = data['top_keywords'];
          return keywordsList.map((e) => TrendPopularKeyword.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching popular keywords: $e');
      return [];
    }
  }

  Future<List<TrendSuggestion>> getSuggestions({String? brand, String? gender}) async {
    try {
      String url = ApiEndpoints.trendSuggest;
      List<String> queryParams = [];
      if (brand != null && brand.isNotEmpty) {
        queryParams.add('brand=$brand');
      }
      if (gender != null && gender.isNotEmpty) {
        queryParams.add('gender=$gender');
      }
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await _apiClient.get(
        url,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['suggestions'] != null) {
          final List<dynamic> suggestionsList = data['suggestions'];
          return suggestionsList.map((e) => TrendSuggestion.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching trend suggestions: $e');
      return [];
    }
  }

  Future<TrendSearchResponse?> searchTrend(String keyword) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.trendSearch}?keyword=$keyword',
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return TrendSearchResponse.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Error searching trend data: $e');
      return null;
    }
  }
}

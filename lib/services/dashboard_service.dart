import 'package:flutter/foundation.dart';
import 'dart:convert';

import '../core/api_client.dart';
import '../core/api_endpoints.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  /// =====================================
  /// FETCH DASHBOARD FILTERS
  /// =====================================

  Future<DashboardFiltersModel?> getDashboardFilters() async {
    try {
      print(
        'DashboardService.getDashboardFilters: requesting ${ApiEndpoints.dashboardFilters}',
      );

      final response = await _apiClient.get(
        ApiEndpoints.dashboardFilters,
        requireAuth: true,
      );

      print(
        'DashboardService.getDashboardFilters: status=${response.statusCode}',
      );

      if (response.statusCode == 200) {
        print(
          'DashboardService.getDashboardFilters: raw response=${response.body}',
        );

        final data = jsonDecode(response.body);

        print(
          'DashboardService.getDashboardFilters: decoded keys=${data.keys.toList()}',
        );

        if (data['success'] == true) {
          final filters = DashboardFiltersModel.fromJson(data);

          print(
            'DashboardService.getDashboardFilters: parsed brands=${filters.brands}, genders=${filters.genders}, platforms=${filters.platforms}, footwearTypes=${filters.footwearTypes}, productTypes=${filters.productTypes}, materials=${filters.materials}, cities=${filters.cities}, seasons=${filters.seasons.map((e) => e.seasonName).toList()}, dateRanges=${filters.dateRanges.map((e) => e.label).toList()}',
          );

          return filters;
        }
      }

      print(
        'DashboardService.getDashboardFilters: unexpected response payload',
      );

      return null;
    } catch (e) {
      print('DashboardService.getDashboardFilters: error = $e');
      return null;
    }
  }

  /// =====================================
  /// FETCH KPI DATA
  /// =====================================

  Future<DashboardResponseModel?> getDashboardData({
    String? brand,
    String? gender,
    List<String>? platforms,
    String? footwearType,
    String? productType,
    String? material,
    String? season,
    String? city,
    String? dateRange,
  }) async {
    try {
      final Map<String, String> queryParams = {};

      if (brand != null && brand.isNotEmpty && brand != 'All') {
        queryParams['brand'] = brand;
      }

      if (gender != null && gender.isNotEmpty && gender != 'All') {
        queryParams['gender'] = gender;
      }

      if (platforms != null && platforms.isNotEmpty) {
        queryParams['platform'] = platforms.join(',');
      }

      if (footwearType != null &&
          footwearType.isNotEmpty &&
          footwearType != 'All') {
        queryParams['footwear_type'] = footwearType;
      }

      if (productType != null &&
          productType.isNotEmpty &&
          productType != 'All') {
        queryParams['product_type'] = productType;
      }

      if (material != null && material.isNotEmpty && material != 'All') {
        queryParams['material'] = material;
      }

      if (season != null && season.isNotEmpty && season != 'All') {
        queryParams['season'] = season;
      }

      if (city != null && city.isNotEmpty && city != 'All') {
        queryParams['city'] = city;
      }

      if (dateRange != null && dateRange.isNotEmpty && dateRange != 'All') {
        queryParams['date_range'] = dateRange;
      }

      final uri = Uri.parse(
        ApiEndpoints.dashboardData,
      ).replace(queryParameters: queryParams);

      final response = await _apiClient.get(uri.toString(), requireAuth: true);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return DashboardResponseModel.fromJson(data);
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}

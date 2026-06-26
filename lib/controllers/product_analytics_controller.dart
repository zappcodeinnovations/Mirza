import 'package:flutter/material.dart';
import '../models/product_analytics_model.dart';
import '../services/product_analytics_service.dart';
import '../core/api_client.dart';

class ProductAnalyticsController extends ChangeNotifier {
  final ProductAnalyticsService _analyticsService = ProductAnalyticsService(ApiClient());

  ProductAnalyticsController();

  bool _isLoading = false;
  String? _errorMessage;
  ProductAnalyticsModel? _analyticsData;

  // Filters
  String _selectedTimeframe = '8 Weeks'; // 'All', '8 Weeks', 'Custom'
  String? _customFromDate;
  String? _customToDate;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProductAnalyticsModel? get analyticsData => _analyticsData;
  String get selectedTimeframe => _selectedTimeframe;

  Future<void> loadAnalytics(String sku) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? weeksParam;
      String? fromParam;
      String? toParam;

      if (_selectedTimeframe == 'All') {
        weeksParam = 'all';
      } else if (_selectedTimeframe == '8 Weeks') {
        weeksParam = '8';
      } else if (_selectedTimeframe == 'Custom') {
        fromParam = _customFromDate;
        toParam = _customToDate;
      }

      final response = await _analyticsService.getProductAnalytics(
        sku,
        weeks: weeksParam,
        from: fromParam,
        to: toParam,
      );

      if (response != null && response.success) {
        _analyticsData = response;
      } else {
        _errorMessage = 'Failed to load product analytics.';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTimeframe(String timeframe, String sku, {String? from, String? to}) {
    _selectedTimeframe = timeframe;
    if (timeframe == 'Custom') {
      _customFromDate = from;
      _customToDate = to;
    }
    loadAnalytics(sku);
  }
}

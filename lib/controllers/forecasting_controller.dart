import 'package:flutter/material.dart';

import '../models/forecasting_model.dart';
import '../services/forecasting_service.dart';

class ForecastingController extends ChangeNotifier {
  final ForecastingService _service = ForecastingService();

  bool _isLoading = false;
  String? _errorMessage;
  ForecastingDashboardModel? _dashboard;
  bool _showAllKpis = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ForecastingDashboardModel? get dashboard => _dashboard;
  ForecastingKpiSummary? get kpis => _dashboard?.kpis;
  List<ForecastingTopProduct> get topProducts =>
      _dashboard?.topProducts ?? const [];
  String get cacheLastUpdated => _dashboard?.cacheLastUpdated ?? '';
  bool get showAllKpis => _showAllKpis;

  Future<void> loadForecasting() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboard = await _service.getForecastingDashboard();
      if (_dashboard == null) {
        _errorMessage = 'Unable to load forecasting data.';
      }
    } catch (e) {
      _errorMessage = 'Unable to load forecasting data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleKpis() {
    _showAllKpis = !_showAllKpis;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../models/reports_model.dart';
import '../models/product_model.dart';
import '../models/weekly_report_model.dart';
import '../services/reports_service.dart';

class ReportsController extends ChangeNotifier {
  final ReportsService _reportsService = ReportsService();

  bool _isLoading = false;
  String? _errorMessage;

  ReturnsKpiModel? _returnsKpis;
  ForecastingKpiModel? _forecastingKpis;
  NewLaunchKpiModel? _newLaunchKpis;
  List<MissingProductModel> _missingProducts = [];
  List<OverstockReportModel> _overstockProducts = [];
  StockStatusKpiModel? _stockStatus;
  WeeklySalesKpiModel? _weeklySales;
  List<String> _popularKeywords = [];
  WeeklyReportModel? _weeklyReportData;
  List<OverallReportModel> _overallReports = [];
  List<ForecastReportModel> _forecastReports = [];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ReturnsKpiModel? get returnsKpis => _returnsKpis;
  ForecastingKpiModel? get forecastingKpis => _forecastingKpis;
  NewLaunchKpiModel? get newLaunchKpis => _newLaunchKpis;
  List<MissingProductModel> get missingProducts => _missingProducts;
  List<OverstockReportModel> get overstockProducts => _overstockProducts;
  StockStatusKpiModel? get stockStatus => _stockStatus;
  WeeklySalesKpiModel? get weeklySales => _weeklySales;
  List<String> get popularKeywords => _popularKeywords;
  WeeklyReportModel? get weeklyReportData => _weeklyReportData;
  List<OverallReportModel> get overallReports => _overallReports;
  List<ForecastReportModel> get forecastReports => _forecastReports;
  // Load all reports simultaneously (dashboard initialization or tools section reload)
  Future<void> loadAllReports() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stockStatus = await _reportsService.getStockStatus();
      _weeklySales = await _reportsService.getWeeklySales();
      _popularKeywords = await _reportsService.getPopularKeywords();
      _overallReports = await _reportsService.getOverallReport();
      _forecastReports = await _reportsService.getForecastReport();
      _overstockProducts = await _reportsService.getOverstockReport();
      _missingProducts = await _reportsService.getMissingProducts();
      
      if (_overallReports.isEmpty) {
         // Attempt to fetch again and see if we can get an error from service
      }
    } catch (e, stacktrace) {
      _errorMessage = 'Some reports failed to load: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reload returns specific report
  Future<void> reloadReturns() async {
    try {
      _returnsKpis = await _reportsService.getReturnsKpis();
      notifyListeners();
    } catch (_) {}
  }

  // Reload forecasting specific report
  Future<void> reloadForecasting() async {
    try {
      _forecastingKpis = await _reportsService.getForecastingKpis();
      notifyListeners();
    } catch (_) {}
  }

  // Trigger Download
  Future<void> loadWeeklyReport() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _weeklyReportData = await _reportsService.getWeeklyReport();
    } catch (e) {
      _errorMessage = 'Failed to load weekly report: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> downloadWeeklyReport({bool isExcel = false}) async {
    return await _reportsService.downloadWeeklyReport(isExcel: isExcel);
  }

  Future<bool> downloadOverallReport({bool isExcel = false}) async {
    return await _reportsService.downloadOverallReport(isExcel: isExcel);
  }

  Future<bool> downloadForecastReport({bool isExcel = false}) async {
    return await _reportsService.downloadForecastReport(isExcel: isExcel);
  }

  Future<bool> downloadOverstockReport({bool isExcel = false}) async {
    return await _reportsService.downloadOverstockReport(isExcel: isExcel);
  }

  Future<bool> downloadMissingProductsReport({bool isExcel = false}) async {
    return await _reportsService.downloadMissingProductsReport(isExcel: isExcel);
  }
}

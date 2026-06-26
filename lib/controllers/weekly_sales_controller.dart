import 'package:flutter/material.dart';
import '../models/weekly_sales_model.dart';
import '../services/weekly_sales_service.dart';
import '../core/api_client.dart';

class WeeklySalesController extends ChangeNotifier {
  final WeeklySalesService _weeklySalesService = WeeklySalesService(ApiClient());

  WeeklySalesController();

  bool _isLoading = false;
  String? _errorMessage;

  WeeklySalesKpiModel? _kpis;
  List<WeeklySalesRecordModel> _records = [];
  WeeklySalesPaginationModel? _pagination;

  // Filter options from API
  List<String> _availableFinancialYears = [];

  // Currently selected filters
  List<String> _selectedFinancialYears = [];

  bool _isFetchingMore = false;
  bool _filtersLoaded = false;

  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  String? get errorMessage => _errorMessage;

  WeeklySalesKpiModel? get kpis => _kpis;
  List<WeeklySalesRecordModel> get records => _records;
  WeeklySalesPaginationModel? get pagination => _pagination;
  bool get hasMoreData => (_pagination?.currentPage ?? 1) < (_pagination?.totalPages ?? 1);

  List<String> get availableFinancialYears => _availableFinancialYears;
  List<String> get selectedFinancialYears => _selectedFinancialYears;

  Future<void> loadInitialData() async {
    if (_records.isNotEmpty || _isLoading) return;
    
    _isLoading = true;
    notifyListeners();
    
    await Future.wait([
      _loadFilters(),
      loadWeeklySales(refresh: true, notifyStart: false),
    ]);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFilters() async {
    if (_filtersLoaded) return;
    
    final response = await _weeklySalesService.getWeeklySalesFilters();
    if (response != null) {
      _availableFinancialYears = response.financialYears;
      _filtersLoaded = true;
    }
  }

  Future<void> loadWeeklySales({bool refresh = false, bool notifyStart = true}) async {
    if (refresh) {
      if (notifyStart) {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();
      }
    } else {
      if (_isFetchingMore || !hasMoreData) return;
      _isFetchingMore = true;
      notifyListeners();
    }

    try {
      final nextPage = refresh ? 1 : (_pagination?.currentPage ?? 0) + 1;
      final response = await _weeklySalesService.getWeeklySales(
        page: nextPage,
        financialYears: _selectedFinancialYears.isNotEmpty ? _selectedFinancialYears : null,
      );
      
      if (response != null) {
        if (refresh) {
          _records = response.records;
          _kpis = response.kpis;
        } else {
          _records.addAll(response.records);
        }
        _pagination = response.pagination;
      } else if (refresh) {
        _errorMessage = 'Failed to load weekly sales data.';
      }
    } catch (e) {
      if (refresh) _errorMessage = 'An error occurred: $e';
    } finally {
      if (refresh) {
        if (notifyStart) _isLoading = false;
      } else {
        _isFetchingMore = false;
      }
      notifyListeners();
    }
  }

  void updateFilters({required List<String> financialYears}) {
    _selectedFinancialYears = financialYears;
    loadWeeklySales(refresh: true);
  }

  void clearFilters() {
    _selectedFinancialYears = [];
    loadWeeklySales(refresh: true);
  }
}

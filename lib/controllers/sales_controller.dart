import 'package:flutter/material.dart';
import '../models/sales_model.dart';
import '../services/sales_service.dart';
import '../core/api_client.dart';

class SalesController extends ChangeNotifier {
  final SalesService _salesService = SalesService(ApiClient());

  SalesController();

  bool _isLoading = false;
  String? _errorMessage;

  SalesKpiModel? _kpis;
  List<SalesRecordModel> _salesRecords = [];
  SalesPaginationModel? _pagination;

  // Filter options from API
  List<String> _availablePlatforms = [];
  List<String> _availableBrands = [];

  // Currently selected filters
  List<String> _selectedPlatforms = [];
  List<String> _selectedBrands = [];

  bool _isFetchingMore = false;
  bool _filtersLoaded = false;

  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  String? get errorMessage => _errorMessage;

  SalesKpiModel? get kpis => _kpis;
  List<SalesRecordModel> get salesRecords => _salesRecords;
  SalesPaginationModel? get pagination => _pagination;
  bool get hasMoreData => (_pagination?.currentPage ?? 1) < (_pagination?.totalPages ?? 1);

  List<String> get availablePlatforms => _availablePlatforms;
  List<String> get availableBrands => _availableBrands;
  
  List<String> get selectedPlatforms => _selectedPlatforms;
  List<String> get selectedBrands => _selectedBrands;

  Future<void> loadInitialData() async {
    if (_salesRecords.isNotEmpty || _isLoading) return;
    
    _isLoading = true;
    notifyListeners();
    
    await Future.wait([
      _loadFilters(),
      loadSales(refresh: true, notifyStart: false),
    ]);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFilters() async {
    if (_filtersLoaded) return;
    
    final response = await _salesService.getSalesFilters();
    if (response != null) {
      _availablePlatforms = response.platforms;
      _availableBrands = response.brands;
      _filtersLoaded = true;
    }
  }

  Future<void> loadSales({bool refresh = false, bool notifyStart = true}) async {
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
      final response = await _salesService.getSales(
        page: nextPage,
        platforms: _selectedPlatforms.isNotEmpty ? _selectedPlatforms : null,
        brands: _selectedBrands.isNotEmpty ? _selectedBrands : null,
      );
      
      if (response != null) {
        if (refresh) {
          _salesRecords = response.records;
          _kpis = response.kpis;
        } else {
          _salesRecords.addAll(response.records);
        }
        _pagination = response.pagination;
      } else if (refresh) {
        _errorMessage = 'Failed to load sales data.';
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

  void updateFilters({required List<String> platforms, required List<String> brands}) {
    _selectedPlatforms = platforms;
    _selectedBrands = brands;
    // Reload data with new filters
    loadSales(refresh: true);
  }

  void clearFilters() {
    _selectedPlatforms = [];
    _selectedBrands = [];
    loadSales(refresh: true);
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/stock_model.dart';
import '../services/stock_service.dart';
import '../core/api_client.dart';

class StockController extends ChangeNotifier {
  final StockService _stockService = StockService(ApiClient());

  StockController();

  bool _isLoading = false;
  String? _errorMessage;

  StockKpiModel? _kpis;
  List<StockRecordModel> _stockRecords = [];
  StockPaginationModel? _pagination;

  // Filter options from API
  List<String> _availableBrands = [];
  List<String> _availableBusinessUnits = [];

  // Currently selected filters
  List<String> _selectedBrands = [];
  List<String> _selectedBusinessUnits = [];

  bool _isFetchingMore = false;
  bool _filtersLoaded = false;
  bool _isDownloading = false;

  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get isDownloading => _isDownloading;
  String? get errorMessage => _errorMessage;

  StockKpiModel? get kpis => _kpis;
  List<StockRecordModel> get stockRecords => _stockRecords;
  StockPaginationModel? get pagination => _pagination;
  bool get hasMoreData => (_pagination?.currentPage ?? 1) < (_pagination?.totalPages ?? 1);

  List<String> get availableBrands => _availableBrands;
  List<String> get availableBusinessUnits => _availableBusinessUnits;
  
  List<String> get selectedBrands => _selectedBrands;
  List<String> get selectedBusinessUnits => _selectedBusinessUnits;

  Future<void> loadInitialData() async {
    if (_stockRecords.isNotEmpty || _isLoading) return;
    
    _isLoading = true;
    notifyListeners();
    
    await Future.wait([
      _loadFilters(),
      loadStock(refresh: true, notifyStart: false),
    ]);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFilters() async {
    if (_filtersLoaded) return;
    
    final response = await _stockService.getStockFilters();
    if (response != null) {
      _availableBrands = response.brands;
      _availableBusinessUnits = response.businessUnits;
      _filtersLoaded = true;
    }
  }

  Future<void> loadStock({bool refresh = false, bool notifyStart = true}) async {
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
      final response = await _stockService.getStock(
        page: nextPage,
        brands: _selectedBrands.isNotEmpty ? _selectedBrands : null,
        businessUnits: _selectedBusinessUnits.isNotEmpty ? _selectedBusinessUnits : null,
      );
      
      if (response != null) {
        if (refresh) {
          _stockRecords = response.records;
          _kpis = response.kpis;
        } else {
          _stockRecords.addAll(response.records);
        }
        _pagination = response.pagination;
      } else if (refresh) {
        _errorMessage = 'Failed to load stock data.';
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

  void updateFilters({required List<String> brands, required List<String> businessUnits}) {
    _selectedBrands = brands;
    _selectedBusinessUnits = businessUnits;
    loadStock(refresh: true);
  }

  void clearFilters() {
    _selectedBrands = [];
    _selectedBusinessUnits = [];
    loadStock(refresh: true);
  }

  Future<bool> downloadStockReport(BuildContext context) async {
    _isDownloading = true;
    notifyListeners();

    try {
      final response = await _stockService.downloadStockReport(
        brands: _selectedBrands.isNotEmpty ? _selectedBrands : null,
        businessUnits: _selectedBusinessUnits.isNotEmpty ? _selectedBusinessUnits : null,
      );
      
      if (response != null && response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${dir.path}/stock_report_$timestamp.csv');
        await file.writeAsBytes(response.bodyBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report downloaded successfully!')),
          );
        }

        // Share the file so the user can save it anywhere
        await Share.shareXFiles([XFile(file.path)], text: 'Stock Report');
        return true;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to download report. Please try again.')),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading report: $e')),
        );
      }
      return false;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }
}

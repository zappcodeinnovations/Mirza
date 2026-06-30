import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardController extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  /// now holds the full API response
  DashboardResponseModel? _dashboardData;

  bool _isLoading = false;
  String? _errorMessage;

  /// =========================
  /// SELECTED FILTERS
  /// =========================
  String _selectedBrand = 'All';
  String _selectedGender = 'All';
  List<String> _selectedPlatforms = [];
  String _selectedFootwearType = 'All';
  String _selectedProductType = 'All';
  String _selectedMaterial = 'All';
  String _selectedSeason = 'All';
  String _selectedCity = 'All';
  String _selectedDateRange = 'All';

  /// =========================
  /// KPI EXPANSION FLAG
  /// =========================
  bool _showMoreKpis = false;

  /// =========================
  /// GETTERS
  /// =========================
  DashboardResponseModel? get dashboardData => _dashboardData;
  DashboardFiltersModel? get filters => _dashboardData?.filters;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get selectedBrand => _selectedBrand;
  String get selectedGender => _selectedGender;
  List<String> get selectedPlatforms => _selectedPlatforms;
  String get selectedFootwearType => _selectedFootwearType;
  String get selectedProductType => _selectedProductType;
  String get selectedMaterial => _selectedMaterial;
  String get selectedSeason => _selectedSeason;
  String get selectedCity => _selectedCity;
  String get selectedDateRange => _selectedDateRange;

  bool get showMoreKpis => _showMoreKpis;

  void toggleMoreKpis() {
    _showMoreKpis = !_showMoreKpis;
    notifyListeners();
  }

  /// =========================
  /// INITIALIZE DASHBOARD
  /// =========================
  Future<void> initializeDashboard() async {
    print('DashboardController.initializeDashboard: start');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('DashboardController.initializeDashboard: fetching filters');
      final filters = await _dashboardService.getDashboardFilters();
      print(
        'DashboardController.initializeDashboard: filters fetched = ${filters != null}',
      );

      _dashboardData = DashboardResponseModel(
        filters: filters,
        kpis: null,
        autoInsights: [],
        topProducts: [],
        styleMix: null,
        colorMix: null,
        materialMix: null,
        returnAnalysis: null,
        seasonalTop: null,
        cityProducts: null,
      );

      await fetchMetrics();
    } catch (e) {
      print('DashboardController.initializeDashboard: error = $e');
      _errorMessage = 'Failed to load dashboard data.';
    } finally {
      print('DashboardController.initializeDashboard: done');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// =========================
  /// SET FILTERS
  /// =========================
  void setFilters({
    String? brand,
    String? gender,
    List<String>? platforms,
    String? footwearType,
    String? productType,
    String? material,
    String? season,
    String? city,
    String? dateRange,
  }) {
    if (brand != null) _selectedBrand = brand;
    if (gender != null) _selectedGender = gender;
    if (platforms != null) _selectedPlatforms = platforms;
    if (footwearType != null) _selectedFootwearType = footwearType;
    if (productType != null) _selectedProductType = productType;
    if (material != null) _selectedMaterial = material;
    if (season != null) _selectedSeason = season;
    if (city != null) _selectedCity = city;
    if (dateRange != null) _selectedDateRange = dateRange;

    notifyListeners();
    fetchMetrics(showLoadingIndicator: true);
  }

  /// =========================
  /// RESET FILTERS
  /// =========================
  void resetFilters() {
    _selectedBrand = 'All';
    _selectedGender = 'All';
    _selectedPlatforms = [];
    _selectedFootwearType = 'All';
    _selectedProductType = 'All';
    _selectedMaterial = 'All';
    _selectedSeason = 'All';
    _selectedCity = 'All';
    _selectedDateRange = 'All';
    notifyListeners();
    fetchMetrics(showLoadingIndicator: true);
  }

  /// =========================
  /// FETCH DASHBOARD DATA
  /// =========================
  Future<void> fetchMetrics({bool showLoadingIndicator = false}) async {
    if (showLoadingIndicator) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final data = await _dashboardService.getDashboardData(
        brand: _selectedBrand,
        gender: _selectedGender,
        platforms: _selectedPlatforms,
        footwearType: _selectedFootwearType,
        productType: _selectedProductType,
        material: _selectedMaterial,
        season: _selectedSeason,
        city: _selectedCity,
        dateRange: _selectedDateRange,
      );

      if (data != null) {
        final preservedFilters = _dashboardData?.filters;
        final incomingFilters = data.filters;

        if (preservedFilters != null && _isEmptyFilters(incomingFilters)) {
          _dashboardData = DashboardResponseModel(
            filters: preservedFilters,
            kpis: data.kpis,
            autoInsights: data.autoInsights,
            topProducts: data.topProducts,
            styleMix: data.styleMix,
            colorMix: data.colorMix,
            materialMix: data.materialMix,
            returnAnalysis: data.returnAnalysis,
            seasonalTop: data.seasonalTop,
            cityProducts: data.cityProducts,
          );
        } else {
          _dashboardData = data;
        }
      } else {
        print('DashboardController.fetchMetrics: no data returned');
        _errorMessage = 'No dashboard data returned from server.';
      }
    } catch (e) {
      print('DashboardController.fetchMetrics: error = $e');
      _errorMessage = e.toString();
    } finally {
      if (showLoadingIndicator) _isLoading = false;
      notifyListeners();
    }
  }

  bool _isEmptyFilters(DashboardFiltersModel? filters) {
    if (filters == null) {
      return true;
    }

    return filters.brands.isEmpty &&
        filters.genders.isEmpty &&
        filters.platforms.isEmpty &&
        filters.footwearTypes.isEmpty &&
        filters.productTypes.isEmpty &&
        filters.materials.isEmpty &&
        filters.cities.isEmpty &&
        filters.seasons.isEmpty &&
        filters.dateRanges.isEmpty;
  }
}

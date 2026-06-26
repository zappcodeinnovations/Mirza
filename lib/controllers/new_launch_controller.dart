import 'package:flutter/material.dart';

import '../models/new_launch_model.dart';
import '../services/new_launch_service.dart';

class NewLaunchController extends ChangeNotifier {
  final NewLaunchService _service = NewLaunchService();

  bool _isLoading = false;
  String? _errorMessage;
  NewLaunchDashboardModel? _dashboard;
  bool _showAllKpis = false;

  NewLaunchProductDetailsModel? _selectedProductDetails;
  bool _isDetailsLoading = false;
  String? _detailsErrorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  NewLaunchDashboardModel? get dashboard => _dashboard;
  NewLaunchKpis? get kpis => _dashboard?.kpis;
  List<NewLaunchProduct> get products => _dashboard?.products ?? const [];
  bool get showAllKpis => _showAllKpis;

  NewLaunchProductDetailsModel? get selectedProductDetails => _selectedProductDetails;
  bool get isDetailsLoading => _isDetailsLoading;
  String? get detailsErrorMessage => _detailsErrorMessage;

  Future<void> loadNewLaunch() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboard = await _service.getNewLaunchDashboard();
      if (_dashboard == null) {
        _errorMessage = 'Unable to load new launch data.';
      }
    } catch (e) {
      _errorMessage = 'Unable to load new launch data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNewLaunchDetails(String skuCode) async {
    _isDetailsLoading = true;
    _detailsErrorMessage = null;
    notifyListeners();

    try {
      _selectedProductDetails = await _service.getNewLaunchDetails(skuCode);
      if (_selectedProductDetails == null) {
        _detailsErrorMessage = 'Failed to load product details';
      }
    } catch (e) {
      _detailsErrorMessage = 'An error occurred while loading product details: $e';
    } finally {
      _isDetailsLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedProduct() {
    _selectedProductDetails = null;
    _detailsErrorMessage = null;
    notifyListeners();
  }

  void toggleKpis() {
    _showAllKpis = !_showAllKpis;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../models/competitors_model.dart';
import '../services/competitors_service.dart';

import '../core/api_client.dart';

class CompetitorsController extends ChangeNotifier {
  final CompetitorsService _competitorsService = CompetitorsService(ApiClient());

  CompetitorsController();

  bool _isLoading = false;
  String? _errorMessage;

  List<CompetitorModel> _competitors = [];
  CompetitorPaginationModel? _pagination;

  bool _isFetchingMore = false;

  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  String? get errorMessage => _errorMessage;

  List<CompetitorModel> get competitors => _competitors;
  CompetitorPaginationModel? get pagination => _pagination;
  bool get hasMoreData => (_pagination?.currentPage ?? 1) < (_pagination?.totalPages ?? 1);

  Future<void> loadCompetitors({bool refresh = false}) async {
    if (refresh) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    } else {
      if (_isFetchingMore || !hasMoreData) return;
      _isFetchingMore = true;
      notifyListeners();
    }

    try {
      final nextPage = refresh ? 1 : (_pagination?.currentPage ?? 0) + 1;
      final response = await _competitorsService.getCompetitors(page: nextPage);
      
      if (response != null) {
        if (refresh) {
          _competitors = response.records;
        } else {
          _competitors.addAll(response.records);
        }
        _pagination = response.pagination;
      } else if (refresh) {
        _errorMessage = 'Failed to load competitors.';
      }
    } catch (e) {
      if (refresh) _errorMessage = 'An error occurred: $e';
    } finally {
      if (refresh) {
        _isLoading = false;
      } else {
        _isFetchingMore = false;
      }
      notifyListeners();
    }
  }
}

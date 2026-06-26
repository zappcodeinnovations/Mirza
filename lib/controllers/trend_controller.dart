import 'package:flutter/material.dart';
import '../models/trend_model.dart';
import '../services/trend_service.dart';

class TrendController extends ChangeNotifier {
  final TrendService _service = TrendService();

  List<TrendPopularKeyword> _popularKeywords = [];
  List<TrendPopularKeyword> get popularKeywords => _popularKeywords;
  bool _isLoadingPopular = false;
  bool get isLoadingPopular => _isLoadingPopular;
  String? _popularErrorMessage;
  String? get popularErrorMessage => _popularErrorMessage;

  TrendSearchResponse? _searchResult;
  TrendSearchResponse? get searchResult => _searchResult;
  bool _isSearching = false;
  bool get isSearching => _isSearching;
  String? _searchErrorMessage;
  String? get searchErrorMessage => _searchErrorMessage;

  List<TrendSuggestion> _suggestions = [];
  List<TrendSuggestion> get suggestions => _suggestions;
  bool _isSuggesting = false;
  bool get isSuggesting => _isSuggesting;

  Future<void> loadPopularKeywords() async {
    _isLoadingPopular = true;
    _popularErrorMessage = null;
    notifyListeners();

    try {
      _popularKeywords = await _service.getPopularKeywords();
      if (_popularKeywords.isEmpty) {
        _popularErrorMessage = 'No popular keywords found.';
      }
    } catch (e) {
      _popularErrorMessage = 'Error loading popular keywords: $e';
    } finally {
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  Future<void> searchTrend(String keyword) async {
    if (keyword.isEmpty) return;

    _isSearching = true;
    _searchErrorMessage = null;
    _searchResult = null; // clear previous result
    notifyListeners();

    try {
      _searchResult = await _service.searchTrend(keyword);
      if (_searchResult == null) {
        _searchErrorMessage = 'No data found for keyword: $keyword';
      }
    } catch (e) {
      _searchErrorMessage = 'Error searching trend: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> loadSuggestions({String? brand, String? gender}) async {
    _isSuggesting = true;
    notifyListeners();

    try {
      _suggestions = await _service.getSuggestions(brand: brand, gender: gender);
    } catch (e) {
      _suggestions = [];
    } finally {
      _isSuggesting = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResult = null;
    _searchErrorMessage = null;
    notifyListeners();
  }
}
